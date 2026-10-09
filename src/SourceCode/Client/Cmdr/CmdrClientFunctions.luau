local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminNotification = require(ReplicatedStorage.SourceCode.Core.Ui.Components.AdminNotification)

export type GlobalMessageArgs = {
	Duration: number,
	Message: string,
	Color: string,
}

return {
	["GlobalMessage"] = function(Message: string, Duration: number, Color: string)
		AdminNotification.AddAdminNotification(Message, Color, Duration)
	end,
}
