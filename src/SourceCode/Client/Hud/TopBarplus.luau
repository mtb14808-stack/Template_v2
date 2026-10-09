local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeedBack = require(ReplicatedStorage.SourceCode.Client.Hud.UI.TopBar.FeedBack)
return function()
	FeedBack()
end
