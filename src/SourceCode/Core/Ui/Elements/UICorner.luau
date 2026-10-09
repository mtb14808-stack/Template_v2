local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Props = {
	CornerRadius: (UDim | () -> UDim)?,
	[any]: any,
}

return function(props: Props)
	return Vide.create("UICorner")(props)
end
