--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local MenuState = require(ReplicatedStorage.SourceCode.Client.App.Sources.MenuState)

local ClientFolder = ReplicatedStorage.SourceCode.Client

type ComponentModule = {
	menuId: string,
	Component: (props: { present: () -> boolean }) -> any,
	alwaysMounted: boolean?,
	destroyDelay: number?,
}

local alwaysMountedComponents = {}
local lazyComponents: { [string]: ComponentModule } = {}
local isInitialized = false

local function registerModule(moduleScript: ModuleScript)
	if not moduleScript:IsA("ModuleScript") or moduleScript == script then
		return
	end

	local success, lib: ComponentModule = pcall(require, moduleScript)
	if not success then
		warn("[MenuRoot] Errore nel caricamento del modulo " .. moduleScript.Name .. ": " .. tostring(lib))
		return
	end

	if type(lib) ~= "table" or not lib.menuId or not lib.Component then
		return
	end

	if lib.alwaysMounted then
		table.insert(
			alwaysMountedComponents,
			lib.Component({
				present = function()
					return true
				end,
			})
		)
		MenuState.registerAlwaysMounted(lib.menuId)
		return
	end

	lazyComponents[lib.menuId] = lib
end

return function()
	if not isInitialized then
		isInitialized = true
		for _, descendant in ipairs(ClientFolder:GetDescendants()) do
			registerModule(descendant)
		end
	end

	local children: { any } = {
		alwaysMountedComponents,
		Vide.indexes(function()
			local current = MenuState.openedMenu()
			return if current then { current } else {}
		end, function(menuIdStr: () -> string, present: () -> boolean)
			local id = menuIdStr()
			local config = lazyComponents[id]
			if config then
				local delayTime = config.destroyDelay or 0.35
				return config.Component({ present = present }), delayTime
			end
			return nil
		end),
	}

	return children
end
