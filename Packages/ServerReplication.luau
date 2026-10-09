--!strict
local RunService = game:GetService("RunService")

local PackageFolder = script.Parent._Index["detourious_loleris-replica@1.0.3"]["loleris-replica"]

-- =========================================================================
-- TIPI COMPLETI PER AUTOCOMPLETE LUAU (Server & Client)
-- =========================================================================

export type Connection = {
	Disconnect: (self: Connection) -> (),
}

export type ReplicaToken = {
	Name: string,
}

-- Oggetto Replica lato SERVER
export type ReplicaServer = {
	Tags: { [any]: any },
	Data: { [any]: any },
	Id: number,
	Token: string,
	Parent: ReplicaServer?,
	Children: { [ReplicaServer]: boolean? },
	BoundInstance: Instance?,
	OnServerEvent: {
		Connect: (self: any, listener: (player: Player, ...any) -> ()) -> Connection,
	},
	Maid: any,

	Set: (self: any, path: { string }, value: any) -> (),
	SetValues: (self: any, path: { string }, values: { [string]: any }) -> (),
	TableInsert: (self: any, path: { string }, value: any, index: number?) -> number,
	TableRemove: (self: any, path: { string }, index: number) -> any,
	Write: (self: any, function_name: string, ...any) -> ...any,
	FireClient: (self: any, player: Player, ...any) -> (),
	FireAllClients: (self: any, ...any) -> (),
	UFireClient: (self: any, player: Player, ...any) -> (),
	UFireAllClients: (self: any, ...any) -> (),
	SetParent: (self: any, new_parent: ReplicaServer) -> (),
	BindToInstance: (self: any, instance: Instance) -> (),
	Replicate: (self: any) -> (),
	DontReplicate: (self: any) -> (),
	Subscribe: (self: any, player: Player) -> (),
	Unsubscribe: (self: any, player: Player) -> (),
	Identify: (self: any) -> string,
	IsActive: (self: any) -> boolean,
	Destroy: (self: any) -> (),
}

-- Modulo SERVER (.Server)
export type ReplicaServerClass = {
	ReadyPlayers: { [Player]: boolean },
	NewReadyPlayer: {
		Connect: (self: any, listener: (player: Player) -> ()) -> Connection,
	},
	RemovingReadyPlayer: {
		Connect: (self: any, listener: (player: Player) -> ()) -> Connection,
	},
	Token: (name: string) -> ReplicaToken,
	New: (params: {
		Token: ReplicaToken,
		Tags: { [any]: any }?,
		Data: { [any]: any }?,
		WriteLib: ModuleScript?,
	}) -> ReplicaServer,
	FromId: (id: number) -> ReplicaServer?,
}

-- Oggetto Replica lato CLIENT (quello che ricevi dentro OnNew)
export type ReplicaClient = {
	Tags: { [any]: any },
	Data: { [any]: any },
	Id: number,
	Token: string,
	Parent: ReplicaClient?,
	Children: { [ReplicaClient]: boolean? },
	BoundInstance: Instance?,
	OnClientEvent: {
		Connect: (self: any, listener: (...any) -> ()) -> Connection,
	},
	Maid: any,

	OnSet: (self: any, path: { string }, listener: (new_value: any, old_value: any) -> ()) -> Connection,
	OnWrite: (self: any, function_name: string, listener: (...any) -> ()) -> Connection,
	OnChange: (
		self: any,
		listener: (action: "Set" | "SetValues" | "TableInsert" | "TableRemove", path: { any }, param1: any, param2: any?) -> ()
	) -> Connection,
	GetChild: (self: any, token: string) -> ReplicaClient?,
	FireServer: (self: any, ...any) -> (),
	UFireServer: (self: any, ...any) -> (),
	Identify: (self: any) -> string,
	IsActive: (self: any) -> boolean,
}

-- Modulo CLIENT (.Client)
export type ReplicaClientClass = {
	IsReady: boolean,
	OnLocalReady: {
		Connect: (self: any, listener: () -> ()) -> Connection,
	},
	RequestData: () -> (),
	OnNew: (token: string, listener: (replica: ReplicaClient) -> ()) -> Connection,
	FromId: (id: number) -> ReplicaClient?,
}

export type ReplicaPackage = {
	Server: ReplicaServerClass,
	Client: ReplicaClientClass,
}

-- =========================================================================
-- CARICAMENTO SICURO (Evita crash OnClientEvent / OnServerEvent)
-- =========================================================================

local ServerModule: any = nil
local ClientModule: any = nil

if RunService:IsServer() then
	ServerModule = require(PackageFolder.ReplicaServer)
else
	ClientModule = require(PackageFolder.ReplicaClient)
end

local Package = {
	Server = ServerModule,
	Client = ClientModule,
}

return Package :: ReplicaPackage
