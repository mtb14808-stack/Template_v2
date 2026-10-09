local GamePassManager = {}

local ServerScriptService = game:GetService("ServerScriptService")
local MarkePlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local networker = require(ReplicatedStorage.Packages.networker)
local NetworkSecurity = require(ServerScriptService.SourceCode.ServerUtilities.NetworkSecurity)
local Data = require(ReplicatedStorage.SourceCode.Core.Configs.Data.Data)
local GamePassInfo = require(script.PassesInfo)

function GamePassManager.PromptPurchase(player: Player, name: string)
	local playerData = Data.server[player]
	if not playerData then
		GamePassManager.networker:fire(player, "RemoveVignette")
		return
	end

	local PassId: string = GamePassInfo.GetGamePassId(name)
	if PassId == nil then
		warn("Invalid gamepass name:", name)
		GamePassManager.networker:fire(player, "RemoveVignette")
		return
	end

	local passDataWrapper = playerData.GamePasses[PassId]
	if not passDataWrapper then
		warn("Missing GamePass data for:", PassId)
		GamePassManager.networker:fire(player, "RemoveVignette")
		return
	end

	local passData = passDataWrapper() or { owned = false, awarded = false }
	local HasPass = passData.owned

	print(player.Name, "Request GamePass:", name, "Owned:", HasPass)

	if HasPass == false then
		local success, result = pcall(function()
			return MarkePlaceService:UserOwnsGamePassAsync(player.UserId, tonumber(PassId))
		end)

		if not success then
			warn("Error checking gamepass:", PassId, result)
			GamePassManager.networker:fire(player, "RemoveVignette")
			return
		end

		if result == true then
			passDataWrapper(function(current)
				local updated = current or { owned = false, awarded = false }
				updated.owned = true
				return updated
			end, false)
			GamePassManager.UpdateOwnerShipData(player)
			GamePassManager.networker:fire(player, "RemoveVignette")
			return
		end

		MarkePlaceService:PromptGamePassPurchase(player, tonumber(PassId))
	else
		GamePassManager.networker:fire(player, "RemoveVignette")
	end
end

function GamePassManager.OnPromptGamePassFinished(player: Player, gamepassid: number, wasPurChased: boolean)
	if not player then
		return
	end

	if wasPurChased == false then
		GamePassManager.networker:fire(player, "RemoveVignette")
		return
	end

	local gamepassidStr = tostring(gamepassid)

	local playerData = Data.server[player]
	if not playerData then
		GamePassManager.networker:fire(player, "RemoveVignette")
		return
	end

	local passDataWrapper = playerData.GamePasses[gamepassidStr]
	if not passDataWrapper then
		warn("Missing GamePass data for:", gamepassidStr)
		GamePassManager.networker:fire(player, "RemoveVignette")
		return
	end

	local AwardFunction = GamePassInfo.Function[gamepassidStr]

	passDataWrapper(function(current)
		local updated = current or { owned = false, awarded = false }
		updated.owned = true
		if AwardFunction then
			updated.awarded = true
		end
		return updated
	end, false)

	if AwardFunction then
		AwardFunction(player)
	else
		warn("No award function for gamepass:", gamepassidStr)
	end

	GamePassManager.networker:fire(player, "RemoveVignette")
end

function GamePassManager.UpdateOwnerShipData(player: Player)
	local playerData = Data.server.Service:waitForData(player)
	if not playerData then
		return
	end

	for PassId: string, AwardFunction in GamePassInfo.Function do
		local passDataWrapper = playerData.GamePasses[PassId]
		if not passDataWrapper then
			warn("Missing GamePass data for:", PassId)
			continue
		end

		local passData = passDataWrapper() or { owned = false, awarded = false }
		local HasPass = passData.owned

		if HasPass == false then
			local success, result = pcall(function()
				return MarkePlaceService:UserOwnsGamePassAsync(player.UserId, tonumber(PassId))
			end)

			if not success then
				warn("Error checking gamepass:", PassId, result)
				continue
			end

			if result == true then
				passDataWrapper(function(current)
					local updated = current or { owned = false, awarded = false }
					updated.owned = true
					updated.awarded = true
					return updated
				end, false)
				AwardFunction(player)
			end
		end
	end
end

MarkePlaceService.PromptGamePassPurchaseFinished:Connect(function(...)
	GamePassManager.OnPromptGamePassFinished(...)
end)

function GamePassManager.HandleBuyRequest(self: GamePassManager, player: Player, Name: string)
	if NetworkSecurity.CDSecurity(player, "Buy_Requested", 1) or not NetworkSecurity.SecurityFilter(Name, "string") then
		warn("INVALID ARGUMENTS")
		GamePassManager.networker:fire(player, "RemoveVignette")
		return
	end
	GamePassManager.PromptPurchase(player, Name)
end

GamePassManager.networker = networker.server.new("Buy_Requested", GamePassManager, { GamePassManager.HandleBuyRequest })
GamePassManager.ProductVignette = networker.server.new("VignetteProduct", GamePassManager)

export type GamePassManager = typeof(GamePassManager)

return GamePassManager
