export type StateModule = {
	PlayersStates: { [number]: { [string]: any } },
	InitializePlayer: (player: Player) -> (),
	RemovePlayer: (player: Player) -> (),
	GetStates: (player: Player) -> { [string]: any }?,
	Add: (player: Player, stateName: string, stateValue: any) -> (),
	GetState: (player: Player, stateName: string) -> any,
	Remove: (player: Player, stateName: string) -> (),
	HasState: (player: Player, stateName: string) -> boolean,
	Toggle: (player: Player, stateName: string) -> boolean?,
	ClearStates: (player: Player) -> (),
	GetAllStates: (player: Player) -> { [string]: any },
	Increment: (player: Player, stateName: string, amount: number) -> number?,
}

local State = {}
State.PlayersStates = {}

function State.InitializePlayer(player: Player)
	State.PlayersStates[player.UserId] = {}
end

function State.RemovePlayer(player: Player)
	State.PlayersStates[player.UserId] = nil
end

function State.GetStates(player: Player)
	local states = State.PlayersStates[player.UserId]

	if not states then
		warn("[" .. script.Name .. "] Player not found in PlayersStates")
		return nil
	end

	return states
end

function State.Add(player: Player, stateName: string, stateValue: any)
	local states = State.GetStates(player)
	if not states then
		return
	end
	states[stateName] = stateValue
end

function State.GetState(player: Player, stateName: string)
	local states = State.GetStates(player)
	if not states then
		return nil
	end
	return states[stateName]
end

function State.Remove(player: Player, stateName: string)
	local states = State.GetStates(player)
	if not states then
		return
	end
	states[stateName] = nil
end

function State.HasState(player: Player, stateName: string)
	local states = State.GetStates(player)
	if not states then
		return false
	end
	return states[stateName] ~= nil
end

function State.Toggle(player: Player, stateName: string)
	local states = State.GetStates(player)
	if not states then
		return nil
	end
	states[stateName] = not states[stateName]
	return states[stateName]
end

function State.ClearStates(player: Player)
	local states = State.GetStates(player)
	if not states then
		return
	end

	table.clear(states)
end

function State.GetAllStates(player: Player)
	local states = State.GetStates(player)
	if not states then
		return {}
	end

	local copy = {}
	for k, v in pairs(states) do
		copy[k] = v
	end
	return copy
end

function State.Increment(player: Player, stateName: string, amount: number)
	local states = State.GetStates(player)
	if not states then
		return nil
	end

	local current = states[stateName] or 0
	states[stateName] = current + amount
	return states[stateName]
end

return State
