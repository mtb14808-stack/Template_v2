local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local NetworkSecurity = require(ServerScriptService.SourceCode.ServerUtilities.NetworkSecurity)
local networker = require(ReplicatedStorage.Packages.networker)
local TeleportToPlace = require(ServerScriptService.SourceCode.ServerUtilities.TeleportToPlace)

-- [Settings]

local EventTag = "AFKEVENT"
local Id = game.PlaceId

local AntiAFKService = {}

function AntiAFKService:Init()
	self.AfkEvent = networker.server.new(EventTag, self, {
		self.Rejoin,
	})
end

function AntiAFKService:Rejoin(plr: Player)
	if NetworkSecurity.CDSecurity(plr, EventTag, 2) then
		return
	end
	TeleportToPlace.Teleport({ PlaceId = Id, Plr = plr })
end

return AntiAFKService
