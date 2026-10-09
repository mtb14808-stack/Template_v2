local MessagingService = game:GetService("MessagingService")
local GLOBAL_CHANNEL = "CmdrGlobalCommands"

local MAX_RETRIES = 5
local RETRY_DELAY = 1

return function(context, messaggio, Duration, Color)
	local Data = {
		Name = "GlobalMessage",
		Args = { messaggio, Duration, Color },
	}

	task.spawn(function()
		local attempts = 0
		local sent = false

		while attempts < MAX_RETRIES and not sent do
			attempts += 1
			local success, err = pcall(function()
				MessagingService:PublishAsync(GLOBAL_CHANNEL, Data)
			end)
			if success then
				sent = true
			else
				warn("Failed: " .. attempts .. "/" .. MAX_RETRIES .. " Failed: " .. tostring(err))
				if attempts < MAX_RETRIES then
					task.wait(RETRY_DELAY * attempts)
				end
			end
		end

		if not sent then
			warn("Failed " .. MAX_RETRIES .. " Retries.")
		end
	end)

	return "Sending global signal..."
end
