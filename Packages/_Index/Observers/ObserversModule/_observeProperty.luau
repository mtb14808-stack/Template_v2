--!strict

local function defaultValueGuard(_value: any): boolean return true end

--[=[
	@within Observers

	Creates an observer around a property of a given instance.
	An optional `guard` predicate can be supplied to filter which values trigger the observer.

	```lua
	-- Only observe Name changes when they’re non-empty strings
	local stop = observeProperty(
		workspace.Model,
		"Name",
		function(newName: string)
			print("New name:", newName)
			return function()
				print("Name changed away from:", newName)
			end
		end,
		function(value)
			return typeof(value) == "string" and #value > 0
		end
	)
	```

	Returns a function that stops observing and runs any outstanding cleanup.
]=]
local function observeProperty(instance: Instance, propertyName: string, callback: (value: any) -> () -> (), guard: ((value: any) -> boolean)?): () -> ()
	local cleanFn: (() -> ())?
	local propChangedConn: RBXScriptConnection
	local changeCounter = 0

	-- decide which guard to use
	local valueGuard: (value: any) -> boolean = if guard ~= nil then guard else defaultValueGuard

	local function onPropertyChanged()
		-- run previous cleanup (if any)
		if cleanFn then
			task.spawn(cleanFn)
			cleanFn = nil
		end

		changeCounter += 1
		local currentId = changeCounter
		local newValue = (instance :: any)[propertyName]

		-- only proceed if guard passes
		if valueGuard(newValue) then
			task.spawn(function()
				local cleanup = callback(newValue)
				-- if nothing else has changed and we're still connected, keep it
				if currentId == changeCounter and propChangedConn.Connected then
					cleanFn = cleanup
				else
					-- otherwise run it immediately
					task.spawn(cleanup)
				end
			end)
		end
	end

	-- connect to the property‑changed signal
	propChangedConn = instance:GetPropertyChangedSignal(propertyName):Connect(onPropertyChanged)

	-- fire once on startup
	task.defer(function()
		if propChangedConn.Connected then onPropertyChanged() end
	end)

	-- return stop function
	return function()
		propChangedConn:Disconnect()
		if cleanFn then
			task.spawn(cleanFn)
			cleanFn = nil
		end
	end
end

return observeProperty
