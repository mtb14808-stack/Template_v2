local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local SoundsIds = require(ReplicatedStorage.SourceCode.Core.Configs.AssetsId.SoundIds)
local String = require(script.Parent.String)

export type SoundData = {
	id: string,
	Volume: number,
	Pitch: number,
	TimeLenght: number,
}

export type ActiveSounds = {
	[string]: Sound,
}

export type Registry = {
	[string]: SoundData,
}

export type SoundModule = {
	Registry: Registry,
	ActiveSounds: ActiveSounds,
	PlayWithOverWrite: (SoundName: string) -> (),
	Play2DSound: (SoundName: string) -> (),
	Play3DSound: (SoundName: string, Parent: Instance) -> (),
}

local Sound = {} :: SoundModule

Sound.Registry = SoundsIds

Sound.ActiveSounds = {}

local function IsSoundActive(SoundName: string): Sound?
	for _, soundInstance in pairs(Sound.ActiveSounds) do
		if soundInstance.Name == SoundName then
			return soundInstance
		end
	end
	return nil
end

function Sound.PlayWithOverWrite(SoundName: string)
	local SoundData = Sound.Registry[SoundName]
	if not SoundData then
		warn("Couldn't Find Sound for Name: " .. SoundName)
		return
	end

	local ActiveSound = IsSoundActive(SoundName)
	if ActiveSound then
		ActiveSound:Destroy()
		for id, soundInst in pairs(Sound.ActiveSounds) do
			if soundInst == ActiveSound then
				Sound.ActiveSounds[id] = nil
				break
			end
		end
	end

	local SoundId = String.GenerateID(5)

	local soundInstance = Instance.new("Sound")
	soundInstance.Name = SoundName
	soundInstance.SoundId = SoundData.id
	soundInstance.Volume = SoundData.Volume
	soundInstance.PlaybackSpeed = SoundData.Pitch
	soundInstance.Parent = SoundService

	Sound.ActiveSounds[SoundId] = soundInstance

	soundInstance:Play()

	task.delay(soundInstance.TimeLength + 0.22, function()
		if Sound.ActiveSounds[SoundId] == soundInstance then
			Sound.ActiveSounds[SoundId] = nil
		end
	end)

	Debris:AddItem(soundInstance, SoundData.TimeLenght + 0.25)
end

function Sound.Play2DSound(SoundName: string)
	local SoundData = Sound.Registry[SoundName]
	if not SoundData then
		warn("Couldn't Find Sound for Name: " .. SoundName)
		return
	end

	local soundInstance = Instance.new("Sound")
	soundInstance.Name = SoundName
	soundInstance.SoundId = SoundData.id
	soundInstance.Volume = SoundData.Volume
	soundInstance.PlaybackSpeed = SoundData.Pitch
	soundInstance.Parent = SoundService

	soundInstance:Play()

	Debris:AddItem(soundInstance, SoundData.TimeLenght + 0.25)
end

function Sound.Play3DSound(SoundName: string, Parent: Instance)
	local SoundData = Sound.Registry[SoundName]
	if not SoundData then
		warn("Couldn't Find Sound for Name: " .. SoundName)
		return
	end

	if not Parent then
		warn("Parent Instance is nil for 3D Sound: " .. SoundName)
		return
	end

	local soundInstance = Instance.new("Sound")
	soundInstance.Name = SoundName
	soundInstance.SoundId = SoundData.id
	soundInstance.Volume = SoundData.Volume
	soundInstance.PlaybackSpeed = SoundData.Pitch
	soundInstance.Parent = Parent

	soundInstance:Play()

	Debris:AddItem(soundInstance, SoundData.TimeLenght + 0.25)
end

return Sound
