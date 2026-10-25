local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TutorialVisual = require(ReplicatedStorage.SourceCode.Features.Tutorial.UI.Components.TutorialVisual)

return function()
	return {
		TutorialVisual(),
	}
end
