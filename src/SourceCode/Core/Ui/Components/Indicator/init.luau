local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IndicatorComponent = require(script.IndicatorComponent)
local Vide = require(ReplicatedStorage.Packages.Vide)

local TriggerSource = Vide.source(false)
local Visible = Vide.source(false)
local DirectionSource = Vide.source("Top")
local ParentSource = Vide.source(nil)

local function TriggerIndicator(Direction: "Bottom" | "Top" | "Left" | "Right", Parent: GuiObject)
	TriggerSource(true)
	Visible(true)
	ParentSource(Parent)
	DirectionSource(Direction)
end

local function SetIndicatorVisibility(State: boolean)
	Visible(State)
end

local function SetParent(Parent: GuiObject)
	ParentSource(Parent)
end

local function DestroyIndicator()
	TriggerSource(false)
	Visible(false)
	ParentSource(nil)
	DirectionSource("Top")
end

local function ChangeDirection(Direction: string)
	DirectionSource(Direction)
end

local function Component()
	return IndicatorComponent({
		Trigger = TriggerSource,
		Visible = Visible,
		Parent = ParentSource,
		Direction = DirectionSource,
	})
end

return {
	Component = Component,
	TriggerIndicator = TriggerIndicator,
	SetIndicatorVisibility = SetIndicatorVisibility,
	ParentSource = ParentSource,
	DestroyIndicator = DestroyIndicator,
	ChangeDirection = ChangeDirection,
}
