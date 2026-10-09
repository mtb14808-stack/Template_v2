local TweenService = game:GetService("TweenService")

export type CoreModule = {
	GetValue: (Alpha: number, style: Enum.EasingStyle, direction: Enum.EasingDirection) -> number,
	Play: (instance: Instance, styleName: string, directionName: string, time: number, goal: { [string]: any }) -> Tween?,
	Wait: (instance: Instance, styleName: string, directionName: string, time: number, goal: { [string]: any }) -> (),
}

local Core = {} :: CoreModule

function Core.GetValue(Alpha: number, style: Enum.EasingStyle, direction: Enum.EasingDirection): number return TweenService:GetValue(Alpha, style, direction) end

function Core.Play(instance: Instance, styleName: string, directionName: string, time: number, goal: { [string]: any }): Tween?
	if not instance or not goal then return nil end

	local successStyle, easingStyle = pcall(function() return Enum.EasingStyle[styleName] end)
	if not successStyle or not easingStyle then easingStyle = Enum.EasingStyle.Sine end

	local successDirection, easingDirection = pcall(function() return Enum.EasingDirection[directionName] end)
	if not successDirection or not easingDirection then easingDirection = Enum.EasingDirection.Out end

	local tInfo = TweenInfo.new(tonumber(time) or 0.5, easingStyle, easingDirection)

	local tween = TweenService:Create(instance, tInfo, goal)
	tween:Play()

	return tween
end

function Core.Wait(instance: Instance, styleName: string, directionName: string, time: number, goal: { [string]: any })
	local tween = Core.Play(instance, styleName, directionName, time, goal)
	if tween then tween.Completed:Wait() end
end

return Core
