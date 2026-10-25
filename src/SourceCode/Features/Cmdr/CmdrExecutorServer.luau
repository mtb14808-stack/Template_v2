local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local networker = require(ReplicatedStorage.Packages.networker)
local Functions = require(script.Parent.CmdrFunctionsServer)

local GLOBAL_CHANNEL = "CmdrGlobalCommands"
local MAX_RETRIES = 5

local ServerCmdr_Executor = {}

function ServerCmdr_Executor.Init()
	ServerCmdr_Executor.networker = networker.server.new("GlobalAction", {}, {})

	task.spawn(function()
		if workspace.DistributedGameTime < 8 then
			task.wait(3)
		end
		local attempts = 0
		local subscribed = false

		while attempts < MAX_RETRIES and not subscribed do
			attempts += 1

			local success, err = pcall(function()
				MessagingService:SubscribeAsync(GLOBAL_CHANNEL, function(Message)
					local Data = Message.Data

					if typeof(Data) == "table" and Data.Name then
						local FunctionName = Data.Name
						local Arguments = Data.Args or {}
						local Function = Functions[FunctionName]
						ServerCmdr_Executor.networker:fireAll("ExecuteFunction", FunctionName, Arguments)

						if Function then
							Function(table.unpack(Arguments))
						end
					end
				end)
			end)

			if success then
				subscribed = true
			else
				warn("Subscribe Try: " .. attempts .. "/" .. MAX_RETRIES .. " Falied: " .. tostring(err))
				if attempts < MAX_RETRIES then
					task.wait(2 * attempts) -- backoff: 2s, 4s, 6s, 8s...
				end
			end
		end

		if not subscribed then
			warn("Subscribe Falied " .. MAX_RETRIES .. " Retry.")
		end
	end)
end

return ServerCmdr_Executor
