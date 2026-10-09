export type RNG = {
	SafeInteger: (min: number, max: number) -> number,
	SafeNextNumber: () -> number,
	SafeNumberRange: (min: number, max: number) -> number,
	SafeChance: (percentage: number) -> boolean,
}

local HttpService = game:GetService("HttpService")

local RNG = {}

local MAX_HEX_VALUE = 0xFFFFFFFF

local function GetSecureEntropy(): number
	local guid = HttpService:GenerateGUID(false)
	local cleanHex = string.gsub(guid, "-", "")
	local subHex = string.sub(cleanHex, 1, 8)
	return tonumber(subHex, 16) or os.clock()
end

function RNG.SafeInteger(min: number, max: number): number
	assert(min <= max, "Minimum value cannot be greater than maximum value")

	local entropy = GetSecureEntropy()
	local range = (max - min) + 1

	return min + (math.floor(entropy) % range)
end

function RNG.SafeNextNumber(): number
	local entropy = GetSecureEntropy()
	return entropy / MAX_HEX_VALUE
end

function RNG.SafeNumberRange(min: number, max: number): number
	assert(min <= max, "Minimum value cannot be greater than maximum value")

	local alpha = RNG.SafeNextNumber()
	return min + (max - min) * alpha
end

function RNG.SafeChance(percentage: number): boolean
	assert(percentage >= 0 and percentage <= 100, "Percentage must be between 0 and 100")

	local roll = RNG.SafeNumberRange(0, 100)
	return roll <= percentage
end

return RNG
