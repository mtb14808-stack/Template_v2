local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)
local ImageLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ImageLabel)
local TextLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.TextLabel)
local UICorner = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UICorner)
local UIStroke = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UIStroke)
local FormatNumber = require(ReplicatedStorage.SourceCode.Core.Ui.Utils.FormatNumber)

local RankColors = {
	[1] = Color3.new(0.996078, 0.752941, 0.019607),
	[2] = Color3.new(0.721568, 0.721568, 0.721568),
	[3] = Color3.new(0.956862, 0.443137, 0.101960),
	[4] = Color3.new(1, 1, 1),
}

local function read(value)
	if type(value) == "function" then
		return value()
	end
	return value
end

return function(Props)
	local getUserId = function()
		return read(Props.UserId) or 0
	end
	local getCurrency = function()
		return read(Props.Currency) or 0
	end
	local getRank = function()
		return read(Props.Rank) or 0
	end

	local getPlrName = function()
		local id = getUserId()
		local player = game.Players:GetPlayerByUserId(id)
		return player and player.Name or "Unknown"
	end

	return Frame({
		Name = function()
			return getPlrName() .. "_Slot"
		end,
		Size = UDim2.fromScale(1, 0.1),

		LayoutOrder = getRank,

		TextLabel({
			UseShadow = false,
			Name = "RankLabel",
			Text = function()
				return "#" .. tostring(getRank())
			end,
			Position = UDim2.fromScale(0.1, 0.65),
			Size = UDim2.fromScale(0.1, 1),
			UIStroke({ Thickness = 5 }),
			TextColor3 = function()
				return RankColors[getRank()] or RankColors[4]
			end,
		}),

		ImageLabel({
			Name = "AvatarImage",
			Size = UDim2.fromScale(0.13, 1),
			Position = UDim2.fromScale(0.238, 0.55),
			Image = function()
				return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(getUserId()) .. "&w=150&h=150"
			end,
			UICorner({ CornerRadius = UDim.new(1, 0) }),
		}),

		TextLabel({
			UseShadow = false,
			Name = "NameLabel",
			Text = getPlrName,
			Position = UDim2.fromScale(0.5, 0.62),
			Size = UDim2.fromScale(0.4, 0.7),
			UIStroke({ Thickness = 5 }),
		}),

		TextLabel({
			UseShadow = false,
			Name = "CurrencyLabel",
			Text = function()
				return FormatNumber.Abbreviate(getCurrency())
			end,
			Position = UDim2.fromScale(0.84, 0.62),
			Size = UDim2.fromScale(0.22, 0.7),
			UIStroke({ Thickness = 5 }),
		}),
	})
end
