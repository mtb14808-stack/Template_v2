--!strict

export type ImageAsset = {
	Image: string,
	Size: UDim2?,
}

local PngIds: {
	Vignette: ImageAsset,
	Indicator: ImageAsset,
	TextDropShadow: ImageAsset,
	LightBulb: ImageAsset,
} = {
	Vignette = {
		Image = "rbxassetid://89169023626581",
	},
	Indicator = {
		Image = "rbxassetid://86108239740706",
		Size = UDim2.fromOffset(83, 99),
	},
	TextDropShadow = {
		Image = "rbxassetid://71648383791959",
	},
	LightBulb = {
		Image = "rbxassetid://139949900625962",
		Size = UDim2.fromOffset(299, 436),
	},
}

return PngIds
