local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientInit = require(ReplicatedStorage.SourceCode.ClientInit)

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

local Start = tick()

ClientInit.InitClient()

local Duration = tick() - Start

print(string.format("Client Loaded Successfully For %s in %.3f seconds", LocalPlayer.Name, Duration))
