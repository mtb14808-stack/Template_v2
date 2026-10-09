local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Props = {
	Color: (ColorSequence | () -> ColorSequence)?,
	Enabled: (boolean | () -> boolean)?,
	Offset: (Vector2 | () -> Vector2)?,
	Rotation: (number | () -> number)?,
	Transparency: (NumberSequence | () -> NumberSequence)?,
	[any]: any,
}

return function(props: Props)
	return Vide.create("UIGradient")(props)
end
