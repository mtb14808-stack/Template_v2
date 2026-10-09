local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

local create = Vide.create

export type Props = {
	CanvasSize: (UDim2 | () -> UDim2)?,
	AutomaticCanvasSize: (Enum.AutomaticSize | () -> Enum.AutomaticSize)?,
	CanvasPosition: (Vector2 | () -> Vector2)?,
	ScrollBarThickness: (number | () -> number)?,
	ScrollBarImageColor3: (Color3 | () -> Color3)?,
	ScrollBarImageTransparency: (number | () -> number)?,
	ScrollingDirection: (Enum.ScrollingDirection | () -> Enum.ScrollingDirection)?,
	ScrollingEnabled: (boolean | () -> boolean)?,
	ElasticBehavior: (Enum.ElasticBehavior | () -> Enum.ElasticBehavior)?,
	HorizontalScrollBarInset: (Enum.ScrollBarInset | () -> Enum.ScrollBarInset)?,
	VerticalScrollBarInset: (Enum.ScrollBarInset | () -> Enum.ScrollBarInset)?,
	VerticalScrollBarPosition: (Enum.VerticalScrollBarPosition | () -> Enum.VerticalScrollBarPosition)?,
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
	local scrollingProps = table.clone(props)

	scrollingProps.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
	scrollingProps.Position = props.Position or UDim2.fromScale(0.5, 0.5)
	scrollingProps.Size = props.Size or UDim2.fromScale(1, 1)
	scrollingProps.BackgroundTransparency = props.BackgroundTransparency or 1

	return create("ScrollingFrame")(scrollingProps)
end
