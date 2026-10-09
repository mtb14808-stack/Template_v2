export type Haptic = {
	Play: (intensity: number?, duration: number?) -> (),
	SoftImpulse: () -> (),
	Alert: () -> (),
	HeavyImpact: () -> (),
	Stop: () -> (),
}

local HapticService = game:GetService("HapticService")
local UserInputService = game:GetService("UserInputService")

local Haptic = {}

warn("TESTARE I IMPULSE SU CONTROLLER PS4 PER CAPIRE INTENSITA")
local GAMEPAD = Enum.UserInputType.Gamepad1

local function canVibrate()
	return HapticService:IsVibrationSupported(GAMEPAD) or UserInputService.TouchEnabled
end

function Haptic.Play(intensity, duration)
	if not canVibrate() then
		return
	end

	intensity = math.clamp(intensity or 0.5, 0, 1)
	duration = duration or 0.2

	HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Large, intensity)
	HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Small, intensity)

	task.delay(duration, function()
		HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Large, 0)
		HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Small, 0)
	end)
end

function Haptic.SoftImpulse()
	if not canVibrate() then
		return
	end

	HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Small, 0.3)
	task.wait(0.05)
	HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Small, 0)
end

function Haptic.Alert()
	if not canVibrate() then
		return
	end

	task.spawn(function()
		Haptic.Play(0.8, 0.1)
		task.wait(0.1)
		Haptic.Play(0.8, 0.1)
	end)
end

function Haptic.HeavyImpact()
	if not canVibrate() then
		return
	end

	HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Large, 1)
	HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Small, 0.5)

	task.delay(0.4, function()
		HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Large, 0)
		HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Small, 0)
	end)
end

function Haptic.Stop()
	HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Large, 0)
	HapticService:SetMotor(GAMEPAD, Enum.VibrationMotor.Small, 0)
end

return Haptic
