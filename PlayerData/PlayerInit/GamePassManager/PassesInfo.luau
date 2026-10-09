local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamePasses = require(ReplicatedStorage.SourceCode.Core.Configs.Monetization.GamePasses)
local PassesInfo = {}

PassesInfo.Names = GamePasses

function PassesInfo.GetGamePassId(name: string)
	return PassesInfo.Names[name]
end

PassesInfo.Function = {
	[PassesInfo.Names.X2Cash.Id] = function(player: Player)
		warn("BOUGHT")
	end,

	[PassesInfo.Names.X2Gems.Id] = function(player: Player)
		warn("BOUGHT")
	end,
}

return PassesInfo
