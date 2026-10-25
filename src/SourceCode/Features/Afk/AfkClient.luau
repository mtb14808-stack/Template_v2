local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local networker = require(ReplicatedStorage.Packages.networker)

local AFK_TIME = 18.3 * 60
local CHECK_INTERVAL = 2
local EventTag = "AFKEVENT"

local lastActivity = os.clock()
local Teleported = false

local AfkController = {}

local function markActive() lastActivity = os.clock() end

function AfkController:Init()
	self.AfkEvent = networker.client.new(EventTag, self)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		markActive()
	end)

	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Gamepad1 then markActive() end
	end)

	UserInputService.TouchMoved:Connect(function(touch, gameProcessed) markActive() end)

	task.spawn(function()
		while not Teleported do
			task.wait(CHECK_INTERVAL)

			if os.clock() - lastActivity >= AFK_TIME then
				warn("TELEPORT - Player is AFK")
				Teleported = true
				self.AfkEvent:fire("Rejoin")
				break
			end
		end
	end)
end

return AfkController
