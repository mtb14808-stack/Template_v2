--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Vide = require(ReplicatedStorage.Packages.Vide)

local TextSizing = {}

function TextSizing.GetScale(gui: Instance): number
	local scale = 1
	local ancestor: Instance? = gui
	while ancestor do
		local uiScale = ancestor:FindFirstChildOfClass("UIScale")
		if uiScale then
			scale *= uiScale.Scale
		end
		ancestor = ancestor.Parent
	end
	return math.max(scale, 0.0001)
end

local function read(value: any): any
	return if type(value) == "function" then value() else value
end

function TextSizing.Apply(props: { [any]: any })
	return Vide.action(function(instance: Instance)
		local text = instance :: TextLabel | TextButton
		local alive = true
		local queued = false
		local revision = 0
		local connections: { RBXScriptConnection } = {}
		local lastKey: string? = nil
		local lastFit = 100
		local nativeKey: string? = nil

		local function update()
			queued = false
			if not alive then
				return
			end
			local ticket = revision
			local scaled = read(props.TextScaled)
			if scaled == false then
				lastKey = nil
				nativeKey = nil
				text.TextScaled = false
				text.TextSize = read(props.TextSize) or 14
				text.TextWrapped = read(props.TextWrapped) or false
				return
			end

			text.TextWrapped = true
			local scale = TextSizing.GetScale(text)
			local size = text.AbsoluteSize / scale
			local padding = text:FindFirstChildOfClass("UIPadding")
			if padding then
				size = Vector2.new(
					size.X * (1 - padding.PaddingLeft.Scale - padding.PaddingRight.Scale)
						- padding.PaddingLeft.Offset - padding.PaddingRight.Offset,
					size.Y * (1 - padding.PaddingTop.Scale - padding.PaddingBottom.Scale)
						- padding.PaddingTop.Offset - padding.PaddingBottom.Offset
				)
			end
			if size.X <= 0 or size.Y <= 0 then
				text.TextScaled = true
				return
			end
			if scale <= 1 or size.Y * scale <= 100 then
				text.TextScaled = true
				return
			end

			local constraint = text:FindFirstChildOfClass("UITextSizeConstraint")
			local minimum = if constraint then math.clamp(constraint.MinTextSize, 1, 100) else 1
			local maximum = if constraint then math.clamp(constraint.MaxTextSize, minimum, 100) else 100
			local key = string.format("%s|%s|%s|%s|%s|%.2f|%.2f|%g|%g|%g",
				text.Text, text.FontFace.Family, text.FontFace.Weight.Name, text.FontFace.Style.Name,
				tostring(text.RichText), size.X, size.Y, text.LineHeight, minimum, maximum)
			if key == lastKey then
				text.TextScaled = lastFit * scale <= 100
				if not text.TextScaled then
					text.TextSize = lastFit
				end
				return
			end
			local screenKey = key .. string.format("|%.4f", scale)
			if screenKey == nativeKey then
				text.TextScaled = true
				return
			end

			local params = Instance.new("GetTextBoundsParams")
			params.Text = text.Text
			params.Font = text.FontFace
			params.RichText = text.RichText
			params.Width = size.X * scale
			local lineHeight = text.LineHeight
			local success, fitted = pcall(function(): number
				params.Size = 100
				local screenBounds = TextService:GetTextBoundsAsync(params)
				local screenLines = math.max(1, math.round(screenBounds.Y / 100))
				local screenHeight = screenBounds.Y + (screenLines - 1) * 100 * (lineHeight - 1)
				if screenBounds.X > size.X * scale or screenHeight > size.Y * scale then
					return 0
				end
				params.Width = size.X
				local low, high = minimum, maximum
				local best = minimum
				while low <= high do
					local candidate = math.floor((low + high) / 2)
					params.Size = candidate
					local bounds = TextService:GetTextBoundsAsync(params)
					local lines = math.max(1, math.round(bounds.Y / candidate))
					local height = bounds.Y + (lines - 1) * candidate * (lineHeight - 1)
					if bounds.X <= size.X and height <= size.Y then
						best = candidate
						low = candidate + 1
					else
						high = candidate - 1
					end
				end
				return best
			end)
			params:Destroy()
			if alive and ticket == revision then
				if success then
					if fitted == 0 then
						nativeKey = screenKey
						text.TextScaled = true
					else
						lastKey = key
						lastFit = fitted
						text.TextScaled = fitted * scale <= 100
						if not text.TextScaled then
							text.TextSize = fitted
						end
					end
				else
					text.TextScaled = true
				end
			end
		end

		local function schedule()
			revision += 1
			if not queued then
				queued = true
				task.defer(update)
			end
		end

		for _, property in ipairs({ "AbsoluteSize", "Text", "FontFace", "RichText", "LineHeight" }) do
			table.insert(connections, text:GetPropertyChangedSignal(property):Connect(schedule))
		end
		table.insert(connections, text.AncestryChanged:Connect(schedule))
		local childConnections: { [Instance]: RBXScriptConnection } = {}
		local function watchChild(child: Instance)
			if child:IsA("UITextSizeConstraint") or child:IsA("UIPadding") then
				childConnections[child] = child.Changed:Connect(schedule)
				schedule()
			end
		end
		for _, child in ipairs(text:GetChildren()) do
			watchChild(child)
		end
		table.insert(connections, text.ChildAdded:Connect(watchChild))
		table.insert(connections, text.ChildRemoved:Connect(function(child: Instance)
			local connection = childConnections[child]
			if connection then
				connection:Disconnect()
				childConnections[child] = nil
				schedule()
			end
		end))
		Vide.cleanup(function()
			alive = false
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end
			for _, connection in pairs(childConnections) do
				connection:Disconnect()
			end
		end)
		Vide.effect(function()
			read(props.TextScaled)
			read(props.TextSize)
			read(props.TextWrapped)
			lastKey = nil
			nativeKey = nil
			schedule()
		end)
	end)
end

return TextSizing
