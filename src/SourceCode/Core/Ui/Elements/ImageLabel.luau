local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

local create = Vide.create

export type Props = {
	Image: (string | () -> string)?,
	ImageColor3: (Color3 | () -> Color3)?,
	ImageTransparency: (number | () -> number)?,
	ImageRectOffset: (Vector2 | () -> Vector2)?,
	ImageRectSize: (Vector2 | () -> Vector2)?,
	ScaleType: (Enum.ScaleType | () -> Enum.ScaleType)?,
	SliceCenter: (Rect | () -> Rect)?,
	SliceScale: (number | () -> number)?,
	TileSize: (UDim2 | () -> UDim2)?,
	ResampleMode: (Enum.ResamplerMode | () -> Enum.ResamplerMode)?,
	Size: (UDim2 | () -> UDim2)?,
	Position: (UDim2 | () -> UDim2)?,
	AnchorPoint: (Vector2 | () -> Vector2)?,
	BackgroundTransparency: (number | () -> number)?,
	BackgroundColor3: (Color3 | () -> Color3)?,
	BorderSizePixel: (number | () -> number)?,
	BorderColor3: (Color3 | () -> Color3)?,
	ZIndex: (number | () -> number)?,
	LayoutOrder: (number | () -> number)?,
	Visible: (boolean | () -> boolean)?,
	AutomaticSize: (Enum.AutomaticSize | () -> Enum.AutomaticSize)?,
	SizeConstraint: (Enum.SizeConstraint | () -> Enum.SizeConstraint)?,
	[any]: any,
}

return function(props: Props)
	local imageProps = table.clone(props)

	imageProps.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
	imageProps.Position = props.Position or UDim2.fromScale(0.5, 0.5)
	imageProps.Size = props.Size or UDim2.fromScale(1, 1)
	imageProps.BackgroundTransparency = props.BackgroundTransparency or 1

	return create("ImageLabel")(imageProps)
end
