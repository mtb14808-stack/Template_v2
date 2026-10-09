--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)

export type SpringControl = {
	impulse: (number | UDim2)?,
	position: (number | UDim2)?,
	velocity: (number | UDim2)?,
}

local Spring = {}

function Spring.HudSrping(
	source: () -> boolean,
	onScreenPos: UDim2,
	offScreenPos: UDim2,
	period: number?,
	damping: number?
): () -> UDim2
	return Vide.spring(function()
		return if source() then offScreenPos else onScreenPos
	end, period or 0.35, damping or 0.8)
end

function Spring.TriggerSpring<T>(
	Goal: T | () -> T,
	Initial: T,
	alphaThreshold: number?,
	period: number?,
	damping: number?
): (() -> T, (any) -> (), () -> boolean)
	local isEnded = Vide.source(false)

	local p = period or 0.4
	local d = math.clamp(damping or 0.7, 0.05, 1)
	local alpha = alphaThreshold or 1

	local baseDuration = (4.6 * p) / (2 * math.pi * d)
	local duration = baseDuration * alpha

	local initialGoal: T
	if typeof(Goal) == "function" then
		initialGoal = (Goal :: () -> T)()
	else
		initialGoal = Goal :: T
	end

	local targetSource = Vide.source(initialGoal)
	local springValue, springControl = Vide.spring(targetSource, p, d)

	springControl({ position = Initial })

	local activeThread: thread? = nil

	local function startTimer()
		if activeThread then
			task.cancel(activeThread)
		end

		isEnded(false)

		activeThread = task.delay(duration, function()
			isEnded(true)
			activeThread = nil
		end)
	end

	Vide.effect(function()
		local currentGoal = if typeof(Goal) == "function" then (Goal :: () -> T)() else Goal :: T
		targetSource(currentGoal)
		startTimer()
	end)

	local function customControl(control: any)
		startTimer()
		springControl(control)
	end

	return springValue, customControl, isEnded
end

function Spring.TriggerImpulse(
	alphaThreshold: number?,
	period: number?,
	damping: number?
): (() -> number, (SpringControl) -> (), () -> boolean)
	local isEnded = Vide.source(false)

	local p = period or 0.4
	local d = math.clamp(damping or 0.7, 0.05, 1)
	local alpha = alphaThreshold or 1

	local baseDuration = (4.6 * p) / (2 * math.pi * d)
	local duration = baseDuration * alpha

	local springValue, setting = Vide.spring(function()
		return 0
	end, p, d)

	local activeThread: thread? = nil

	local function triggerImpulse(control: SpringControl)
		if control.impulse or control.velocity then
			if activeThread then
				task.cancel(activeThread)
			end

			isEnded(false)

			activeThread = task.delay(duration, function()
				isEnded(true)
				activeThread = nil
			end)
		end

		setting(control)
	end

	return springValue, triggerImpulse, isEnded
end
function Spring.NormalSpring(
	Goal: number | UDim2 | () -> UDim2 | number,
	Initial: UDim2 | number,
	period: number?,
	damping: number?
): (() -> UDim2, (SpringControl) -> ())
	local springValue, springControl = Vide.spring(function()
		return if type(Goal) == "function" then Goal() else Goal
	end, period or 0.4, damping or 0.7)

	springControl({ position = Initial })

	return springValue, springControl
end

function Spring.NormalImpulse(period: number?, damping: number?): (() -> number, (SpringControl) -> ())
	local springValue, setting = Vide.spring(function()
		return 0
	end, period or 0.4, damping or 0.7)

	return springValue, setting
end

return Spring
