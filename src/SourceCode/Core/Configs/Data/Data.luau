local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataTemplate = require(script.Parent.DataTemplate)
local DataService = require(ReplicatedStorage.Packages.DataService)

return DataService({
	template = DataTemplate.template,
	useMock = true,
})
