return function(cooldown: number, callback: (...any) -> ())
	local lastCall = 0

	return function(...)
		local now = os.clock()
		if now - lastCall >= cooldown then
			lastCall = now
			callback(...)
		end
	end
end
