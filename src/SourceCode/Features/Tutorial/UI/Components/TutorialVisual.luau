local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local TutorialSource = require(ReplicatedStorage.SourceCode.Features.Tutorial.UI.Sources.TutorialSource)
local PngIds = require(ReplicatedStorage.SourceCode.Core.Configs.AssetsId.PngIds)
local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)
local ImageLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ImageLabel)
local ScaledFrame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ScaledFrame)
local TextLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.TextLabel)
local UIStroke = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UIStroke)
local Spring = require(ReplicatedStorage.SourceCode.Core.Ui.Utils.Spring)

local RotationTarget = 30
local BASE_SCALE = 1.5
local TEXT_SIZE = 42
local LightBulbRawSize = PngIds.LightBulb.Size or UDim2.fromOffset(299, 436)
local LightBulbSize = UDim2.fromOffset(LightBulbRawSize.X.Offset / 6, LightBulbRawSize.Y.Offset / 6.5)

return function()
	return Vide.show(TutorialSource.MountSource, function()
		local SizeSpring, _, Ended = Spring.TriggerSpring(function()
			return TutorialSource.ActiveSource() == true and 1 or 0
		end, 1, 1, 0.2, 1)

		local ChangeTextSpring, ChangeTextControl = Spring.NormalSpring(1, 1, 0.2, 1)
		local Direction = Vide.source(-1)
		local DisplayedText = Vide.source(TutorialSource.TextSource())
		local RotationSpring = Spring.NormalSpring(function()
			return Direction() * RotationTarget
		end, Direction() * RotationTarget, 1.4, 0.7)

		local RotationThread = task.spawn(function()
			while true do
				Direction(Direction() * -1)
				task.wait(0.61)
			end
		end)

		Vide.cleanup(function()
			if RotationThread then
				task.cancel(RotationThread)
				RotationThread = nil
			end
		end)

		Vide.effect(function()
			local CurrentText = TutorialSource.TextSource()
			if CurrentText ~= DisplayedText() then
				ChangeTextControl({ position = 0 })
				DisplayedText(CurrentText)
			end
		end)

		Vide.effect(function()
			local ShouldUnMount = if Ended() == true and TutorialSource.ActiveSource() == false then true else false
			if ShouldUnMount then
				TutorialSource.MountSource(false)
			end
		end)

		local DriveProps = Vide.derive(function()
			local text = DisplayedText()
			local font = Enum.Font.BuilderSansExtraBold
			local textSizeBounds = TextService:GetTextSize(text, TEXT_SIZE, font, Vector2.new(10000, 10000))

			return {
				Text = text,
				TextColor = TutorialSource.TextColorSource(),
				font = font,
				TextWidth = math.max(1, textSizeBounds.X),
				TextHeight = math.max(1, textSizeBounds.Y),
			}
		end)

		return ScaledFrame({
			ZIndex = 10,
			Name = "Tutorial",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(1000, 70),
			Position = UDim2.fromScale(0.5, 0.22),
			Frame({
				Name = "Container",
				Frame({
					Name = "Tutorial_Container",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					AutomaticSize = Enum.AutomaticSize.XY,

					Vide.create("UIScale")({
						Scale = function()
							local s1 = SizeSpring()
							local s2 = ChangeTextSpring()

							return BASE_SCALE * s1 * s2
						end,
					}),

					Vide.create("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 10),
					}),

					Frame({
						Size = LightBulbSize,
						Name = "LighBulbContainer",
						BackgroundTransparency = 1,
						ImageLabel({
							Name = "LightBulb",
							LayoutOrder = 1,
							Image = PngIds.LightBulb.Image,
							Size = UDim2.fromScale(1, 1),
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Rotation = function()
								return RotationSpring()
							end,
						}),
					}),
					TextLabel({
						Name = "TextContent",
						LayoutOrder = 2,
						ZIndex = 10,
						BackgroundTransparency = 1,
						Font = function()
							return DriveProps().font
						end,
						UseShadow = false,
						TextWrapped = false,
						TextScaled = false,
						TextSize = TEXT_SIZE,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						Size = function()
							return UDim2.fromOffset(DriveProps().TextWidth, DriveProps().TextHeight)
						end,
						UIStroke({
							Thickness = 3,
						}),
						Text = function()
							return DriveProps().Text
						end,
						TextColor3 = function()
							return DriveProps().TextColor or Color3.new(1, 1, 1)
						end,
						ImageLabel({
							ZIndex = -1111,
							Name = "DropShadow",
							Image = PngIds.TextDropShadow.Image,
							Size = UDim2.new(1.5, 40, 1.8, 20),
							Position = UDim2.fromScale(0.5, 0.55),
							AnchorPoint = Vector2.new(0.5, 0.5),
							ImageTransparency = 0.54,
						}),
					}),
				}),
			}),
		})
	end)
end
