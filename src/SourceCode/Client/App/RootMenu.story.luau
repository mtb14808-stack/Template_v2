local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RootMenuUI = require(script.Parent.RootMenuUI)
local Vide = require(ReplicatedStorage.Packages.Vide)

return function(Target)
	local Cleanup = Vide.mount(function()
		return RootMenuUI()
	end, Target)

	return function()
		Cleanup()
	end
end
