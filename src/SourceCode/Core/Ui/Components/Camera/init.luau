--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local CameraComponent = require(script.CameraComponent)

export type Setting = {
	FunctionName: string,
	[string]: any,
}

export type Action = {
	Id: number,
	Settings: Setting,
	Duration: number,
}

local MountedSource = Vide.source(false)
local ActionSource = Vide.source({ Id = 0, Settings = { FunctionName = "" }, Duration = 0 } :: Action)

local ActiveTasks = 0
local CleanThread: thread? = nil
local ActionId = 0

local function CleanCamera()
	if CleanThread then
		task.cancel(CleanThread)
		CleanThread = nil
	end
	ActiveTasks = 0
	MountedSource(false)
end

local function RunCameraFunction(Settings: Setting, customDuration: number?)
	if CleanThread then
		task.cancel(CleanThread)
		CleanThread = nil
	end

	local duration = customDuration or Settings.Duration or 5.5
	ActionId += 1

	MountedSource(true)
	ActionSource({
		Id = ActionId,
		Settings = Settings,
		Duration = duration,
	})

	ActiveTasks += 1

	task.delay(duration, function()
		ActiveTasks -= 1
		if ActiveTasks <= 0 then
			CleanThread = task.delay(5, function()
				CleanThread = nil
				CleanCamera()
			end)
		end
	end)
end

local function Component()
	return CameraComponent({
		ActionSource = ActionSource,
		MountedSource = MountedSource,
	})
end

return {
	Component = Component,
	RunCameraFunction = RunCameraFunction,
	CleanCamera = CleanCamera,
}
