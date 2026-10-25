local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Spring = require(ReplicatedStorage.SourceCode.Core.Ui.Utils.Spring)
local HudSource = require(ReplicatedStorage.SourceCode.Features.Hud.UI.Sources.HudSource)
local ScaledFrame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ScaledFrame)

local InitialPosition = UDim2.fromScale(0.98, 0.5)
local OffScreenPosition = UDim2.fromScale(1.2, 0.5)

return function()
	local Position = Spring.HudSrping(HudSource.HudSource, InitialPosition, OffScreenPosition)
	return ScaledFrame({

		Position = Position,
		Size = UDim2.fromOffset(150, 900),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Name = "RightBar",
	})
end
