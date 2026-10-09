local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)

export type ComponentArgs = {
	Trigger: () -> number,
	Type: () -> "UpRain" | "BottomCorner",
	ZIndex: number,
	Count: () -> number,
}

export type NodeEntity = {
	uid: number,
	pos: Vector2,
	life: number,
	momentum: Vector2,
	timeActive: number,
	weight: Vector2,
	angle: number,
	spinRate: number,
	scale: Vector2,
	tint: Color3,
	oscillationOffset: number,
	oscillationFreq: number,
	oscillationScale: number,
}

local VisualNodes = Vide.source({} :: { [number]: NodeEntity })
local PreviousEventTick = Vide.source(0)
local AnimationCycleTracker = 0
local GlobalNodeIndex = 0

local TINT_PALETTE = {
	Color3.fromRGB(255, 0, 127),
	Color3.fromRGB(255, 235, 59),
	Color3.fromRGB(0, 204, 255),
	Color3.fromRGB(157, 0, 255),
	Color3.fromRGB(0, 255, 128),
	Color3.fromRGB(255, 87, 34),
	Color3.fromRGB(255, 255, 255),
}

local function ConstructNodeData(
	boundsX0: number,
	boundsX1: number,
	boundsY0: number,
	boundsY1: number,
	thrustX0: number,
	thrustX1: number,
	thrustY0: number,
	thrustY1: number,
	fallForce: Vector2
): NodeEntity
	GlobalNodeIndex += 1

	local startX = boundsX0 + math.random() * (boundsX1 - boundsX0)
	local startY = boundsY0 + math.random() * (boundsY1 - boundsY0)
	local moveX = thrustX0 + math.random() * (thrustX1 - thrustX0)
	local moveY = thrustY0 + math.random() * (thrustY1 - thrustY0)
	local width = 30 + math.random() * 14
	local height = 20 + math.random() * 10

	return {
		uid = GlobalNodeIndex,
		pos = Vector2.new(startX, startY),
		momentum = Vector2.new(moveX, moveY),
		timeActive = 0,
		life = 3 + math.random() * 2.5,
		weight = fallForce,
		angle = math.random() * 360,
		spinRate = -250 + math.random() * 500,
		scale = Vector2.new(width, height),
		tint = TINT_PALETTE[math.random(1, #TINT_PALETTE)],
		oscillationOffset = math.random() * math.pi * 2,
		oscillationFreq = 3 + math.random() * 2.5,
		oscillationScale = 0.02 + math.random() * 0.03,
	}
end

local function DispatchBurst(amount: number, generatorFunc: () -> NodeEntity)
	local stateCopy = table.clone(VisualNodes())

	local step = 1
	while step <= amount do
		table.insert(stateCopy, generatorFunc())
		step += 1
	end

	VisualNodes(stateCopy)
end

local function ExecuteOverheadShower(amount: number)
	AnimationCycleTracker += 1
	local cycleCache = AnimationCycleTracker

	task.spawn(function()
		local cascadeTimings = { 0, 0.15, 0.3, 0.5, 0.7, 0.9 }
		local previousStamp = 0

		for idx = 1, #cascadeTimings do
			local currentStamp = cascadeTimings[idx]
			task.wait(currentStamp - previousStamp)
			previousStamp = currentStamp

			if AnimationCycleTracker ~= cycleCache then
				break
			end

			DispatchBurst(amount, function()
				return ConstructNodeData(0.05, 0.95, -0.15, -0.05, -0.2, 0.2, 0.2, 0.6, Vector2.new(0, 0.8))
			end)
		end
	end)
end

local function ExecuteCornerCannons(amount: number)
	AnimationCycleTracker += 1
	local cycleCache = AnimationCycleTracker

	task.spawn(function()
		local eruptionTimings = { 0, 0.1, 0.22, 0.36 }
		local previousStamp = 0

		for idx = 1, #eruptionTimings do
			local currentStamp = eruptionTimings[idx]
			task.wait(currentStamp - previousStamp)
			previousStamp = currentStamp

			if AnimationCycleTracker ~= cycleCache then
				break
			end

			DispatchBurst(amount, function()
				return ConstructNodeData(-0.05, 0.05, 0.95, 1.05, 0.8, 1.6, -2.5, -1.8, Vector2.new(0, 2.2))
			end)

			DispatchBurst(amount, function()
				return ConstructNodeData(0.95, 1.05, 0.95, 1.05, -1.6, -0.8, -2.5, -1.8, Vector2.new(0, 2.2))
			end)
		end
	end)
end

return function(Args: ComponentArgs)
	local CacheTick = PreviousEventTick()

	Vide.effect(function()
		local NewTick = Args.Trigger()
		if NewTick == CacheTick then
			return
		end

		CacheTick = NewTick
		local AnimType = Args.Type()

		if AnimType == "UpRain" then
			ExecuteOverheadShower(Args.Count())
		elseif AnimType == "BottomCorner" then
			ExecuteCornerCannons(Args.Count())
		end
	end)

	local PhysicsLoop = RunService.Heartbeat:Connect(function(delta: number)
		local snapshot = VisualNodes()
		if #snapshot == 0 then
			return
		end

		local nextState = table.create(#snapshot)
		local aerodynamicDrag = 1.4
		local rotationalFriction = 0.95

		for _, item in snapshot do
			local updatedAge = item.timeActive + delta
			if updatedAge >= item.life then
				continue
			end

			local driftAmount = math.sin(item.timeActive * item.oscillationFreq + item.oscillationOffset)
				* item.oscillationScale
			local slowedVel = item.momentum * (1 - aerodynamicDrag * delta)
			local finalVel = slowedVel + item.weight * delta
			local posX = item.pos.X + (finalVel.X + driftAmount) * delta
			local posY = item.pos.Y + finalVel.Y * delta
			local adjustedSpin = item.spinRate * (1 - rotationalFriction * delta)

			table.insert(nextState, {
				uid = item.uid,
				timeActive = updatedAge,
				life = item.life,
				pos = Vector2.new(posX, posY),
				momentum = finalVel,
				weight = item.weight,
				angle = item.angle + adjustedSpin * delta,
				spinRate = adjustedSpin,
				scale = item.scale,
				tint = item.tint,
				oscillationOffset = item.oscillationOffset,
				oscillationFreq = item.oscillationFreq,
				oscillationScale = item.oscillationScale,
			})
		end

		VisualNodes(nextState)
	end)

	Vide.cleanup(function()
		PhysicsLoop:Disconnect()
		VisualNodes({})
	end)

	return Frame({
		ZIndex = Args.ZIndex or 10,
		Name = "EffectsLayer_Confetti",
		Visible = function()
			return #VisualNodes() > 0
		end,

		Vide.values(VisualNodes, function(NodeItem)
			return Frame({
				Name = function()
					return "Node_" .. tostring(NodeItem.uid)
				end,
				Visible = true,
				BackgroundTransparency = 0,
				Position = function()
					return UDim2.fromScale(NodeItem.pos.X, NodeItem.pos.Y)
				end,
				Size = function()
					return UDim2.fromOffset(NodeItem.scale.X, NodeItem.scale.Y)
				end,
				Rotation = function()
					return NodeItem.angle
				end,
				BackgroundColor3 = function()
					return NodeItem.tint
				end,
			})
		end),
	})
end
