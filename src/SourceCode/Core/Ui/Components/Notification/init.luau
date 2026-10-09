local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationComponent = require(script.NotificationComponent)
local Vide = require(ReplicatedStorage.Packages.Vide)
local TutorialSource = require(ReplicatedStorage.SourceCode.Client.Tutorial.UI.Sources.TutorialSource)

export type NotificationInput = {
	Text: string,
	Duration: number,
	Type: string,
}

local NotificationsSource: NotificationComponent.Source<{ [number]: NotificationComponent.NotificationData }> =
	Vide.source({} :: { [number]: NotificationComponent.NotificationData })

local AdminNotificationState = Vide.source(false)

local function Component()
	return NotificationComponent({
		Notifications = NotificationsSource,
		AdminNotification = AdminNotificationState,
	})
end

local function SetAdminNotificationState(value: boolean)
	AdminNotificationState(value)
end

local function NewNotification(Settings: NotificationInput)
	if AdminNotificationState() == true or TutorialSource.MountSource() == true then
		return
	end

	local currentTable = NotificationsSource()
	local foundItem: NotificationComponent.NotificationData? = nil

	for _, item in ipairs(currentTable) do
		if item.OriginalText == Settings.Text and item.Type == Settings.Type then
			foundItem = item
			break
		end
	end

	if foundItem then
		Vide.batch(function()
			local newCount = foundItem.Count() + 1
			foundItem.Count(newCount)
			foundItem.Text(foundItem.OriginalText .. " (x" .. tostring(newCount) .. ")")
			foundItem.ResetTimer(foundItem.ResetTimer() + 1)
		end)
	else
		local newItem: NotificationComponent.NotificationData = {
			Id = HttpService:GenerateGUID(false),
			OriginalText = Settings.Text,
			Type = Settings.Type,
			Duration = Settings.Duration,
			Text = Vide.source(Settings.Text),
			Count = Vide.source(1),
			ResetTimer = Vide.source(0),
		}
		local newTable = table.clone(currentTable)
		table.insert(newTable, newItem)
		NotificationsSource(newTable)
	end
end

return {
	Component = Component,
	NewNotification = NewNotification,
	SetAdminNotificationState = SetAdminNotificationState,
}
