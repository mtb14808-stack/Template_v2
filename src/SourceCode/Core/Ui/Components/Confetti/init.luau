local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConfettiComponent = require(script.ConfettiComponent)
local Vide = require(ReplicatedStorage.Packages.Vide)

local TriggerSource = Vide.source(0)
local TypeSource = Vide.source("")
local CountSource = Vide.source(0)

local function Fire(Type: "UpRain" | "BottomCorner", Count: number)
	CountSource(Count)
	if Type then
		TypeSource(Type)
	end
	TriggerSource(TriggerSource() + 1)
end

local function Component()
	return ConfettiComponent({
		Trigger = TriggerSource,
		Type = TypeSource,
		Count = CountSource,
		ZIndex = 10,
	})
end

return {
	Fire = Fire,
	Component = Component,
}
