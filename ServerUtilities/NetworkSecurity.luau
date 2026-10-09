export type NetworkSecurity = {
	ClientRequestCDService: { [number]: { [string]: boolean } },
	InitializePlayer: (Player: Player) -> (),
	RemovePlayer: (Player: Player) -> (),
	GetPlayerCD: (Player: Player) -> { [string]: boolean },
	IsinCD: (Player: Player, Arg: string) -> boolean,
	SetCD: (Player: Player, Arg: string, Cooldown: number) -> (),
	CDSecurity: (Player: Player, Arg: string, Cooldown: number) -> boolean?,
	SecurityFilter: (Player: Player, Arg: string, Type: string) -> boolean,
}

local NetworkSecurity = {}

NetworkSecurity.ClientRequestCDService = {}

local MasterCDTable = NetworkSecurity.ClientRequestCDService

function NetworkSecurity.InitializePlayer(Player: Player)
	MasterCDTable[Player.UserId] = {}
end

function NetworkSecurity.RemovePlayer(Player: Player)
	MasterCDTable[Player.UserId] = nil
end

function NetworkSecurity.GetPlayerCD(Player: Player)
	local PlayerCD = MasterCDTable[Player.UserId]
	if not PlayerCD then
		warn("PlayerCD not found for " .. Player.Name .. ", re-initializing.")
		MasterCDTable[Player.UserId] = {}
		return MasterCDTable[Player.UserId]
	end
	return PlayerCD
end

function NetworkSecurity.IsinCD(Player: Player, Arg: string)
	local PlayerCD = NetworkSecurity.GetPlayerCD(Player)

	return PlayerCD[Arg] == true
end

function NetworkSecurity.SetCD(Player: Player, Arg: string, Cooldown: number)
	local userId = Player.UserId
	local PlayerCD = NetworkSecurity.GetPlayerCD(Player)

	PlayerCD[Arg] = true

	task.delay(Cooldown, function()
		if MasterCDTable[userId] then
			MasterCDTable[userId][Arg] = nil
		end
	end)
end

function NetworkSecurity.CDSecurity(Player: Player, Arg: string, CoolWown: number)
	if not Player then
		return
	end
	if NetworkSecurity.IsinCD(Player, Arg) then
		return true
	end
	NetworkSecurity.SetCD(Player, Arg, CoolWown)
end

function NetworkSecurity.SecurityFilter(Arg: any, Type: string)
	if typeof(Arg) ~= Type then
		return false
	end
	return true
end

return NetworkSecurity
