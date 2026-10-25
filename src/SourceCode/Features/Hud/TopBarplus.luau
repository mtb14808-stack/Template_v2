local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FeedBack = require(ReplicatedStorage.SourceCode.Features.Hud.UI.TopBar.FeedBack)
return function()
	FeedBack()
end
