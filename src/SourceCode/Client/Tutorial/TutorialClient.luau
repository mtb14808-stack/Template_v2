local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TutorialSteps = require(script.Parent.TutorialSteps)
local networker = require(ReplicatedStorage.Packages.networker)
local TutorialSource = require(ReplicatedStorage.SourceCode.Client.Tutorial.UI.Sources.TutorialSource)
local Indicator = require(ReplicatedStorage.SourceCode.Core.Ui.Components.Indicator)
local TutorailEvents = "TutorailEvents"

local TutorialClient = {}

TutorialClient.Data = TutorialSteps

local function MarkIndex(Index: number)
	TutorialClient.TutorailEvents:fire("MarkTutorial", Index)
end

local function EndTutorial()
	TutorialClient.TutorailEvents:fire("EndTutorial")
	TutorialSource.SetTuroailState(false)
end

local function HandleSteps(Index: number)
	if Index == 1 then
		TutorialSource.SetTuroailState(true, TutorialClient.Data[Index].Text)
		Indicator.TriggerIndicator("Right", TutorialClient.Data[Index].TargetParent())
	elseif Index == 2 then
	end
end

function TutorialClient:Init()
	self.TutorailEvents = networker.client.new(TutorailEvents, self)
end

function TutorialClient:StartTutorial(Index: number)
	HandleSteps(Index)
end

return TutorialClient
