--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local PngIds = require(ReplicatedStorage.SourceCode.Core.Configs.AssetsId.PngIds)
local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)
local ImageLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ImageLabel)
local UIGradient = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UIGradient)

export type ColorInput = Color3 | ColorSequence

export type Args = {
	IsMounted: () -> boolean,
	State: () -> boolean,
	UseRotation: () -> boolean,
	Transparency: () -> number,
	Color: () -> ColorInput,
	RotationSpeed: () -> number,
}

return function(Args: Args)
	return Frame({
		Name = "VignetteContainer",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 50,

		Visible = function()
			return Args.IsMounted()
		end,
		Vide.show(Args.IsMounted, function()
			local rotationSource = Vide.source(0)
			local internalColor3 = Vide.source(Color3.new(0, 0, 0))

			local transparencyGoal = Vide.derive(function()
				return if Args.State() then Args.Transparency() else 1
			end)

			local springTransparency, Setting = Vide.spring(transparencyGoal, 0.45, 1)

			Setting({ position = 1 })

			Vide.effect(function()
				local currentColor = Args.Color()
				if typeof(currentColor) == "Color3" then
					internalColor3(currentColor)
				end
			end)

			local springColor = Vide.spring(internalColor3, 0.4, 1)

			local gradientColor = Vide.derive(function(): ColorSequence
				local rawColor = Args.Color()
				if typeof(rawColor) == "ColorSequence" then
					return rawColor
				else
					return ColorSequence.new(springColor())
				end
			end)

			Vide.effect(function()
				if not Args.UseRotation() then
					rotationSource(0)
					return
				end

				local conn = RunService.Heartbeat:Connect(function(dt: number)
					if not Args.State() and springTransparency() >= 0.995 then
						return
					end
					rotationSource((rotationSource() + dt * 30 * Args.RotationSpeed()) % 360)
				end)

				Vide.cleanup(function()
					conn:Disconnect()
				end)
			end)

			return ImageLabel({
				Name = "Vignette",
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = PngIds.Vignette.Image,
				ImageTransparency = springTransparency,

				UIGradient({
					Rotation = rotationSource,
					Color = gradientColor,
					Transparency = function()
						local t = math.clamp(springTransparency(), 0, 1)
						return NumberSequence.new(t)
					end,
				}),
			})
		end),
	})
end
