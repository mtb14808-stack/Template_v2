local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrClientFunctions = require(script.Parent.CmdrClientFunctions)
local networker = require(ReplicatedStorage.Packages.networker)

local CmdrClient = {}

function CmdrClient:Init()
	self.networker = networker.client.new("GlobalAction", self)
end

function CmdrClient:ExecuteFunction(FunctionName: string, Args)
	local TargetFunction = CmdrClientFunctions[FunctionName]

	if not TargetFunction then
		warn("No function Found For Global Action", FunctionName)
		return
	end

	TargetFunction(table.unpack(Args))
end

return CmdrClient
