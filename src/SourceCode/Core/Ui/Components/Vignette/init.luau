--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local VignetteComponent = require(script.VignetteComponent)

export type ColorInput = Color3 | ColorSequence

local isMounted = Vide.source(false)
local vignetteState = Vide.source(false)
local colorSource = Vide.source(Color3.new(0, 0, 0) :: ColorInput)
local transparencySource = Vide.source(0)
local rotationSpeedSource = Vide.source(1)
local useRotationSource = Vide.source(false)
local IsProductVignetteSource = Vide.source(false)

local destroyThread: thread? = nil
local durationThread: thread? = nil

local function cancelTimers()
	if destroyThread then
		task.cancel(destroyThread)
		destroyThread = nil
	end
	if durationThread then
		task.cancel(durationThread)
		durationThread = nil
	end
end

local function RemoveVignette()
	if durationThread then
		task.cancel(durationThread)
		durationThread = nil
	end

	vignetteState(false)
	if IsProductVignetteSource() == true then
		IsProductVignetteSource(false)
	end
	if destroyThread then
		task.cancel(destroyThread)
	end

	destroyThread = task.delay(5, function()
		destroyThread = nil
		if not vignetteState() then
			Vide.batch(function()
				useRotationSource(false)
				rotationSpeedSource(1)
				isMounted(false)
			end)
		end
	end)
end

local function SetVignette(
	vignetteColor: ColorInput,
	transparencyGoal: number,
	useRotation: boolean?,
	rotationSpeed: number?,
	IsProductVignette: boolean?
)
	cancelTimers()

	Vide.batch(function()
		isMounted(true)
		colorSource(vignetteColor)
		transparencySource(transparencyGoal)
		useRotationSource(useRotation or false)
		rotationSpeedSource(rotationSpeed or 1)
		vignetteState(true)
		if IsProductVignette then
			IsProductVignetteSource(true)
		else
			IsProductVignetteSource(false)
		end
	end)
end

local function applyVignetteWithDuration(
	vignetteColor: ColorInput,
	vignetteDuration: number,
	transparencyGoal: number,
	useRotation: boolean?,
	rotationSpeed: number?
)
	SetVignette(vignetteColor, transparencyGoal, useRotation, rotationSpeed)

	durationThread = task.delay(vignetteDuration, function()
		durationThread = nil
		RemoveVignette()
	end)
end

local function ProductVignette(
	vignetteColor: ColorInput,
	transparencyGoal: number,
	useRotation: boolean?,
	rotationSpeed: number?
)
	SetVignette(vignetteColor, transparencyGoal, useRotation, rotationSpeed, true)
end

local function Component()
	return VignetteComponent({
		IsMounted = isMounted,
		State = vignetteState,
		UseRotation = useRotationSource,
		Transparency = transparencySource,
		RotationSpeed = rotationSpeedSource,
		Color = colorSource,
	})
end

return {
	SetVignette = SetVignette,
	RemoveVignette = RemoveVignette,
	applyVignetteWithDuration = applyVignetteWithDuration,
	ProductVignette = ProductVignette,
	IsProductVignetteSource = IsProductVignetteSource,
	Component = Component,
}
