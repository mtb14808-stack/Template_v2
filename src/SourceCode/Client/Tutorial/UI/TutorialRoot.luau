local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TutorialVisual = require(ReplicatedStorage.SourceCode.Client.Tutorial.UI.Components.TutorialVisual)

return function()
	return {
		TutorialVisual(),
	}
end
