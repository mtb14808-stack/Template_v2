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
	HoverImage: (string | () -> string)?,
	PressedImage: (string | () -> string)?,
	AutoButtonColor: (boolean | () -> boolean)?,
	Selected: (boolean | () -> boolean)?,
	Active: (boolean | () -> boolean)?,
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
	Activated: ((InputObject, number) -> ())?,
	MouseButton1Click: (() -> ())?,
	MouseButton1Down: ((number, number) -> ())?,
	MouseButton1Up: ((number, number) -> ())?,
	MouseEnter: ((number, number) -> ())?,
	MouseLeave: ((number, number) -> ())?,
	[any]: any,
}

return function(props: Props)
	local imageButtonProps = table.clone(props)

	imageButtonProps.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
	imageButtonProps.Position = props.Position or UDim2.fromScale(0.5, 0.5)
	imageButtonProps.Size = props.Size or UDim2.fromScale(1, 1)
	imageButtonProps.BackgroundTransparency = props.BackgroundTransparency or 1

	return create("ImageButton")(imageButtonProps)
end
