local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.SourceCode.Core.Configs.Data.Data)
local DataTemplate = require(ReplicatedStorage.SourceCode.Core.Configs.Data.DataTemplate)

local DataManager = {}

local function GetData(plr: Player): DataTemplate.Template
	return Data.server[plr]
end

--/ Tutorial Functions

function DataManager.GetTutorialState(plr: Player): boolean?
	local playerData = GetData(plr)
	if not playerData then
		return nil
	end

	local tutorialData = playerData.Tutorial()
	if typeof(tutorialData) == "table" then
		return tutorialData.Completed
	end
	return false
end

function DataManager.SetTutorialState(plr: Player, state: boolean)
	local playerData = GetData(plr)
	if not playerData then
		return
	end

	playerData.Tutorial(function(current)
		local updated = current or { Steps = {}, Completed = false }
		updated.Completed = state
		return updated
	end, false)
end

function DataManager.MarkTutorial(plr: Player, index: number)
	local playerData = GetData(plr)
	if not playerData then
		return
	end

	playerData.Tutorial(function(current)
		local updated = current or { Steps = {}, Completed = false }
		updated.Steps = updated.Steps or {}
		updated.Steps[index] = true
		return updated
	end, false)
end

function DataManager.GetTutorialSteps(plr: Player): { [number]: boolean }?
	local playerData = GetData(plr)
	if not playerData then
		return nil
	end

	local tutorialData = playerData.Tutorial()
	if typeof(tutorialData) == "table" then
		return tutorialData.Steps
	end
	return {}
end

--/ Data Functions

function DataManager.GetPlayerData(player: Player)
	local playerData = GetData(player)
	if playerData then
		return playerData
	end

	warn("Data Access " .. player.Name .. " Falied.")
	return nil
end

--/ Cash Functions

function DataManager.AddCash(player: Player, amount: number)
	local playerData = GetData(player)
	if not playerData then
		return
	end

	playerData.Cash(function(currentCash: number)
		return (currentCash or 0) + amount
	end)
end

function DataManager.GetCash(player: Player): number
	local playerData = GetData(player)
	if not playerData then
		return 0
	end
	return playerData.Cash() or 0
end

return DataManager
