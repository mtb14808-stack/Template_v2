local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

local MountSource = Vide.source(false)
local ActiveSource = Vide.source(false)

local TextSource = Vide.source("")
local TextColorSource = Vide.source(Color3.new(1, 1, 1))

local function SetTutorialText(Text: string)
	TextSource(Text)
end

local function SetTuroailState(State: boolean, Text: string)
	if State == true then
		MountSource(true)
	end
	ActiveSource(State)
	SetTutorialText(Text)
end

local function SetTextColor(Color: Color3)
	TextColorSource(Color)
end

return {

	--//functions
	SetTutorialText = SetTutorialText,
	SetTuroailState = SetTuroailState,
	SetTextColor = SetTextColor,
	--// Sources
	TextSource = TextSource,
	TextColorSource = TextColorSource,
	MountSource = MountSource,
	ActiveSource = ActiveSource,
}
