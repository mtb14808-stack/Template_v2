local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.PlayerData.PlayerInit.DataManager)
local NetworkSecurity = require(ServerScriptService.SourceCode.Core.ServerUtilities.NetworkSecurity)
local networker = require(ReplicatedStorage.Packages.networker)
local TutorialServer = {}

local TutorailEvents = "TutorailEvents"

function TutorialServer:Init()
	self.networker = networker.server.new(TutorailEvents, self, {
		self.EndTutorial,
		self.MarkTutorial,
	})
end

function TutorialServer:SendData(player: Player)
	local Index = 1
	self.networker:fire(player, "StartTutorial", Index)
end

function TutorialServer:EndTutorial(plr: Player)
	if NetworkSecurity.CDSecurity(plr, "EndTutorial", 2) then
		warn("DEBOUNCE")
		return
	end
	print("TUTORIAL ENDED SEGNA CON FUNNLES")
	DataManager.SetTutorialState(plr, true)
end

function TutorialServer:MarkTutorial(plr: Player, Index: number)
	if NetworkSecurity.CDSecurity(plr, "MarkTutorial", 1) or not NetworkSecurity.SecurityFilter(Index, "number") then
		warn("INVALID TYPS OR DEBOUNCE")
		return
	end

	print("TUTORIAL INDEX  SEGNA CON FUNNLES")
	DataManager.MarkTutorialStep(plr, Index)
end

return TutorialServer
