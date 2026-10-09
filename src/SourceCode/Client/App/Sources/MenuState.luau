--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HudSource = require(ReplicatedStorage.SourceCode.Client.Hud.UI.Sources.HudSource)

local Vide = require(ReplicatedStorage.Packages.Vide)

local LocalPlayer = Players.LocalPlayer

local openedMenu = Vide.source(nil :: string?) :: () -> string?

local DisableState = false
local lastSavedMenu: string? = nil
local lastSavedHudState: boolean? = nil
local lastSavedBlur: boolean? = nil
local lastSavedFov: boolean? = nil

local BLUR_SIZE = 10
local TARGET_FOV = 90
local DEFAULT_FOV = 70

local blurInstance: BlurEffect? = nil
local activeBlurTween: Tween? = nil
local activeFovTween: Tween? = nil
local currentTargetFov = DEFAULT_FOV
local isBlurActive = false
local isFovActive = false

local AlwaysMountedMenus: { [string]: boolean } = {}

local TWEEN_INFO = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function getOrCreateBlur(): BlurEffect
	if not blurInstance then
		local existing = Lighting:FindFirstChild("MenuBlurEffect") :: BlurEffect?
		if existing then
			blurInstance = existing
		else
			local newBlur = Instance.new("BlurEffect")
			newBlur.Name = "MenuBlurEffect"
			newBlur.Size = 0
			newBlur.Enabled = true
			newBlur.Parent = Lighting
			blurInstance = newBlur
		end
	end
	return blurInstance
end

local function applyBlur(enable: boolean)
	isBlurActive = enable
	local blur = getOrCreateBlur()

	if activeBlurTween then
		activeBlurTween:Cancel()
		activeBlurTween = nil
	end

	local targetSize = if enable then BLUR_SIZE else 0
	activeBlurTween = TweenService:Create(blur, TWEEN_INFO, { Size = targetSize })
	activeBlurTween:Play()
end

local function applyCameraFov(enable: boolean)
	isFovActive = enable
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	if activeFovTween then
		activeFovTween:Cancel()
		activeFovTween = nil
	end

	currentTargetFov = if enable then TARGET_FOV else DEFAULT_FOV
	activeFovTween = TweenService:Create(camera, TWEEN_INFO, { FieldOfView = currentTargetFov })
	activeFovTween:Play()
end

if LocalPlayer then
	LocalPlayer.CharacterAdded:Connect(function()
		task.defer(function()
			local camera = Workspace.CurrentCamera
			if camera and currentTargetFov ~= DEFAULT_FOV then
				camera.FieldOfView = currentTargetFov
			end
		end)
	end)
end

local function registerAlwaysMounted(menuId: string)
	AlwaysMountedMenus[menuId] = true
end

local function isAlwaysMounted(menuId: string?): boolean
	if not menuId then
		return false
	end
	return AlwaysMountedMenus[menuId] == true
end

local function DisableMenusHud()
	if DisableState then
		return
	end
	DisableState = true

	local currentMenu = openedMenu()
	lastSavedMenu = currentMenu
	lastSavedHudState = HudSource.HudSource()
	lastSavedBlur = isBlurActive
	lastSavedFov = isFovActive

	if currentMenu ~= nil then
		openedMenu(nil)
	end

	applyBlur(false)
	applyCameraFov(false)
	HudSource.HandleHud(true)
end

local function EnableMenusHud()
	if not DisableState then
		return
	end
	DisableState = false

	local menuToRestore = lastSavedMenu
	local hudToRestore = if lastSavedHudState ~= nil then lastSavedHudState else false
	local blurToRestore = if lastSavedBlur ~= nil then lastSavedBlur else false
	local fovToRestore = if lastSavedFov ~= nil then lastSavedFov else false

	lastSavedMenu = nil
	lastSavedHudState = nil
	lastSavedBlur = nil
	lastSavedFov = nil

	if menuToRestore ~= nil then
		openedMenu(menuToRestore)
	end

	applyBlur(blurToRestore)
	applyCameraFov(fovToRestore)
	HudSource.HandleHud(hudToRestore)
end

local function GetDisableState(): boolean
	return DisableState
end

local function setOpenedMenu(menuId: string?, closeHud: boolean?, useBlur: boolean?, useCameraFov: boolean?)
	if DisableState then
		return
	end

	local currentMenu = openedMenu()

	if currentMenu ~= nil and currentMenu == menuId then
		menuId = nil
	end

	openedMenu(menuId)

	if menuId == nil then
		applyBlur(false)
		applyCameraFov(false)
	else
		applyBlur(useBlur == true)
		applyCameraFov(useCameraFov == true)
	end

	local shouldClose = if closeHud ~= nil then closeHud else false
	HudSource.HandleHud(shouldClose)
end

local function closeCurrentMenu(reopenHud: boolean?)
	setOpenedMenu(nil, if reopenHud ~= nil then not reopenHud else false)
end

return {
	openedMenu = openedMenu,
	setOpenedMenu = setOpenedMenu,
	closeCurrentMenu = closeCurrentMenu,
	DisableMenusHud = DisableMenusHud,
	EnableMenusHud = EnableMenusHud,
	GetDisableState = GetDisableState,
	registerAlwaysMounted = registerAlwaysMounted,
	isAlwaysMounted = isAlwaysMounted,
}
