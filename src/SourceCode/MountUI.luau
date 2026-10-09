local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local RootMenuUI = require(ReplicatedStorage.SourceCode.Client.App.RootMenuUI)
local TopBarplus = require(ReplicatedStorage.SourceCode.Client.Hud.TopBarplus)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local mount = Vide.mount

local function MountVideUI()
	return mount(function()
		return RootMenuUI()
	end, PlayerGui)
end

return function()
	MountVideUI()
	TopBarplus()
end
