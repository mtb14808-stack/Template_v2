export type String = {
	Capitalize: (str: string) -> string,
	Truncate: (str: string, maxLength: number) -> string,
	RemoveWhitespace: (str: string) -> string,
	GenerateID: (length: number?) -> string,
	CountChars: (str: string) -> number,
	ContainsChar: (str: string, char: string) -> boolean,
	CountOccurrences: (str: string, char: string) -> number,
	ToFormatName: (str: string) -> string,
	FilterOnlyAlpha: (str: string) -> string,
}

local String = {}

function String.Capitalize(str: string): string
	return (str:sub(1, 1):upper() .. str:sub(2):lower())
end

function String.Truncate(str: string, maxLength: number): string
	if #str > maxLength then
		return str:sub(1, maxLength - 3) .. "..."
	end
	return str
end

function String.RemoveWhitespace(str: string): string
	return str:gsub("%s+", "")
end

function String.GenerateID(length: number?): string
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local randomID = ""
	local rand = Random.new()
	local targetLength = length or 10

	for i = 1, targetLength do
		local r = rand:NextInteger(1, #chars)
		randomID ..= chars:sub(r, r)
	end
	return randomID
end

function String.CountChars(str: string): number
	return #str
end

function String.ContainsChar(str: string, char: string): boolean
	return str:find(char, 1, true) ~= nil
end

function String.CountOccurrences(str: string, char: string): number
	local _, count = str:gsub(char, "")
	return count
end

function String.ToFormatName(str: string): string
	local words = str:gsub("[_-]", " "):split(" ")
	for i, v in ipairs(words) do
		words[i] = String.Capitalize(v)
	end
	return table.concat(words, " ")
end

function String.FilterOnlyAlpha(str: string): string
	return str:gsub("%A", "")
end

return String
