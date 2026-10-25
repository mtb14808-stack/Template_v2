local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
return function()
	local Icon = TopbarPlus.new()

	Icon:setImage(91349989997111):setImageScale(1.085)

	Icon.selected:Connect(function()
		Icon:deselect()

		pcall(function()
			SocialService:PromptFeedbackSubmissionAsync()
		end)
	end)
end
