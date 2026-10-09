local ProductManager = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetworkSecurity = require(ServerScriptService.SourceCode.ServerUtilities.NetworkSecurity)
local networker = require(ReplicatedStorage.Packages.networker)
local Data = require(ReplicatedStorage.SourceCode.Core.Configs.Data.Data)
local ProductFunctions = require(script.ProductInfo)

local MAX_CACHE_SIZE = 100

function ProductManager.ProductPurchasedRequested(player, productId)
	if not ProductFunctions[productId] then
		warn("Product not found:", productId)
		ProductManager.networker:fire(player, "RemoveVignette")
		return
	end

	MarketplaceService:PromptProductPurchase(player, productId)
end

local function ProcessReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local playerData = Data.server.Service:waitForData(player)
	if not playerData then
		ProductManager.networker:fire(player, "RemoveVignette")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId
	if not ProductFunctions[productId] then
		warn("Product not found:", productId)
		ProductManager.networker:fire(player, "RemoveVignette")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local purchaseId = tostring(receiptInfo.PurchaseId)

	local currentCache = playerData.PurchaseIdCache() or {}
	if currentCache[purchaseId] then
		ProductManager.networker:fire(player, "RemoveVignette")
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local grantSuccess, grantErr = pcall(function()
		ProductFunctions[productId](receiptInfo, player, playerData)
	end)

	if not grantSuccess then
		warn("Failed to grant product:", player.UserId, purchaseId, grantErr)
		ProductManager.networker:fire(player, "RemoveVignette")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	playerData.PurchaseIdCache[purchaseId](true, false)

	local CurrentCache = playerData.PurchaseIdCache() or {}
	local keys = {}
	for key in CurrentCache do
		table.insert(keys, key)
	end

	if #keys > MAX_CACHE_SIZE then
		local oldestKey = keys[1]
		playerData.PurchaseIdCache[oldestKey](nil, false)
	end

	warn(playerData.PurchaseIdCache())

	ProductManager.networker:fire(player, "RemoveVignette")
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		return
	end

	if not isPurchased then
		ProductManager.networker:fire(player, "RemoveVignette")
	end
end)

function ProductManager.HandleProductRequest(self: ProductManager, player: Player, Id: number)
	if
		NetworkSecurity.CDSecurity(player, "HandleProductRequest", 1)
		or not NetworkSecurity.SecurityFilter(Id, "number")
	then
		ProductManager.networker:fire(player, "RemoveVignette")
		return
	end
	ProductManager.ProductPurchasedRequested(player, Id)
end

ProductManager.networker =
	networker.server.new("Product_Request", ProductManager, { ProductManager.HandleProductRequest })
export type ProductManager = typeof(ProductManager)

MarketplaceService.ProcessReceipt = ProcessReceipt

return ProductManager
