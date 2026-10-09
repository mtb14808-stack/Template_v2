local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Props = {
	PaddingBottom: (UDim | () -> UDim)?,
	PaddingLeft: (UDim | () -> UDim)?,
	PaddingRight: (UDim | () -> UDim)?,
	PaddingTop: (UDim | () -> UDim)?,
	[any]: any,
}

return function(props: Props)
	return Vide.create("UIPadding")(props)
end
