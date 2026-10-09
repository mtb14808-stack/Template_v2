local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local networker = require(ReplicatedStorage.Packages.networker)
local LeaderboardSources = require(ReplicatedStorage.SourceCode.Client.Leaderboard.UI.Sources.LeaderboardSources)
local Animation = require(ReplicatedStorage.SourceCode.Core.Utilities.Animation)
local FireWork = require(ReplicatedStorage.SourceCode.Core.Utilities.FireWork)

local LeadBoardTemplate = ReplicatedStorage.Assets.Templates.Leadrboard.LeaderboardTemplate
local CurrencyLearboard: Folder = ReplicatedStorage.Assets.Models.CurrencyLearboard
local Rank = ReplicatedStorage.Assets.Templates.Leadrboard.Rank

export type LeaderBoardData = {
	[string]: buffer,
}

export type DataType = {
	UserId: number,
	Currency: number,
	Rank: number,
}

export type BoardData = {
	Name: string,
	Adornee: BasePart?,
	Players: { DataType },
}

export type OrderedData = { BoardData }

local LeaderboardClient = {}

LeaderboardClient.LeaderBoardData = {} :: LeaderBoardData
LeaderboardClient.OrderedData = {} :: OrderedData

local EventTag = "LeadearboardUpdate"

function LeaderboardClient:Init()
	self.LeadrboardEvent = networker.client.new(EventTag, self)
end

function LeaderboardClient:UpdateLeaderBoardData(LeadData: LeaderBoardData)
	self.LeaderBoardData = LeadData
	self:UpdateLeaderBoardModel()
	self:ProcessOrderedData()
end

function LeaderboardClient:ProcessOrderedData()
	local newOrderedData: OrderedData = {}

	for currencyName, buf in self.LeaderBoardData do
		local bytes = buffer.len(buf)
		local totalRecords = math.floor(bytes / 16)
		local playersList: { DataType } = {}

		for i = 1, totalRecords do
			local offset = (i - 1) * 16
			local userId = buffer.readf64(buf, offset)
			local score = buffer.readf64(buf, offset + 8)

			table.insert(playersList, {
				UserId = userId,
				Currency = score,
				Rank = i,
			})
		end

		local leaderboardsFolder = Workspace:FindFirstChild("Leaderboards")
		local leaderboardModel = leaderboardsFolder and leaderboardsFolder:FindFirstChild(currencyName) :: Model?
		local mainPart = leaderboardModel and leaderboardModel:WaitForChild("MainPart", 5) :: BasePart?

		table.insert(newOrderedData, {
			Name = currencyName,
			Adornee = mainPart,
			Players = playersList,
		})
	end

	self.OrderedData = newOrderedData

	if LeaderboardSources and LeaderboardSources.OrderedDataSource then
		LeaderboardSources.OrderedDataSource(newOrderedData)
	end
end

local function CreateCurrencyLead(Name: string)
	local LeaderboardsFolder = Workspace:WaitForChild("Leaderboards", 10) :: Folder?
	if not LeaderboardsFolder then
		warn("Couldn't Find Leaderboards Folder")
		return nil
	end

	local ExistingBoard = LeaderboardsFolder:FindFirstChild(Name)
	if ExistingBoard then
		ExistingBoard:Destroy()
	end

	local Lead = LeadBoardTemplate:Clone()
	Lead.Name = Name
	Lead.Parent = LeaderboardsFolder

	local CFramePart = LeaderboardsFolder:WaitForChild(Name .. "_Pivot", 5) :: BasePart?
	if CFramePart then
		Lead:PivotTo(CFramePart.CFrame)
	end

	return Lead
end

function LeaderboardClient:UpdateLeaderBoardModel()
	local hasAnyData = false

	for CurrencyName: string, Buf in self.LeaderBoardData do
		local LeaderBoardModel = CreateCurrencyLead(CurrencyName)
		if not LeaderBoardModel then
			continue
		end

		local BufferLength = buffer.len(Buf)
		local TotalRecords = math.floor(BufferLength / 16)

		if TotalRecords > 0 then
			hasAnyData = true
		end
	end

	if LeaderboardSources and LeaderboardSources.LeadEmptyErrorSource then
		LeaderboardSources.LeadEmptyErrorSource(not hasAnyData)
	end

	self:SetPodiums()
	self:StartAnimations()
end

function LeaderboardClient:SetPodiums()
	local LeaderboardsFolder = Workspace:FindFirstChild("Leaderboards") :: Folder?
	if not LeaderboardsFolder then
		return
	end

	for CurrencyName: string, buf in self.LeaderBoardData do
		local LeaderBoardModel = LeaderboardsFolder:FindFirstChild(CurrencyName) :: Model?
		if not LeaderBoardModel then
			continue
		end

		local ExistingPodium = LeaderBoardModel:FindFirstChild("Podium")
		if ExistingPodium then
			ExistingPodium:Destroy()
		end

		local TemplateFolder = CurrencyLearboard:FindFirstChild(CurrencyName .. "Podium")
		if not TemplateFolder then
			continue
		end

		local RawPodium = TemplateFolder:FindFirstChild("Podium")
		if not RawPodium then
			continue
		end

		local Podium: Model = RawPodium:Clone()
		Podium.Name = "Podium"

		local Head = Podium:FindFirstChild("Head")
		local PodiumRankDisplay = Rank:Clone()
		if Head then
			PodiumRankDisplay.Parent = Head
		end

		if buffer.len(buf) >= 16 then
			local TargetUserId = buffer.readf64(buf, 0)

			task.spawn(function()
				local PlrName = "Unknown"
				local ActivePlayer = Players:GetPlayerByUserId(TargetUserId)

				if ActivePlayer then
					PlrName = ActivePlayer.Name
				else
					local Success, Result = pcall(function()
						return Players:GetNameFromUserIdAsync(TargetUserId)
					end)
					if Success and Result then
						PlrName = Result
					end
				end

				local RankText = PodiumRankDisplay:FindFirstChildOfClass("TextLabel", true) :: TextLabel?
				if RankText then
					RankText.Text = "#1  " .. PlrName
				end
			end)
		end

		local PodiumCFrame = LeaderBoardModel:FindFirstChild("PodiumCFrame") :: BasePart?
		if PodiumCFrame and Podium.PrimaryPart then
			Podium:PivotTo(PodiumCFrame.CFrame)
		end

		Podium.Parent = LeaderBoardModel
	end
end

function LeaderboardClient:StartAnimations()
	local LeaderboardsFolder = Workspace:FindFirstChild("Leaderboards")
	if not LeaderboardsFolder then
		return
	end

	local Count = 0
	for _, LeadrBoardModel in LeaderboardsFolder:GetChildren() do
		if not LeadrBoardModel:IsA("Model") then
			continue
		end

		Count += 1
		local Podium = LeadrBoardModel:FindFirstChild("Podium")
		if Podium then
			local Track = Animation.Play("PoduimDance_" .. Count, Podium)
			if Track then
				Track.Looped = true
			end
		end
	end
end

return LeaderboardClient
