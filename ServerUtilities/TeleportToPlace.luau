local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Promise = require(ReplicatedStorage.Packages.Promise)

export type Data = {
	PlaceId: number,
	Plr: Player,
}

export type Teleport = {
	Teleport: (Data: Data) -> any,
}

local Teleport = {}

local function attemptTeleport(data: Data)
	return Promise.new(function(resolve, reject)
		local success, result = pcall(function()
			return TeleportService:TeleportAsync(data.PlaceId, { data.Plr })
		end)

		if success then
			resolve(result)
		else
			reject(result)
		end
	end)
end

function Teleport.Teleport(data: Data)
	return Promise.retry(function()
		return attemptTeleport(data)
	end, 3):timeout(10)
end

return Teleport
