local ServerScriptService = game:GetService("ServerScriptService")
local Cmdr = require(ServerScriptService.ServerPackages.Cmdr)

local CmdrExecutor = require(script.Parent:WaitForChild("CmdrExecutorServer"))

--INIT
CmdrExecutor.Init()

local ADMIN_IDS = {
	5169340626,
}

Cmdr.Registry:RegisterDefaultCommands()

Cmdr.Registry:RegisterHook("BeforeRun", function(context)
	if table.find(ADMIN_IDS, context.Executor.UserId) then
		return nil
	end

	return "Not Authorized."
end)
