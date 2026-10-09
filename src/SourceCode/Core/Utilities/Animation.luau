local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationsData = require(ReplicatedStorage.SourceCode.Core.Configs.AnimationsData)

local LocalPlayer = Players.LocalPlayer

export type AnimationEntry = {
	Name: string,
	Id: string | number,
	Preload: boolean?,
}

local Animation = {}

Animation.Animations = AnimationsData.ModuleAnimation :: { AnimationEntry }

local AnimationInstances: { [string]: Animation } = {}
local LoadedTracks: { [Animator]: { [string]: AnimationTrack } } = setmetatable({}, { __mode = "k" }) :: any

local function CleanupAnimatorTracks(animator: Animator)
	local tracks = LoadedTracks[animator]
	if tracks then
		for _, track in pairs(tracks) do
			pcall(function()
				track:Stop(0)
				track:Destroy()
			end)
		end
		table.clear(tracks)
		LoadedTracks[animator] = nil
	end
end

local function GetAnimator(rig: Model): Animator?
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator and rig:IsDescendantOf(game) then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
		return animator
	end

	local animController = rig:FindFirstChildOfClass("AnimationController")
	if animController then
		local animator = animController:FindFirstChildOfClass("Animator")
		if not animator and rig:IsDescendantOf(game) then
			animator = Instance.new("Animator")
			animator.Parent = animController
		end
		return animator
	end

	return nil
end

local function BindCharacterCleanup(char: Model)
	task.spawn(function()
		local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
		if humanoid and humanoid:IsA("Humanoid") then
			humanoid.Died:Connect(function()
				local animator = humanoid:FindFirstChildOfClass("Animator")
				if animator then
					CleanupAnimatorTracks(animator)
				end
			end)
		end

		char.Destroying:Connect(function()
			local animator = GetAnimator(char)
			if animator then
				CleanupAnimatorTracks(animator)
			end
		end)
	end)
end

function Animation.Init()
	local preloadQueue: { Instance } = {}

	for _, entry in ipairs(Animation.Animations) do
		local formattedId = if typeof(entry.Id) == "number" then "rbxassetid://" .. tostring(entry.Id) else entry.Id

		local anim = Instance.new("Animation")
		anim.Name = entry.Name
		anim.AnimationId = formattedId

		AnimationInstances[entry.Name] = anim

		if entry.Preload == true then
			table.insert(preloadQueue, anim)
		end
	end

	task.spawn(function()
		if #preloadQueue > 0 then
			pcall(function()
				ContentProvider:PreloadAsync(preloadQueue)
			end)
		end
	end)

	if LocalPlayer.Character then
		BindCharacterCleanup(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(BindCharacterCleanup)
end

function Animation.Play(
	name: string,
	targetRig: Model?,
	fadeTime: number?,
	weight: number?,
	speed: number?
): AnimationTrack?
	local rig = targetRig or LocalPlayer.Character
	if not rig then
		return nil
	end

	local animInstance = AnimationInstances[name]
	if not animInstance then
		return nil
	end

	local animator = GetAnimator(rig)
	if not animator then
		return nil
	end

	if not LoadedTracks[animator] then
		LoadedTracks[animator] = {}

		animator.Destroying:Connect(function()
			CleanupAnimatorTracks(animator)
		end)
	end

	local track = LoadedTracks[animator][name]
	if not track then
		track = animator:LoadAnimation(animInstance)
		LoadedTracks[animator][name] = track
	end

	track:Play(fadeTime or 0.2, weight or 1, speed or 1)
	return track
end

function Animation.Stop(name: string, targetRig: Model?, fadeTime: number?)
	local rig = targetRig or LocalPlayer.Character
	if not rig then
		return
	end

	local animator = GetAnimator(rig)
	if not animator or not LoadedTracks[animator] then
		return
	end

	local track = LoadedTracks[animator][name]
	if track and track.IsPlaying then
		track:Stop(fadeTime or 0.2)
	end
end

function Animation.StopAll(targetRig: Model?, fadeTime: number?)
	local rig = targetRig or LocalPlayer.Character
	if not rig then
		return
	end

	local animator = GetAnimator(rig)
	if not animator or not LoadedTracks[animator] then
		return
	end

	for _, track in pairs(LoadedTracks[animator]) do
		if track.IsPlaying then
			track:Stop(fadeTime or 0.2)
		end
	end
end

function Animation.CleanupRig(rig: Model)
	local animator = GetAnimator(rig)
	if animator then
		CleanupAnimatorTracks(animator)
	end
end

return Animation
