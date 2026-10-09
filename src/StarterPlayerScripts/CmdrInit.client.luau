local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient"))

CmdrClient.SetActivationKeys({ Enum.KeyCode.F2, Enum.KeyCode.Tilde })
