--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local ViewPortSizeSource = require(ReplicatedStorage.SourceCode.Core.Ui.Sources.ViewPortSizeSource)

local BASE_RESOLUTION = Vector2.new(1920, 1080)

export type Props = {
	MinSize: Vector2?,
	Children: any?,
	[any]: any,
}

return function(Props: Props)
	local minSize = Props.MinSize or Vector2.zero

	local frameProps: { [any]: any } = {}

	for key, value in pairs(Props) do
		if key ~= "MinSize" and key ~= "Children" and typeof(key) ~= "number" then
			frameProps[key] = value
		end
	end

	if frameProps.Name == nil then
		frameProps.Name = "AutoScaledFrame"
	end
	if frameProps.Size == nil then
		frameProps.Size = UDim2.fromOffset(800, 500)
	end
	if frameProps.Position == nil then
		frameProps.Position = UDim2.fromScale(0.5, 0.5)
	end
	if frameProps.BackgroundTransparency == nil then
		frameProps.BackgroundTransparency = 1
	end
	if frameProps.BorderSizePixel == nil then
		frameProps.BorderSizePixel = 0
	end

	table.insert(
		frameProps,
		Vide.create("UIScale")({
			Scale = Vide.derive(function()
				local currentSize = ViewPortSizeSource()
				local currentX = math.max(minSize.X, currentSize.X)
				local currentY = math.max(minSize.Y, currentSize.Y)

				local scaleX = currentX / BASE_RESOLUTION.X
				local scaleY = currentY / BASE_RESOLUTION.Y

				return math.min(scaleX, scaleY)
			end),
		})
	)

	for key, value in pairs(Props) do
		if typeof(key) == "number" then
			table.insert(frameProps, value)
		end
	end

	if Props.Children ~= nil then
		table.insert(frameProps, Props.Children)
	end

	frameProps.Position = frameProps.Position or UDim2.fromScale(0.5, 0.5)
	frameProps.AnchorPoint = frameProps.AnchorPoint or Vector2.new(0.5, 0.5)
	frameProps.BackgroundTransparency = frameProps.BackgroundTransparency or 1
	return Vide.create("Frame")(frameProps)
end
