local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local Vide = require(ReplicatedStorage.Packages.Vide)

local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)
local ImageLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ImageLabel)
local ScaledFrame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.ScaledFrame)
local TextLabel = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.TextLabel)
local UICorner = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UICorner)
local UIListLayout = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UIListLayout)
local UIStroke = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.UIStroke)
local ViewPortSizeSource = require(ReplicatedStorage.SourceCode.Core.Ui.Sources.ViewPortSizeSource)

local Spring = require(ReplicatedStorage.SourceCode.Core.Ui.Utils.Spring)
local Sound = require(ReplicatedStorage.SourceCode.Core.Utilities.Sound)

export type NotificationData = {
	Id: string?,
	Color: string,
	Name: string?,
	Text: string,
	Duration: number,
	Count: number?,
}

export type Props = {
	AdminNotificationSource: (({ NotificationData }) -> { NotificationData }) & (() -> { NotificationData }),
	Mounted: ((boolean) -> boolean) & (() -> boolean),
}

local Colors = {
	["Red"] = Color3.fromRGB(255, 0, 0),
	["Green"] = Color3.fromRGB(0, 255, 0),
	["Purple"] = Color3.fromRGB(128, 0, 128),
	["Yellow"] = Color3.fromRGB(255, 217, 0),
	["Orange"] = Color3.fromRGB(255, 140, 0),
	["Default"] = Color3.fromRGB(0, 123, 255),
}

local VERIFIED_ICON = ""
local BASE_POSITION_Y = 0.12
local FramLifeTime = 16

local function GetColorByName(Name: string?): Color3
	return Colors[Name or "Default"] or Colors.Default
end

return function(Props: Props)
	local CurrentUnmountThread: thread? = nil
	local localPlayer = Players.LocalPlayer

	Vide.effect(function()
		local CurrentTable = Props.AdminNotificationSource()

		if #CurrentTable == 0 then
			if not CurrentUnmountThread then
				CurrentUnmountThread = task.delay(FramLifeTime, function()
					Props.Mounted(false)
					CurrentUnmountThread = nil
				end)
			end
		else
			if CurrentUnmountThread then
				task.cancel(CurrentUnmountThread)
				CurrentUnmountThread = nil
			end
		end
	end)

	Vide.cleanup(function()
		if CurrentUnmountThread then
			task.cancel(CurrentUnmountThread)
			CurrentUnmountThread = nil
		end
	end)

	return Vide.show(Props.Mounted, function()
		return Frame({
			Name = "NotificationContainerLayout",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,

			Vide.values(Props.AdminNotificationSource, function(Data: NotificationData, GetIndex: () -> number)
				Sound.Play2DSound("AdminNotification")

				local ACTIVE = Vide.source(true)

				local DriveProps = Vide.derive(function()
					local Color = Data.Color
					local RawText = Data.Text
					local MessageContent = RawText:match(":%s*(.*)$") or RawText
					local Count = Data.Count or 1

					local FullMessage = " " .. MessageContent .. (Count > 1 and " (x" .. Count .. ")" or "")
					local NameText = (Data.Name or "Vrextiz") .. VERIFIED_ICON .. ":"

					local Duration = math.clamp(Data.Duration, 0, 16)
					local ViewPortSize = ViewPortSizeSource()
					local screenScale = math.clamp((ViewPortSize.Y / 1080) * 1.53, 0.65, 1.4)

					local BASE_TEXT_SIZE = math.round(32 * screenScale)
					local AVATAR_SIZE = math.round(48 * screenScale)
					local FRAME_HEIGHT = math.round(60 * screenScale)
					local MAX_WIDTH = math.round(ViewPortSize.X * 0.75)
					local MIN_WIDTH = math.round(200 * screenScale)
					local GAP = 8

					local font = Enum.Font.BuilderSansExtraBold
					local userSize = TextService:GetTextSize(NameText, BASE_TEXT_SIZE, font, Vector2.new(10000, 10000))
					local msgSize =
						TextService:GetTextSize(FullMessage, BASE_TEXT_SIZE, font, Vector2.new(10000, 10000))

					local userWidth = math.max(1, userSize.X)
					local msgWidth = math.max(1, msgSize.X)
					local totalRequiredWidth = AVATAR_SIZE + GAP + userWidth + GAP + msgWidth

					local scale = 1
					if totalRequiredWidth > MAX_WIDTH then
						scale = MAX_WIDTH / totalRequiredWidth
					end

					local actualTextSize = math.max(12, math.floor(BASE_TEXT_SIZE * scale))
					if scale < 1 then
						userWidth = TextService:GetTextSize(NameText, actualTextSize, font, Vector2.new(10000, 10000)).X
						msgWidth =
							TextService:GetTextSize(FullMessage, actualTextSize, font, Vector2.new(10000, 10000)).X
					end

					local finalWidth = math.clamp(AVATAR_SIZE + GAP + userWidth + GAP + msgWidth, MIN_WIDTH, MAX_WIDTH)
					local strokeThickness = math.max(1, 2.5 * (actualTextSize / 32))

					return {
						Color = Color,
						FullMessage = FullMessage,
						NameText = NameText,
						Duration = Duration,
						actualTextSize = actualTextSize,
						AVATAR_SIZE = AVATAR_SIZE,
						FRAME_HEIGHT = FRAME_HEIGHT,
						userWidth = userWidth,
						msgWidth = msgWidth,
						finalWidth = finalWidth,
						GAP = GAP,
						strokeThickness = strokeThickness,
					}
				end)

				local TargetYOffset = Vide.derive(function()
					local index = GetIndex() - 1
					return index * (DriveProps().FRAME_HEIGHT - 2)
				end)

				local AnimatedYOffset = Spring.TriggerSpring(function()
					return TargetYOffset()
				end, 0, 1, 0.25)

				local TransparencyAlpha = Spring.TriggerSpring(function()
					return ACTIVE() and 0 or 1
				end, 1, 0, 0.4)

				local delayThread = task.delay(DriveProps().Duration, function()
					ACTIVE(false)
				end)

				Vide.derive(function()
					local State = ACTIVE()
					local Alpha = TransparencyAlpha()

					if State == false and Alpha >= 0.95 then
						task.defer(function()
							local CurrentTable = table.clone(Props.AdminNotificationSource())
							local Index = table.find(CurrentTable, Data)

							if Index then
								table.remove(CurrentTable, Index)
								Props.AdminNotificationSource(CurrentTable)
							end
						end)
					end
				end)

				Vide.cleanup(function()
					if delayThread then
						task.cancel(delayThread)
					end
				end)

				local profileImage = ""
				if localPlayer then
					profileImage = string.format(
						"https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
						localPlayer.UserId
					)
				end

				return Frame({
					Name = "AdminNotiHolder",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0),
					Size = function()
						local drive = DriveProps()
						return UDim2.fromOffset(drive.finalWidth, drive.FRAME_HEIGHT)
					end,
					Position = function()
						return UDim2.new(0.5, 0, BASE_POSITION_Y, AnimatedYOffset())
					end,

					UIListLayout({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = function()
							return UDim.new(0, DriveProps().GAP)
						end,
					}),

					ImageLabel({
						Name = "ProfilePic",
						LayoutOrder = 1,
						Image = profileImage,
						BackgroundTransparency = 1,
						ImageTransparency = TransparencyAlpha,
						Size = function()
							local size = DriveProps().AVATAR_SIZE
							return UDim2.fromOffset(size, size)
						end,
						UICorner({ CornerRadius = UDim.new(1, 0) }),
					}),

					TextLabel({
						Name = "UsernameLabel",
						LayoutOrder = 2,
						BackgroundTransparency = 1,
						UseShadow = false,
						Font = Enum.Font.BuilderSansExtraBold,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
						Text = function()
							return DriveProps().NameText
						end,
						TextTransparency = TransparencyAlpha,
						TextStrokeTransparency = function()
							return 0.2 + (TransparencyAlpha() * 0.8)
						end,
						TextSize = function()
							return DriveProps().actualTextSize
						end,
						TextColor3 = function()
							return GetColorByName(DriveProps().Color)
						end,
						Size = function()
							return UDim2.new(0, DriveProps().userWidth, 1, 0)
						end,
						UIStroke({
							Thickness = function()
								return DriveProps().strokeThickness
							end,
							Transparency = TransparencyAlpha,
							Color = Color3.new(0, 0, 0),
						}),
					}),

					TextLabel({
						Name = "MessageLabel",
						LayoutOrder = 3,
						UseShadow = false,
						BackgroundTransparency = 1,
						Font = Enum.Font.BuilderSansExtraBold,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Center,
						Text = function()
							return DriveProps().FullMessage
						end,
						TextTransparency = TransparencyAlpha,
						TextStrokeTransparency = function()
							return 0.2 + (TransparencyAlpha() * 0.8)
						end,
						TextSize = function()
							return DriveProps().actualTextSize
						end,
						TextColor3 = Color3.new(1, 1, 1),
						Size = function()
							return UDim2.new(0, DriveProps().msgWidth, 1, 0)
						end,
						UIStroke({
							Thickness = function()
								return DriveProps().strokeThickness
							end,
							Transparency = TransparencyAlpha,
							Color = Color3.new(0, 0, 0),
						}),
					}),
				})
			end),
		})
	end)
end
