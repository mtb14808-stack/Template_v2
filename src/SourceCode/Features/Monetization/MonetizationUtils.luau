local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamePasses = require(ReplicatedStorage.SourceCode.Core.Configs.Monetization.GamePasses)
local Products = require(ReplicatedStorage.SourceCode.Core.Configs.Monetization.Products)

local MonetizationUtils = {}

local function GetIdByName(Type: "Product" | "GamePass", Name: string): number?
	local Id = if Type == "Product" then Products[Name].Id else GamePasses[Name].Id
	if not Id then
		warn("Couldn't Find Id")
		return nil
	end
	return tonumber(Id)
end

function MonetizationUtils.GetProductorGamePassPrice(Type: "Product" | "GamePass", Name: string): number
	local id = GetIdByName(Type, Name)
	if not id then
		warn("ID not found for:", Type, Name)
		return -1
	end

	local infoType = if Type == "Product" then Enum.InfoType.Product else Enum.InfoType.GamePass

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfoAsync(id, infoType)
	end)

	if success and result then
		if result.PriceInRobux then
			return result.PriceInRobux
		else
			warn("Product  nil for ID:", id)
			return 0
		end
	else
		warn("Errore  GetProductInfoAsync for ID:", id, result)
		return -1
	end
end

return MonetizationUtils
