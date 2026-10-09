local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Products = require(ReplicatedStorage.SourceCode.Core.Configs.Monetization.Products)

return {
	[Products.Cash10k.Id] = function(Recepitinfo, Player, profile)
		warn("BOUGHT")
	end,

	[Products.Cash100k.Id] = function(Recepitinfo, Player, profile)
		warn("BOUGHT")
	end,
}
