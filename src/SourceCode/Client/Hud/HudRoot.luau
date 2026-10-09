local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TopBar = require(ReplicatedStorage.SourceCode.Client.Hud.UI.Components.TopBar)
local BottomBar = require(ReplicatedStorage.SourceCode.Client.Hud.UI.Components.BottomBar)
local EffectsContainer = require(ReplicatedStorage.SourceCode.Client.Hud.UI.Components.EffectsContainer)
local LeftBar = require(ReplicatedStorage.SourceCode.Client.Hud.UI.Components.LeftBar)
local RightBar = require(ReplicatedStorage.SourceCode.Client.Hud.UI.Components.RightBar)
return function()
	return {
		RightBar(),
		LeftBar(),
		EffectsContainer(),
		TopBar(),
		BottomBar(),
	}
end
