# Mapping automatico Rojo

Il generatore usa JavaScript e le funzioni integrate di Node.js. Non richiede `npm install`.

Il progetto usa Rojo 7.7.1. Su Windows, Rojo 7.7.0 può non rilevare i cambiamenti dei file. Esegui `rokit install` dopo aver aggiornato il progetto per usare la versione indicata in `rokit.toml`.

Per avviare insieme il controllo automatico dei file e Rojo:

```powershell
npm run dev
```

Per aggiornare il mapping una volta:

```powershell
npm run build:rojo
```

Per aggiornare il mapping automaticamente usando un server Rojo già aperto:

```powershell
npm run watch:rojo
```

Il watcher reagisce a salvataggi, creazioni, rinomine ed eliminazioni dentro `src`. Rigenera `default.project.json` quando cambia la struttura. Le modifiche al contenuto degli script vengono sincronizzate direttamente da Rojo, senza riscrivere inutilmente il JSON.

In VS Code è disponibile il task `Rojo: mapping automatico`, configurato per partire all'apertura della cartella quando i task automatici sono consentiti. Il task `Rojo: mapping e server` avvia anche Rojo. Usa un solo server Rojo alla volta.

## Percorsi

| File sul disco | Percorso Roblox |
| --- | --- |
| `src/SourceCode/Features/Tutorial/TutorialClient.luau` | `ReplicatedStorage.SourceCode.Features.Tutorial.TutorialClient` |
| `src/SourceCode/Features/Tutorial/TutorialServer.luau` | `ServerScriptService.SourceCode.Features.Tutorial.TutorialServer` |
| `src/SourceCode/Core/Utilities/Nested/TestServer.luau` | `ServerScriptService.SourceCode.Core.ServerUtilities.Nested.TestServer` |
| `src/SourceCode/Core/ServerUtilities/NetworkSecurity.luau` | `ServerScriptService.SourceCode.Core.ServerUtilities.NetworkSecurity` |

I nomi `TutorialServer`, `ServerCache`, `server` e il suffisso `.server.luau` identificano codice server. Una cartella server rende privati anche i suoi discendenti. `Observers` non viene scambiato per un nome server.

Le utility condivise in `Core/Utilities` restano in `ReplicatedStorage`. Le utility server vengono collocate in `Core/ServerUtilities`, mantenendo le sottocartelle.

Un file `NomeServer.luau` rimane un `ModuleScript`: il nome determina dove viene mappato. Il suffisso `.server.luau` crea invece uno `Script`. I moduli `.luau` client e condivisi restano in `ReplicatedStorage`; gli script di avvio client continuano a essere in `src/StarterPlayerScripts`.

Le cartelle con `init.luau` mantengono il comportamento di modulo. I figli vengono mappati separatamente per evitare duplicati e tenere i file server fuori da `ReplicatedStorage`. Sono supportati anche `init.server.luau`, i metadata Rojo e gli asset normalmente usati dal progetto. I progetti Rojo annidati dentro `SourceCode` vengono rifiutati esplicitamente.

`PlayerData`, `ServerPackages` e `Packages` hanno mapping diretti nel template e non vengono scanditi né modificati dal generatore.

## Configurazione e test

Modifica `rojo.project.template.json` per cambiare servizi, proprietà o mapping statici. `default.project.json` viene generato: modificarlo direttamente non rende persistenti i cambiamenti.

```powershell
npm test
```

I test verificano routing, gerarchia, moduli con `init`, metadata, collisioni e aggiornamenti del watcher. Se Rojo è disponibile, verificano anche una build reale e l'assenza di moduli server nel ramo client.

Il sistema segue l'idea di [genRojoTree](https://github.com/leifstout/genRojoTree), adattata alla struttura di questo progetto.
