local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local LeaderboardSlot = require(ReplicatedStorage.SourceCode.Features.Leaderboard.UI.Components.LeaderboardSlot)
local LeaderboardSources = require(ReplicatedStorage.SourceCode.Features.Leaderboard.UI.Sources.LeaderboardSources)
local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)
local ScrollingFrame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ScrollingFrame)
local TextLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.TextLabel)
local UIListLayout = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UIListLayout)
local UIStroke = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UIStroke)

return function()
	return Vide.indexes(function()
		return LeaderboardSources.OrderedDataSource() or {}
	end, function(boardGetter, index)
		return Vide.create("SurfaceGui")({
			Name = function()
				local board = boardGetter()
				return board and ("Leaderboard_" .. tostring(board.Name or index)) or "Leaderboard"
			end,
			Face = Enum.NormalId.Left,
			LightInfluence = 0,
			MaxDistance = 250,
			ClipsDescendants = false,
			Adornee = function()
				local board = boardGetter()
				return board and board.Adornee or nil
			end,

			Frame({
				Name = "Container",
				Vide.show(LeaderboardSources.LeadEmptyErrorSource, function()
					return TextLabel({
						Name = "EmptyErrorText",
						Text = "😢 Empty Leaderboard 😢",
						Rotation = -15,
						UseShadow = false,
						Size = UDim2.fromScale(1, 0.15),
						UIStroke({ Thickness = 4.2 }),
					})
				end),

				ScrollingFrame({
					UIListLayout({ Padding = UDim.new(0.015, 0) }),
					ScrollBarImageTransparency = 1,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,

					Vide.values(function()
						local board = boardGetter()
						return (board and board.Players) or {}
					end, function(playerData)
						return LeaderboardSlot({
							UserId = function()
								return playerData.UserId or 0
							end,
							Currency = function()
								return playerData.Currency or 0
							end,
							Rank = function()
								return playerData.Rank or 0
							end,
						})
					end),
				}),
			}),
		})
	end)
end
