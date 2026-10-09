local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Props = {
	ApplyStrokeMode: (Enum.ApplyStrokeMode | () -> Enum.ApplyStrokeMode)?,
	Color: (Color3 | () -> Color3)?,
	Enabled: (boolean | () -> boolean)?,
	LineJoinMode: (Enum.LineJoinMode | () -> Enum.LineJoinMode)?,
	Thickness: (number | () -> number)?,
	Transparency: (number | () -> number)?,
	[any]: any,
}

return function(props: Props)
	local strokeProps = table.clone(props)

	return Vide.create("UIStroke")(strokeProps)
end
