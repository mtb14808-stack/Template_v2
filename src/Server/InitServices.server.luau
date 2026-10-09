local ServerScriptService = game:GetService("ServerScriptService")

local ServicesFolder = script.Parent
local DataServiceFolder = ServerScriptService:WaitForChild("PlayerData")

local startTime = os.clock()

local loadedServices = {}

local function safeRequire(moduleScript: ModuleScript)
	if moduleScript:FindFirstAncestor("Cmdr") or moduleScript.Name == "Cmdr" or moduleScript.Name == "CmdrService" then
		return
	end

	local success, loadedModule = pcall(require, moduleScript)

	if not success then
		warn("[ServerInit] Require error in [" .. moduleScript.Name .. "]: " .. tostring(loadedModule))
		return
	end

	if typeof(loadedModule) == "table" then
		table.insert(loadedServices, {
			Name = moduleScript.Name,
			Module = loadedModule,
		})
	end
end

for _, moduleScript in DataServiceFolder:GetDescendants() do
	if moduleScript:IsA("ModuleScript") then
		safeRequire(moduleScript)
	end
end

for _, moduleScript in ServicesFolder:GetDescendants() do
	if moduleScript:IsA("ModuleScript") then
		safeRequire(moduleScript)
	end
end

for _, serviceData in loadedServices do
	local module = serviceData.Module
	local initFn = module.Init or module.init

	if typeof(initFn) == "function" then
		task.spawn(function()
			local initSuccess, err = pcall(function()
				initFn(module)
			end)

			if not initSuccess then
				warn("[ServerInit] Init error in [" .. serviceData.Name .. "]: " .. tostring(err))
			end
		end)
	end
end

local duration = os.clock() - startTime
print(string.format("Server Loaded Successfully in %.3f seconds", duration))

loadedServices = nil
