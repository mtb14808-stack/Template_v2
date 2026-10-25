local Players = game:GetService("Players")
local Player = Players.LocalPlayer

return {
	[1] = {
		Text = "Collect The Food",
		TargetParent = function()
			local PLayerGui = Player:WaitForChild("PlayerGui")
			local MainRoot = PLayerGui:WaitForChild("MainRoot")
			local LeftBar = MainRoot:WaitForChild("TestContainer")
			return LeftBar
		end,
	},
}
