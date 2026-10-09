--!strict

type GuardPredicate = (child: any) -> boolean

local function defaultChildGuard(_child: any): boolean return true end

--[=[
	Creates an observer that captures each child for the given instance.
	An optional `guard` predicate can be supplied to filter which children trigger the observer.

	```lua
	-- Only observe Parts
	observeChildren(
		workspace,
		function(child)
			print("Part added:", child:GetFullName())
			return function()
				print("Part removed (or observer stopped):", child:GetFullName())
			end
		end,
		function(child)
			return child:IsA("Part")
		end
	)
	```
]=]
local function observeChildren(instance: any, callback: (child: any) -> (() -> ())?, guard: GuardPredicate?): () -> ()
	local childAddedConn: RBXScriptConnection
	local childRemovedConn: RBXScriptConnection

	-- Map each child to its cleanup function
	local cleanupFunctionsPerChild: { [Instance]: () -> () } = {}

	-- Choose the guard (either the one passed in, or a default that always returns true)
	local childGuard: GuardPredicate = if guard ~= nil then guard else defaultChildGuard

	-- Fires when a new child appears
	local function OnChildAdded(child: Instance)
		-- skip if the observer was already disconnected
		if not childAddedConn.Connected then return end

		-- skip if guard rejects this child
		if not childGuard(child) then return end

		task.spawn(function()
			local cleanup = callback(child)
			if typeof(cleanup) == "function" then
				-- only keep the cleanup if child is still parented and we're still observing
				if childAddedConn.Connected and child.Parent ~= nil then
					cleanupFunctionsPerChild[child] = cleanup
				else
					-- otherwise run it immediately
					task.spawn(cleanup)
				end
			end
		end)
	end

	-- Fires when a child is removed
	local function OnChildRemoved(child: Instance)
		local cleanup = cleanupFunctionsPerChild[child]
		cleanupFunctionsPerChild[child] = nil
		if typeof(cleanup) == "function" then task.spawn(cleanup) end
	end

	-- Connect events
	childAddedConn = instance.ChildAdded:Connect(OnChildAdded)
	childRemovedConn = instance.ChildRemoved:Connect(OnChildRemoved)

	-- Fire for existing children
	task.defer(function()
		if not childAddedConn.Connected then return end
		for _, child in instance:GetChildren() do
			OnChildAdded(child)
		end
	end)

	-- Return a disconnect function
	return function()
		childAddedConn:Disconnect()
		childRemovedConn:Disconnect()

		-- Clean up any remaining children
		for child, _ in pairs(cleanupFunctionsPerChild) do
			OnChildRemoved(child)
		end
	end
end

return observeChildren
