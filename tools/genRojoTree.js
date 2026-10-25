const fs = require("node:fs");
const path = require("node:path");
const os = require("node:os");
const { spawn } = require("node:child_process");

const TEMPLATE = "rojo.project.template.json";
const OUTPUT = "default.project.json";
const SOURCE = "src/SourceCode";

function isServerName(name) {
  return /(?:^|[._-])server(?:[._-]|$)/i.test(name)
    || /Server(?=[A-Z0-9._-]|$)/.test(name)
    || /server$/i.test(name);
}

function describeFile(name) {
  const script = name.match(/^(.*?)(\.(server|client))?\.(lua|luau)$/i);
  if (script) {
    const server = script[3]?.toLowerCase() === "server" || isServerName(script[1]);
    if (server && script[3]?.toLowerCase() === "client") {
      throw new Error(`Nome ambiguo client/server: ${name}`);
    }
    return { name: script[1], server, init: script[1].toLowerCase() === "init" };
  }
  if (/\.meta\.json$/i.test(name)) return null;
  if (/\.project\.json$/i.test(name)) {
    throw new Error(`Progetto annidato non supportato in ${SOURCE}: ${name}`);
  }
  const asset = name.match(/^(.*?)\.(?:model\.json|rbxm|rbxmx|json|toml|txt|csv)$/i);
  return asset ? { name: asset[1], server: isServerName(asset[1]), init: false } : null;
}

function folder(root, parts) {
  let current = root;
  for (const part of parts) {
    if (part.startsWith("$")) throw new Error(`Nome Rojo riservato: ${part}`);
    if (!Object.hasOwn(current, part)) {
      Object.defineProperty(current, part, {
        value: { $className: "Folder" }, enumerable: true, writable: true, configurable: true,
      });
    }
    current = current[part];
  }
  return current;
}

function generateProject(rootDir) {
  const project = JSON.parse(fs.readFileSync(path.join(rootDir, TEMPLATE), "utf8"));
  const roots = {
    shared: project.tree?.ReplicatedStorage?.SourceCode,
    server: project.tree?.ServerScriptService?.SourceCode,
  };
  for (const [side, root] of Object.entries(roots)) {
    if (!root || root.$path) throw new Error(`SourceCode ${side} deve essere una cartella senza $path nel template`);
  }
  const claimed = new Map();
  const ignored = new Set(project.globIgnorePaths ?? []);
  const sourceDir = path.join(rootDir, SOURCE);
  if (!fs.statSync(sourceDir).isDirectory()) throw new Error(`Cartella mancante: ${SOURCE}`);

  function targetParts(parts, server) {
    return server ? parts.map((part) => part.toLowerCase() === "utilities" ? "ServerUtilities" : part) : parts;
  }

  function addFile(parts, filename, description, server) {
    const virtual = targetParts(parts, server);
    const destination = description.init ? virtual : [...virtual, description.name];
    if (destination.length === 0) throw new Error(`init alla radice di ${SOURCE} non supportato`);
    const side = server ? "server" : "shared";
    const key = `${side}/${destination.join("/")}`;
    const source = [SOURCE, ...parts, filename].join("/");
    if (claimed.has(key)) throw new Error(`Collisione ${key}: ${claimed.get(key)} e ${source}`);
    const parent = folder(roots[side], destination.slice(0, -1));
    const name = destination.at(-1);
    if (name.startsWith("$")) throw new Error(`Nome Rojo riservato: ${name}`);
    if (Object.hasOwn(parent, name) && parent[name].$path) {
      throw new Error(`Collisione con il template: ${key}`);
    }
    const node = folder(parent, [name]);
    delete node.$className;
    node.$path = description.init ? [SOURCE, ...parts].join("/") : source;
    claimed.set(key, source);
  }

  function walk(parts, inheritedServer = false) {
    const directory = path.join(sourceDir, ...parts);
    const entries = fs.readdirSync(directory, { withFileTypes: true })
      .filter((entry) => !entry.name.startsWith("."))
      .sort((a, b) => a.name < b.name ? -1 : a.name > b.name ? 1 : 0);
    const initFiles = entries.filter((entry) => entry.isFile() && /^init(?:\.(?:server|client))?\.(?:lua|luau)$/i.test(entry.name));
    if (initFiles.length > 1) throw new Error(`Più file init in ${[SOURCE, ...parts].join("/")}`);
    const init = initFiles[0] ? describeFile(initFiles[0].name) : null;
    const serverDirectory = inheritedServer || (parts.length > 0 && isServerName(parts.at(-1))) || Boolean(init?.server);
    if (serverDirectory && !inheritedServer) ignored.add([SOURCE, ...parts].join("/"));
    if (init) {
      for (const entry of entries) {
        if (entry.name !== initFiles[0].name && !/\.meta\.json$/i.test(entry.name)) {
          ignored.add([SOURCE, ...parts, entry.name].join("/"));
        }
      }
    }

    for (const entry of entries) {
      if (entry.isSymbolicLink()) throw new Error(`Link simbolico non supportato: ${entry.name}`);
      if (entry.isDirectory()) {
        walk([...parts, entry.name], serverDirectory);
      } else if (entry.isFile()) {
        const description = describeFile(entry.name);
        if (description) {
          if (description.server && !serverDirectory) ignored.add([SOURCE, ...parts, entry.name].join("/"));
          addFile(parts, entry.name, description, serverDirectory || description.server);
        }
      }
    }

    const metadataPath = path.join(directory, "init.meta.json");
    if (fs.existsSync(metadataPath)) {
      const metadata = JSON.parse(fs.readFileSync(metadataPath, "utf8"));
      for (const side of ["shared", "server"]) {
        const virtual = targetParts(parts, side === "server");
        let node = roots[side];
        for (const part of virtual) node = node?.[part];
        if (!node) continue;
        if (metadata.className) node.$className = metadata.className;
        if (metadata.properties) node.$properties = { ...node.$properties, ...metadata.properties };
        if (metadata.ignoreUnknownInstances !== undefined) node.$ignoreUnknownInstances = metadata.ignoreUnknownInstances;
      }
    }
  }

  walk([]);
  project.globIgnorePaths = [...ignored].sort();
  return project;
}

function writeProject(rootDir) {
  const output = path.join(rootDir, OUTPUT);
  const content = `${JSON.stringify(generateProject(rootDir), null, 2)}\n`;
  if (fs.existsSync(output) && fs.readFileSync(output, "utf8") === content) return false;
  const temporary = `${output}.${process.pid}.tmp`;
  try {
    fs.writeFileSync(temporary, content, "utf8");
    fs.renameSync(temporary, output);
  } finally {
    if (fs.existsSync(temporary)) fs.unlinkSync(temporary);
  }
  return true;
}

function watchProject(rootDir, onResult = (changed) => {
  if (changed) console.log(`[Mapping] Aggiornato ${OUTPUT}`);
}, onError = (error) => console.error(`[Mapping] ${error.message}`)) {
  let timer;
  let closed = false;
  const rebuild = () => {
    if (closed) return;
    clearTimeout(timer);
    timer = setTimeout(() => {
      try { onResult(writeProject(rootDir)); } catch (error) { onError(error); }
    }, 150);
  };
  const watchers = [
    fs.watch(path.join(rootDir, "src"), { recursive: true }, rebuild),
    fs.watch(rootDir, (_, filename) => {
      if (!filename || filename.toString() === TEMPLATE) rebuild();
    }),
  ];
  for (const watcher of watchers) watcher.on("error", onError);
  return () => {
    closed = true;
    clearTimeout(timer);
    for (const watcher of watchers) watcher.close();
  };
}

function resolveRojo(rootDir) {
  if (process.env.ROJO_BIN) return process.env.ROJO_BIN;
  const rokitFile = path.join(rootDir, "rokit.toml");
  const version = fs.existsSync(rokitFile)
    ? fs.readFileSync(rokitFile, "utf8").match(/^rojo\s*=\s*"rojo-rbx\/rojo@([^"]+)"/m)?.[1] : null;
  if (version) {
    const executable = path.join(os.homedir(), ".rokit", "tool-storage", "rojo-rbx", "rojo", version, process.platform === "win32" ? "rojo.exe" : "rojo");
    if (fs.existsSync(executable)) return executable;
  }
  return "rojo";
}

function main() {
  const args = new Set(process.argv.slice(2));
  for (const arg of args) if (!["--watch", "--serve"].includes(arg)) throw new Error(`Argomento sconosciuto: ${arg}`);
  const rootDir = path.resolve(__dirname, "..");
  const watching = args.has("--watch") || args.has("--serve");
  const close = watching ? watchProject(rootDir) : () => {};
  try {
    console.log(writeProject(rootDir) ? `[Mapping] Generato ${OUTPUT}` : `[Mapping] ${OUTPUT} già aggiornato`);
  } catch (error) {
    close();
    throw error;
  }
  let rojo;
  function stop(code = 0) {
    close();
    if (rojo && !rojo.killed) rojo.kill();
    process.exitCode = code;
  }
  if (args.has("--serve")) {
    rojo = spawn(resolveRojo(rootDir), ["serve", OUTPUT], { cwd: rootDir, stdio: "inherit", windowsHide: true });
    rojo.on("error", (error) => { console.error(`[Rojo] ${error.message}`); stop(1); });
    rojo.on("exit", (code) => stop(code ?? 0));
  }
  if (watching) {
    console.log(`[Mapping] In ascolto su ${SOURCE}. Ctrl+C per terminare.`);
    process.once("SIGINT", () => stop());
    process.once("SIGTERM", () => stop());
  }
}

module.exports = { describeFile, generateProject, writeProject, watchProject, resolveRojo };

if (require.main === module) {
  try { main(); } catch (error) { console.error(`[Mapping] ${error.message}`); process.exitCode = 1; }
}
