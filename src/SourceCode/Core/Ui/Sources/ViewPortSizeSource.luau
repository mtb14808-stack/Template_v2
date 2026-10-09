local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local CurrentCamera = game.Workspace.CurrentCamera

local ViewPortSize = Vide.source(CurrentCamera.ViewportSize)

CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	ViewPortSize(CurrentCamera.ViewportSize)
end)

return ViewPortSize
