local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Data = require(ReplicatedStorage.SourceCode.Core.Configs.Data.Data)

local function GetDataSource(SourceName: string, MockValue: any?)
	local initialValue = if MockValue ~= nil then MockValue else Data.client[SourceName]()
	local source = Vide.source(initialValue)

	if MockValue == nil then
		local disconnect = Data.client[SourceName].Changed(function(newValue: any)
			source(newValue)
		end)

		Vide.cleanup(function()
			if typeof(disconnect) == "function" then
				disconnect()
			elseif typeof(disconnect) == "table" and typeof(disconnect.Disconnect) == "function" then
				disconnect:Disconnect()
			elseif typeof(disconnect) == "RBXScriptConnection" then
				disconnect:Disconnect()
			end
		end)
	end

	return source
end

return GetDataSource
