local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

local OrderedDataSource = Vide.source({})
local LeadEmptyErrorSource = Vide.source(false)

return {
	LeadEmptyErrorSource = LeadEmptyErrorSource,
	OrderedDataSource = OrderedDataSource,
}
