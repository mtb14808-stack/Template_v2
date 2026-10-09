--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Frame = require(ReplicatedStorage.SourceCode.Core.Ui.Elements.Frame)

local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera") :: Camera

export type Settings = {
	FunctionName: string,
	Duration: number?,
	[string]: any,
}

export type Action = {
	Id: number,
	Settings: Settings,
	Duration: number,
}

export type Props = {
	ActionSource: () -> Action,
	MountedSource: () -> boolean,
}

type EffectData = {
	Settings: Settings,
	StartTime: number,
	Duration: number,
	FadeTime: number,
}

local ContinuousEffects = {
	ShakeCamera = function(args: { Intensity: number?, Frequency: number?, Duration: number? }, weight: number)
		local intensity = (args.Intensity or 1) * weight
		local freq = args.Frequency or 20
		local clock = os.clock() * freq
		local offsetX = math.noise(clock, 0, 0) * intensity
		local offsetY = math.noise(0, clock, 0) * intensity

		Camera.CFrame *= CFrame.Angles(math.rad(offsetY * 0.1), math.rad(offsetX * 0.1), 0)
	end,

	Bobbing = function(args: { Speed: number?, Intensity: number?, Duration: number? }, weight: number)
		local speed = args.Speed or 8
		local intensity = (args.Intensity or 0.5) * weight
		local wave = math.sin(os.clock() * speed) * (intensity * 0.05)

		Camera.CFrame *= CFrame.new(0, wave, 0)
	end,

	Sway = function(args: { Amount: number?, Duration: number? }, weight: number)
		local amount = (args.Amount or 1) * weight
		local roll = math.sin(os.clock() * 3) * math.rad(amount)

		Camera.CFrame *= CFrame.Angles(0, 0, roll)
	end,

	DistanceShake = function(
		args: {
			Origin: Vector3?,
			MaxDistance: number?,
			Intensity: number?,
			Frequency: number?,
			Duration: number?,
		},
		weight: number
	)
		local origin = args.Origin or Camera.CFrame.Position
		local maxDist = args.MaxDistance or 50
		local baseIntensity = (args.Intensity or 1) * weight
		local freq = args.Frequency or 20

		local dist = (Camera.CFrame.Position - origin).Magnitude
		if dist >= maxDist then
			return
		end

		local distanceFactor = 1 - (dist / maxDist)
		local currentIntensity = baseIntensity * distanceFactor

		local clock = os.clock() * freq
		local offsetX = math.noise(clock, 0, 0) * currentIntensity
		local offsetY = math.noise(0, clock, 0) * currentIntensity

		Camera.CFrame *= CFrame.Angles(math.rad(offsetY * 0.1), math.rad(offsetX * 0.1), 0)
	end,
}

return function(Props: Props)
	return Vide.show(Props.MountedSource, function()
		local renderConnection: RBXScriptConnection? = nil
		local burstThread: thread? = nil
		local activeContinuous: { [number]: EffectData } = {}

		local targetFov = Vide.source(Camera.FieldOfView)
		local fovSpring, configSpring = Vide.spring(targetFov, 0.4, 0.8)

		Vide.effect(function()
			Camera.FieldOfView = fovSpring()
		end)

		local InstantEffects = {
			TimedBurstFov = function(args: { TargetFov: number, Period: number, Duration: number, NormalFov: number? })
				configSpring({ period = args.Period, damping = 0.8 })
				targetFov(args.TargetFov)

				if burstThread then
					task.cancel(burstThread)
				end

				burstThread = task.delay(args.Period + args.Duration, function()
					targetFov(args.NormalFov or 70)
					burstThread = nil
				end)
			end,

			ImpulseFov = function(args: { Impulse: number, Period: number?, Damping: number?, Duration: number? })
				configSpring({ period = args.Period or 0.9, damping = args.Damping or 0.5, impulse = args.Impulse })
			end,

			SetFov = function(args: { GoalFov: number, Time: number? })
				targetFov(args.GoalFov)
				configSpring({ period = args.Time or 0.9 })
			end,
		}

		Vide.effect(function()
			local action = Props.ActionSource()
			local settings = action.Settings
			local fnName = settings.FunctionName
			local duration = settings.Duration or action.Duration

			if not fnName or fnName == "" then
				return
			end

			if InstantEffects[fnName] then
				InstantEffects[fnName](settings)
			elseif ContinuousEffects[fnName] then
				local id = action.Id
				local fadeTime = math.min(0.5, duration * 0.3)

				activeContinuous[id] = {
					Settings = settings,
					StartTime = os.clock(),
					Duration = duration,
					FadeTime = fadeTime,
				}

				if not renderConnection then
					renderConnection = RunService.RenderStepped:Connect(function()
						local now = os.clock()

						for effectId, data in pairs(activeContinuous) do
							local elapsed = now - data.StartTime
							local remaining = data.Duration - elapsed

							if remaining > 0 then
								local fadeIn = if data.FadeTime > 0
									then math.clamp(elapsed / data.FadeTime, 0, 1)
									else 1
								local fadeOut = if data.FadeTime > 0
									then math.clamp(remaining / data.FadeTime, 0, 1)
									else 1

								local weight = math.min(fadeIn, fadeOut)
								weight = weight * weight * (3 - 2 * weight)

								if weight > 0.001 then
									ContinuousEffects[data.Settings.FunctionName](data.Settings, weight)
								end
							else
								activeContinuous[effectId] = nil
							end
						end

						if next(activeContinuous) == nil and renderConnection then
							renderConnection:Disconnect()
							renderConnection = nil
						end
					end)
				end
			end
		end)

		Vide.cleanup(function()
			if renderConnection then
				renderConnection:Disconnect()
				renderConnection = nil
			end
			if burstThread then
				task.cancel(burstThread)
				burstThread = nil
			end
			table.clear(activeContinuous)
		end)

		return Frame({
			Name = "CameraHost",
			Visible = false,
			Size = UDim2.fromScale(0, 0),
		})
	end)
end
