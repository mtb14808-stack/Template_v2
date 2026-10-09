local Number = {}

export type NumberModule = {
	GenerateID: (length: number) -> number,
}

function Number.GenerateID(length: number): number
	local str = ""
	for _ = 1, length do
		str ..= tostring(math.random(0, 9))
	end
	return tonumber(str) :: number
end

return Number
