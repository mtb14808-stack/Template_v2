local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PngIds = require(ReplicatedStorage.SourceCode.Core.Configs.AssetsId.PngIds)
local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)
local ScaledFrame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ScaledFrame)
local TextLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.TextLabel)

return function()
	return ScaledFrame({
		Size = UDim2.fromOffset(500, 150),
		TextLabel({
			Text = "Test",
			Prefix = PngIds.LightBulb,
			PrefixMult = 0.3,
			Thickness = 4,
			PrefixPadding = 20,
		}),
	})
end
