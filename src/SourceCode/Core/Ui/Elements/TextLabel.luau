--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local TextPrefix = require(script.Parent.TextPrefix)
local TextSizing = require(script.Parent.Parent.Utils.TextSizing)

local create = Vide.create

export type Props = {
	Prefix: TextPrefix.Prefix?,
	PrefixMult: (number | () -> number)?,
	PrefixPadding: (number | () -> number)?,
	Text: (string | () -> string)?,
	TextColor3: (Color3 | () -> Color3)?,
	TextSize: (number | () -> number)?,
	TextScaled: (boolean | () -> boolean)?,
	Font: (Enum.Font | () -> Enum.Font)?,
	FontFace: (Font | () -> Font)?,
	TextTransparency: (number | () -> number)?,
	TextStrokeColor3: (Color3 | () -> Color3)?,
	TextStrokeTransparency: (number | () -> number)?,
	Thickness: number?,
	TextDirection: (Enum.TextDirection | () -> Enum.TextDirection)?,
	TextTruncate: (Enum.TextTruncate | () -> Enum.TextTruncate)?,
	TextWrapped: (boolean | () -> boolean)?,
	TextXAlignment: (Enum.TextXAlignment | () -> Enum.TextXAlignment)?,
	TextYAlignment: (Enum.TextYAlignment | () -> Enum.TextYAlignment)?,
	RichText: (boolean | () -> boolean)?,
	MaxVisibleGraphemes: (number | () -> number)?,
	LineHeight: (number | () -> number)?,
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
	UseShadow: (boolean | () -> boolean)?,
	ShadowOffset: (UDim2 | () -> UDim2)?,
	ShadowColor3: (Color3 | () -> Color3)?,
	UseFrameContainer: (boolean | () -> boolean)?,
	Rotation: (number | () -> number)?,
	TextBounds: (Vector2 | () -> Vector2)?,

	[any]: any,
}

local function TextLabel(props: Props): Instance
	if props.Prefix ~= nil then
		return TextPrefix(props, false, TextLabel)
	end
	local useShadow = if typeof(props.UseShadow) == "function"
		then props.UseShadow()
		else (if props.UseShadow ~= nil then props.UseShadow else true)

	local rawUseFrameContainer = if typeof(props.UseFrameContainer) == "function"
		then props.UseFrameContainer()
		else props.UseFrameContainer

	local useFrameContainer = if rawUseFrameContainer ~= nil then rawUseFrameContainer else useShadow

	local frameChildren: { [any]: any } = {}
	local strokes: { Instance } = {}

	if typeof(props.Thickness) == "number" then
		table.insert(strokes, create("UIStroke")({
			Thickness = props.Thickness,
		}))
	end

	local function processChild(child: any)
		if typeof(child) == "Instance" and (child:IsA("UIStroke") or child:IsA("UIGradient")) then
			table.insert(strokes, child)
		else
			table.insert(frameChildren, child)
		end
	end

	for key, value in pairs(props) do
		if typeof(key) == "number" then
			processChild(value)
		end
	end

	if props.Children ~= nil then
		if typeof(props.Children) == "table" then
			for _, child in pairs(props.Children) do
				processChild(child)
			end
		else
			processChild(props.Children)
		end
	end

	local function getBaseZIndex(): number
		local z = props.ZIndex
		if type(z) == "function" then
			return z() :: number
		end
		return (z :: number) or 2
	end

	local shadowZIndex = function(): number
		return getBaseZIndex()
	end

	local mainZIndex = function(): number
		return getBaseZIndex() + 1
	end

	local shadowPosition = function(): UDim2
		local off = props.ShadowOffset
		if type(off) == "function" then
			off = off()
		end
		local offset: UDim2 = (off :: UDim2) or UDim2.fromOffset(0, 4)
		return UDim2.new(0.5 + offset.X.Scale, offset.X.Offset, 0.5 + offset.Y.Scale, offset.Y.Offset)
	end

	local shadowProps: { [any]: any }? = if useShadow
		then {
			Name = "ShadowLabel",
			Size = UDim2.fromScale(1, 1),
			Position = shadowPosition,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			ZIndex = shadowZIndex,

			Text = props.Text,
			TextColor3 = props.ShadowColor3 or Color3.new(0, 0, 0),
			TextSize = props.TextSize,
			TextScaled = false,
			TextSizing.Apply(props),
			Font = props.Font or Enum.Font.BuilderSansExtraBold,
			FontFace = props.FontFace,
			TextTransparency = props.TextTransparency,
			TextDirection = props.TextDirection,
			TextTruncate = props.TextTruncate,
			TextWrapped = props.TextWrapped,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			TextBounds = if props.TextBounds then props.TextBounds else nil,
			RichText = props.RichText,
			MaxVisibleGraphemes = props.MaxVisibleGraphemes,
			LineHeight = props.LineHeight,
		}
		else nil

	if not useFrameContainer then
		local directProps: { [any]: any } = {
			Name = props.Name or "TextLabel",
			Size = props.Size or UDim2.fromScale(1, 1),
			Position = props.Position or UDim2.fromScale(0.5, 0.5),
			AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
			BackgroundTransparency = props.BackgroundTransparency or 1,
			BackgroundColor3 = props.BackgroundColor3,
			BorderSizePixel = props.BorderSizePixel or 0,
			BorderColor3 = props.BorderColor3,
			ZIndex = if useShadow then mainZIndex else 3,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			AutomaticSize = props.AutomaticSize,
			SizeConstraint = props.SizeConstraint,
			Rotation = props.Rotation or 0,

			Text = props.Text,
			TextColor3 = props.TextColor3 or Color3.new(1, 1, 1),
			TextSize = props.TextSize,
			TextScaled = false,
			TextSizing.Apply(props),
			Font = props.Font or Enum.Font.BuilderSansExtraBold,
			FontFace = props.FontFace,
			TextTransparency = props.TextTransparency,
			TextStrokeColor3 = props.TextStrokeColor3,
			TextStrokeTransparency = props.TextStrokeTransparency,
			TextDirection = props.TextDirection,
			TextTruncate = props.TextTruncate,
			TextWrapped = props.TextWrapped,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			TextBounds = if props.TextBounds then props.TextBounds else nil,
			RichText = props.RichText,
			MaxVisibleGraphemes = props.MaxVisibleGraphemes,
			LineHeight = props.LineHeight,
		}

		for _, stroke in ipairs(strokes) do
			if shadowProps then
				table.insert(shadowProps, stroke:Clone())
			end
			table.insert(directProps, stroke)
		end

		if shadowProps then
			table.insert(directProps, create("TextLabel")(shadowProps))
		end

		for _, child in ipairs(frameChildren) do
			table.insert(directProps, child)
		end

		return create("TextLabel")(directProps)
	end

	local mainProps: { [any]: any } = {
		Name = "MainLabel",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = if useShadow then mainZIndex else 3,

		Text = props.Text,
		TextColor3 = props.TextColor3 or Color3.new(1, 1, 1),
		TextSize = props.TextSize,
		TextScaled = false,
		TextSizing.Apply(props),
		Font = props.Font or Enum.Font.BuilderSansExtraBold,
		FontFace = props.FontFace,
		TextTransparency = props.TextTransparency,
		TextStrokeColor3 = props.TextStrokeColor3,
		TextStrokeTransparency = props.TextStrokeTransparency,
		TextDirection = props.TextDirection,
		TextTruncate = props.TextTruncate,
		TextWrapped = props.TextWrapped,
		TextXAlignment = props.TextXAlignment,
		TextYAlignment = props.TextYAlignment,
		TextBounds = if props.TextBounds then props.TextBounds else nil,

		RichText = props.RichText,
		MaxVisibleGraphemes = props.MaxVisibleGraphemes,
		LineHeight = props.LineHeight,
	}

	for _, stroke in ipairs(strokes) do
		if shadowProps then
			table.insert(shadowProps, stroke:Clone())
		end
		table.insert(mainProps, stroke)
	end

	local frameProps: { [any]: any } = {
		Name = props.Name or "TextLabelFrame",
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = props.BackgroundTransparency or 1,
		BackgroundColor3 = props.BackgroundColor3,
		BorderSizePixel = props.BorderSizePixel or 0,
		BorderColor3 = props.BorderColor3,
		ZIndex = props.ZIndex,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		AutomaticSize = props.AutomaticSize,
		SizeConstraint = props.SizeConstraint,
		Rotation = props.Rotation or 0,
	}

	if shadowProps then
		table.insert(frameProps, create("TextLabel")(shadowProps))
	end
	table.insert(frameProps, create("TextLabel")(mainProps))

	for _, child in ipairs(frameChildren) do
		table.insert(frameProps, child)
	end

	return create("Frame")(frameProps)
end

return TextLabel
