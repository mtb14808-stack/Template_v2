local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

local source = Vide.source
local spring = Vide.spring
local create = Vide.create

export type HoverOptions = {
	hoverScale: number?,
	pressScale: number?,
	normalScale: number?,
	period: number?,
	damping: number?,
	MouseEnter: boolean?,
	MouseLeave: boolean?,
	MouseButton1Down: boolean?,
	MouseButton1Up: boolean?,
}

return function(options: HoverOptions?)
	local opts = options or {}
	local hoverScale = opts.hoverScale or 1.1
	local pressScale = opts.pressScale or 0.95
	local normalScale = opts.normalScale or 1.0
	if opts.hoverScale == nil and opts.pressScale == nil and opts.normalScale == nil then
		opts.hoverScale = 1.05
		opts.pressScale = 0.95
		opts.normalScale = 1.0
	end

	local enableMouseEnter = if opts.MouseEnter ~= nil then opts.MouseEnter else true
	local enableMouseLeave = if opts.MouseLeave ~= nil then opts.MouseLeave else true
	local enableMouseDown = if opts.MouseButton1Down ~= nil then opts.MouseButton1Down else true
	local enableMouseUp = if opts.MouseButton1Up ~= nil then opts.MouseButton1Up else true

	local isHovered = source(false)
	local isPressed = source(false)

	local targetScale = function()
		if isPressed() then
			return pressScale
		elseif isHovered() then
			return hoverScale
		else
			return normalScale
		end
	end

	local buttonScale = spring(targetScale, opts.period or 0.1, opts.damping or 1)

	return function(props: { [any]: any })
		local originalMouseEnter = props.MouseEnter
		local originalMouseLeave = props.MouseLeave
		local originalMouseDown = props.MouseButton1Down
		local originalMouseUp = props.MouseButton1Up

		if enableMouseEnter then
			props.MouseEnter = function(...)
				isHovered(true)
				if originalMouseEnter then
					originalMouseEnter(...)
				end
			end
		end

		if enableMouseLeave then
			props.MouseLeave = function(...)
				isHovered(false)
				isPressed(false)
				if originalMouseLeave then
					originalMouseLeave(...)
				end
			end
		end

		if enableMouseDown then
			props.MouseButton1Down = function(...)
				isPressed(true)
				if originalMouseDown then
					originalMouseDown(...)
				end
			end
		end

		if enableMouseUp then
			props.MouseButton1Up = function(...)
				isPressed(false)
				if originalMouseUp then
					originalMouseUp(...)
				end
			end
		end

		table.insert(
			props,
			create("UIScale")({
				Scale = buttonScale,
			})
		)

		return props
	end
end
