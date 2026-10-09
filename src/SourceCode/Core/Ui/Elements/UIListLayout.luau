local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Props = {
	HorizontalAlignment: (Enum.HorizontalAlignment | () -> Enum.HorizontalAlignment)?,
	VerticalAlignment: (Enum.VerticalAlignment | () -> Enum.VerticalAlignment)?,
	SortOrder: (Enum.SortOrder | () -> Enum.SortOrder)?,
	FillDirection: (Enum.FillDirection | () -> Enum.FillDirection)?,
	Padding: (UDim | () -> UDim)?,
	Wraps: (boolean | () -> boolean)?,
	HorizontalFlex: (Enum.UIFlexAlignment | () -> Enum.UIFlexAlignment)?,
	VerticalFlex: (Enum.UIFlexAlignment | () -> Enum.UIFlexAlignment)?,
	ItemLineAlignment: (Enum.ItemLineAlignment | () -> Enum.ItemLineAlignment)?,
	[any]: any,
}

return function(props: Props)
	return Vide.create("UIListLayout")(props)
end
