local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

local hudSource = Vide.source(false)

local function HandleHudSource(State: boolean?)
	if State == nil then
		hudSource(not hudSource())
		return
	end
	hudSource(State)
end

return {
	HudSource = hudSource,
	HandleHud = HandleHudSource,
}
