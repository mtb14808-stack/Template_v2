local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HudSource = require(ReplicatedStorage.SourceCode.Features.Hud.UI.Sources.HudSource)
local ScaledFrame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ScaledFrame)
local Spring = require(ReplicatedStorage.SourceCode.Core.Ui.Utils.Spring)

local OffScreenPosition = UDim2.fromScale(0.5, 1.2)
local InitialPosition = UDim2.fromScale(0.5, 0.98)

return function()
	local Position = Spring.HudSrping(HudSource.HudSource, InitialPosition, OffScreenPosition)

	return ScaledFrame({
		Position = Position,
		Size = UDim2.fromOffset(700, 150),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		Name = "BottomBar",
	})
end
