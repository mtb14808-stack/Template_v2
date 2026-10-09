local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type Props = {
	Scale: ((() -> number) | number)?,
}

return function(props: Props?)
	local p = props or {}
	return Vide.create("UIScale")({
		Scale = p.Scale or 1,
	})
end
