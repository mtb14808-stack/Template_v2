local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local TutorialSource = require(ReplicatedStorage.SourceCode.Features.Tutorial.UI.Sources.TutorialSource)
local AdminNotificationComponent = require(script.AdminNotificationComponent)
local Notification = require(script.Parent.Notification)

local AdminNotificationSource = Vide.source({} :: { AdminNotificationComponent.NotificationData })
local Mounted = Vide.source(false)

local function Component()
	Vide.effect(function()
		local currentNotifications = AdminNotificationSource()
		if #currentNotifications == 0 then
			Notification.SetAdminNotificationState(false)
		end
	end)

	return AdminNotificationComponent({
		AdminNotificationSource = AdminNotificationSource,
		Mounted = Mounted,
	})
end

local function AddAdminNotification(Text: string, Color: string, Duration: number)
	if TutorialSource.MountSource() == true then
		return
	end

	Mounted(true)
	Notification.SetAdminNotificationState(true)

	local CurrentTable = table.clone(AdminNotificationSource())

	local NewNotification: AdminNotificationComponent.NotificationData = {
		Text = Text,
		Color = Color,
		Duration = Duration,
	}

	table.insert(CurrentTable, NewNotification)
	AdminNotificationSource(CurrentTable)
end

return {
	Component = Component,
	AddAdminNotification = AddAdminNotification,
}
