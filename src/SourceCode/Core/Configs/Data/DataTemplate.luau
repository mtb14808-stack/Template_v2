local template = {
	--//Values
	Cash = 0,
	OfflineTime = 0,
	LastLeaveTime = 0,

	--//Tables
	GamePasses = {
		["1630549700"] = { owned = false, awarded = false },
		["1630795673"] = { owned = false, awarded = false },
	} :: { [string]: { owned: boolean, awarded: boolean } },
	Settings = {} :: { [string]: any },
	Tutorial = {
		Steps = {} :: { [number]: boolean },
		Completed = false,
	},
	PurchaseIdCache = {} :: { [string]: boolean },
}

export type Template = typeof(template)

return {
	template = template,
}
