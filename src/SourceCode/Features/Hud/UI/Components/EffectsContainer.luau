local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local AdminNotification = require(ReplicatedStorage.SourceCode.Core.Ui.Components.AdminNotification)
local Camera = require(ReplicatedStorage.SourceCode.Core.Ui.Components.Camera)
local Confetti = require(ReplicatedStorage.SourceCode.Core.Ui.Components.Confetti)
local Indicator = require(ReplicatedStorage.SourceCode.Core.Ui.Components.Indicator)
local Notification = require(ReplicatedStorage.SourceCode.Core.Ui.Components.Notification)
local Vignette = require(ReplicatedStorage.SourceCode.Core.Ui.Components.Vignette)

local create = Vide.create

return function()
	return create("Frame")({
		Name = "EffectsContainer",
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 10,

		--ComponentEffect
		Camera.Component(),
		Indicator.Component(),
		Confetti.Component(),
		Notification.Component(),
		AdminNotification.Component(),
		Vignette.Component(),
	})
end
