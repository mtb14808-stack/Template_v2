local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local networker = require(ReplicatedStorage.Packages.networker)
local Appearance = require(ReplicatedStorage.SourceCode.Core.Utilities.Appearance)

local CurrencyLearboard: Folder = ReplicatedStorage.Assets.Models.CurrencyLearboard
local PodiumTemplate = ReplicatedStorage.Assets.Templates.Leadrboard.PodiumTemplate
type Promise = typeof(Promise.new())

export type CurrentData = {
	[string]: buffer,
}

export type LeaderboardServerModule = {
	RefreshTime: number,
	TimeLeft: number,
	TopLength: number,
	CurrentData: CurrentData,
	ActiveCurrency: { string },
	Init: (self: LeaderboardServerModule) -> (),
	SetupData: (self: LeaderboardServerModule) -> (),
	UpdateData: (self: LeaderboardServerModule) -> Promise,
	SendDataToAll: (self: LeaderboardServerModule) -> (),
	SendDataToPlayer: (self: LeaderboardServerModule, player: Player) -> (),
}

local LeaderboardServer = {} :: LeaderboardServerModule
local PlayerDataCache: { [number]: { [string]: number } } = {}

LeaderboardServer.RefreshTime = 110
LeaderboardServer.TimeLeft = LeaderboardServer.RefreshTime
LeaderboardServer.TopLength = 70
LeaderboardServer.CurrentData = {} :: CurrentData
LeaderboardServer.ActiveCurrency = { "Cash" }
LeaderboardServer.Inited = false

local EventTag = "LeadearboardUpdate"

local function savePlayerData(plr: Player, currency: string): Promise
	return Promise.new(function(resolve, reject)
		local userId = plr.UserId
		if not userId then
			reject("Invalid UserId")
			return
		end

		local leaderstats = plr:FindFirstChild("leaderstats") :: Folder?
		local valueObject = (
			leaderstats and leaderstats:FindFirstChild(currency) or plr:FindFirstChild(currency)
		) :: IntValue?

		if not valueObject then
			resolve()
			warn("ERROR")
			return
		end

		local roundedValue = math.floor(valueObject.Value)

		if not PlayerDataCache[userId] then
			PlayerDataCache[userId] = {}
		end

		if PlayerDataCache[userId][currency] == roundedValue then
			resolve()
			return
		end

		local currencyDS = DataStoreService:GetOrderedDataStore(currency .. "Leaderboard")

		Promise.retry(function()
			return Promise.new(function(res, rej)
				local success, err = pcall(function()
					currencyDS:SetAsync(tostring(userId), roundedValue)
				end)

				if success then
					res()
				else
					rej(err)
				end
			end)
		end, 3)
			:andThen(function()
				if PlayerDataCache[userId] then
					PlayerDataCache[userId][currency] = roundedValue
				end
				resolve()
			end)
			:catch(function(err)
				reject("Failed to save DataStore for " .. plr.Name .. " (" .. currency .. "): " .. tostring(err))
			end)
	end)
end

local function SaveActivePlayersData(): Promise
	local promises = {}

	for _, plr in Players:GetPlayers() do
		for _, currency in LeaderboardServer.ActiveCurrency do
			table.insert(promises, savePlayerData(plr, currency))
		end
	end

	return Promise.allSettled(promises)
end

function LeaderboardServer:Init()
	self.LeadrboardEvent = networker.server.new(EventTag, self)
	self:SetupData()

	task.spawn(function()
		if #Players:GetPlayers() == 0 then
			Players.PlayerAdded:Wait()
		end
		task.wait(2)
		self:UpdateData():andThen(function()
			self:SendDataToAll()
			LeaderboardServer.Inited = true
		end)
	end)

	task.spawn(function()
		while true do
			task.wait(1)
			self.TimeLeft -= 1

			if self.TimeLeft <= 0 then
				self:UpdateData():andThen(function()
					self:SendDataToAll()
				end)
				self.TimeLeft = self.RefreshTime
			end
		end
	end)

	Players.PlayerAdded:Connect(function(plr)
		self:SendDataToPlayer(plr)
	end)

	Players.PlayerRemoving:Connect(function(plr)
		PlayerDataCache[plr.UserId] = nil
	end)
end

function LeaderboardServer:SetupData()
	for _, Currency in LeaderboardServer.ActiveCurrency do
		LeaderboardServer.CurrentData[Currency] = buffer.create(0)

		local CurrencyFolder = CurrencyLearboard:WaitForChild(Currency .. "Podium", 5) :: Folder?
		if not CurrencyFolder then
			CurrencyFolder = Instance.new("Folder")
			CurrencyFolder.Name = Currency .. "Podium"
			CurrencyFolder.Parent = CurrencyLearboard

			local Podium = PodiumTemplate:Clone()
			Podium.Name = "Podium"
			Podium.Parent = CurrencyFolder
		end
	end
end

function LeaderboardServer:UpdateData(): Promise
	if #Players:GetPlayers() == 0 then
		return Promise.resolve()
	end

	return SaveActivePlayersData():andThen(function()
		local promises = {}

		for _, Currency in LeaderboardServer.ActiveCurrency do
			local currencyPromise = Promise.new(function(resolve, reject)
				local CurrencyDS = DataStoreService:GetOrderedDataStore(Currency .. "Leaderboard")

				Promise.retry(function()
					return Promise.new(function(res, rej)
						local success, pages = pcall(function()
							return CurrencyDS:GetSortedAsync(false, LeaderboardServer.TopLength)
						end)

						if not success or not pages then
							rej(pages)
							return
						end

						local pageSuccess, pageData = pcall(function()
							return pages:GetCurrentPage()
						end)

						if pageSuccess and pageData then
							res(pageData)
						else
							rej(pageData)
						end
					end)
				end, 3)
					:andThen(function(Result)
						local CurrencyFolder = CurrencyLearboard:FindFirstChild(Currency .. "Podium") :: Folder?
						local Podium = CurrencyFolder and CurrencyFolder:FindFirstChild("Podium") :: Model?

						local TotalRecords = #Result

						if TotalRecords == 0 then
							LeaderboardServer.CurrentData[Currency] = buffer.create(0)
							resolve()
							return
						end

						local Buf = buffer.create(TotalRecords * 16)
						local appearancePromises = {}

						for Rank, data in Result do
							local TargetUserId = tonumber(data.key) or 0
							local TargetValue = tonumber(data.value) or 0

							if Rank == 1 and Podium then
								table.insert(
									appearancePromises,
									Appearance.applyCharacterAppearance(TargetUserId, Podium)
								)
							end

							local Offset = (Rank - 1) * 16
							buffer.writef64(Buf, Offset, TargetUserId)
							buffer.writef64(Buf, Offset + 8, TargetValue)
						end

						LeaderboardServer.CurrentData[Currency] = Buf

						if #appearancePromises > 0 then
							Promise.allSettled(appearancePromises):andThen(function()
								resolve()
							end)
						else
							resolve()
						end
					end)
					:catch(function(err)
						warn("Failed to retrieve Leaderboard from DataStore: " .. tostring(err))
						reject(err)
					end)
			end)

			table.insert(promises, currencyPromise)
		end

		return Promise.allSettled(promises)
	end)
end

function LeaderboardServer:SendDataToAll()
	self.LeadrboardEvent:fireAll("UpdateLeaderBoardData", self.CurrentData)
end

function LeaderboardServer:SendDataToPlayer(player: Player)
	self.LeadrboardEvent:fire(player, "UpdateLeaderBoardData", self.CurrentData)
end

return LeaderboardServer
