local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local PngIds = require(ReplicatedStorage.SourceCode.Core.Configs.AssetsId.PngIds)
local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)
local ImageLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ImageLabel)
local Spring = require(ReplicatedStorage.SourceCode.Core.Ui.Utils.Spring)

export type Args = {
	Trigger: () -> boolean,
	Visible: () -> boolean,
	Parent: () -> GuiObject,
	Direction: () -> string,
}

local BounceDuration = 0.25
local BounceDistance = 35
local IndicatorRawSize = PngIds.Indicator.Size or UDim2.fromOffset(83, 99)
local IndicatorSize = UDim2.fromOffset(IndicatorRawSize.X.Offset * 1.5, IndicatorRawSize.Y.Offset * 1.5)
local Margin = 20

local function GetRotation(direction: string): number
	local rotations = {
		Bottom = 0,
		Down = 0,
		Top = 180,
		Up = 180,
		Left = 90,
		Right = -90,
	}
	return rotations[direction] or 0
end

local function GetBasePosition(direction: string, size: Vector2, margin: number): UDim2
	if direction == "Top" or direction == "Up" then
		return UDim2.new(0.5, 0, 0, -(size.Y / 2) - margin)
	elseif direction == "Bottom" or direction == "Down" then
		return UDim2.new(0.5, 0, 1, (size.Y / 2) + margin)
	elseif direction == "Left" then
		return UDim2.new(0, -(size.X / 2) - margin, 0.5, 0)
	elseif direction == "Right" then
		return UDim2.new(1, (size.X / 2) + margin, 0.5, 0)
	end
	return UDim2.new(0.5, 0, 0.5, 0)
end

local function GetBackwardOffset(direction: string, dist: number): UDim2
	if direction == "Top" or direction == "Up" then
		return UDim2.fromOffset(0, -dist)
	elseif direction == "Bottom" or direction == "Down" then
		return UDim2.fromOffset(0, dist)
	elseif direction == "Left" then
		return UDim2.fromOffset(-dist, 0)
	elseif direction == "Right" then
		return UDim2.fromOffset(dist, 0)
	end
	return UDim2.new()
end

return function(Args: Args)
	return Vide.show(Args.Trigger, function()
		local TargetOffset = Vide.source(0)
		local BounceSpring = Spring.NormalSpring(function()
			return TargetOffset()
		end, 0, 1, 0.5)

		local Thread = task.spawn(function()
			while true do
				if Args.Visible() == false then
					task.wait(0.15)
				else
					TargetOffset(1)
					task.wait(BounceDuration)
					if Args.Visible() == false then
						break
					end
					TargetOffset(0)
					task.wait(BounceDuration)
				end
			end
		end)

		Vide.cleanup(function()
			if Thread then
				task.cancel(Thread)
			end
		end)

		local DriveProps = Vide.derive(function()
			local dir = Args.Direction()
			local sizeVector = Vector2.new(IndicatorSize.X.Offset, IndicatorSize.Y.Offset)
			local basePos = GetBasePosition(dir, sizeVector, Margin)
			local offset = GetBackwardOffset(dir, BounceSpring() * BounceDistance)

			return {
				Parent = Args.Parent(),
				Visible = Args.Visible(),
				Rotation = GetRotation(dir),
				Position = basePos + offset,
			}
		end)

		return Frame({
			ZIndex = 100,
			Name = "IndicatorContainer",
			Parent = function()
				return DriveProps().Parent
			end,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = function()
				return DriveProps().Position
			end,
			Rotation = function()
				return DriveProps().Rotation
			end,
			Visible = function()
				return DriveProps().Visible
			end,
			Size = IndicatorSize,
			ImageLabel({
				Name = "Indicator",
				Image = PngIds.Indicator.Image,
				Size = UDim2.fromScale(1, 1),
			}),
		})
	end)
end
