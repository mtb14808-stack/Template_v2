local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Props = {
	CellPadding: (UDim2 | () -> UDim2)?,
	CellSize: (UDim2 | () -> UDim2)?,
	FillDirection: (Enum.FillDirection | () -> Enum.FillDirection)?,
	FillDirectionMaxCells: (number | () -> number)?,
	HorizontalAlignment: (Enum.HorizontalAlignment | () -> Enum.HorizontalAlignment)?,
	StartCorner: (Enum.StartCorner | () -> Enum.StartCorner)?,
	SortOrder: (Enum.SortOrder | () -> Enum.SortOrder)?,
	VerticalAlignment: (Enum.VerticalAlignment | () -> Enum.VerticalAlignment)?,
	[any]: any,
}

return function(props: Props)
	return Vide.create("UIGridLayout")(props)
end
