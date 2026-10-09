--!strict

type GuardPredicate = (attributeName: string, value: any) -> boolean

local function defaultGuard(_attributeName: string, _value: any): boolean return true end

--[=[
	Creates an observer that watches all attributes on a given instance.
	Your callback is invoked for existing attributes on start and
	for every subsequent change where guard(attributeName, value) returns true.

	-- Only observe numeric attributes
	local stop = observeAllAttributes(
		workspace.Part,
		function(name, value)
			print(name, "=", value)
			return function()
				print(name, "was removed or no longer passes guard")
			end
		end,
		function(name, value)
			return typeof(value) == "number"
		end
	)
	
	Returns a function that stops observing and runs any outstanding cleanup callbacks.
]=]
local function observeAllAttributes(instance: any, callback: (attributeName: string, value: any) -> (() -> ())?, guardPredicate: GuardPredicate?): () -> ()
	local cleanupFunctionsPerAttribute: { [string]: () -> () } = {}
	local attributeGuard: GuardPredicate = if guardPredicate ~= nil then guardPredicate else defaultGuard
	local attributeChangedConnection: RBXScriptConnection

	local function onAttributeChanged(attributeName: string)
		-- Tear down any prior callback for this attribute
		local previousCleanup = cleanupFunctionsPerAttribute[attributeName]
		if typeof(previousCleanup) == "function" then
			task.spawn(previousCleanup)
			cleanupFunctionsPerAttribute[attributeName] = nil
		end

		-- Fire new callback if guard passes
		local newValue = instance:GetAttribute(attributeName)
		if newValue ~= nil and attributeGuard(attributeName, newValue) then
			task.spawn(function()
				local cleanup = callback(attributeName, newValue)
				if typeof(cleanup) == "function" then
					-- Only keep it if we're still connected and the value hasn't changed again
					if attributeChangedConnection.Connected and instance:GetAttribute(attributeName) == newValue then
						cleanupFunctionsPerAttribute[attributeName] = cleanup
					else
						task.spawn(cleanup)
					end
				end
			end)
		end
	end

	-- Connect the global AttributeChanged event
	attributeChangedConnection = instance.AttributeChanged:Connect(onAttributeChanged)

	-- Seed with existing attributes
	task.defer(function()
		if not attributeChangedConnection.Connected then return end
		for name, _value in instance:GetAttributes() do
			onAttributeChanged(name)
		end
	end)

	-- Return a stopper that disconnects and cleans up everything
	return function()
		attributeChangedConnection:Disconnect()
		for name, cleanup in pairs(cleanupFunctionsPerAttribute) do
			cleanupFunctionsPerAttribute[name] = nil
			if typeof(cleanup) == "function" then task.spawn(cleanup) end
		end
	end
end

return observeAllAttributes
