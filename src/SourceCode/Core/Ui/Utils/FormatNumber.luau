export type FormatNumber = {
	Abbreviate: (value: number) -> string,
	Comma: (value: number) -> string,
	Round: (value: number, decimals: number?) -> number,
	Map: (value: number, inMin: number, inMax: number, outMin: number, outMax: number) -> number,
}

local FormatNumber = {}

local SUFFIXES = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Q",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc",
	"Ud",
	"Dd",
	"Td",
	"Qad",
	"Qid",
	"Sxd",
	"Spd",
	"Ocd",
	"Nod",
	"Vg",
	"Uvg",
	"Dvg",
	"Tvg",
	"Qavg",
	"Qivg",
	"Sxvg",
	"Spvg",
	"Ocvg",
	"Novg",
	"Tg",
	"Utg",
	"Dtg",
	"Ttg",
	"Qatg",
	"Qitg",
	"Sxtg",
	"Sptg",
	"Octg",
	"Notg",
	"Qag",
	"Uqag",
	"Dqag",
	"Tqag",
	"Qaqag",
	"Qiqag",
	"Sxqag",
	"Spqag",
	"Ocqag",
	"Noqag",
	"Qig",
	"Uqig",
	"Dqig",
	"Tqig",
	"Qaqig",
	"Qiqig",
	"Sxqig",
	"Spqig",
	"Ocqig",
	"Noqig",
	"Sxg",
	"Usxg",
	"Dsxg",
	"Tsxg",
	"Qasxg",
	"Qisxg",
	"Sxsxg",
	"Spsxg",
	"Ocsxg",
	"Nosxg",
	"Spg",
	"Uspg",
	"Dspg",
	"Tspg",
	"Qaspg",
	"Qispg",
	"Sxspg",
	"Spspg",
	"Ocspg",
	"Nospg",
	"Ocg",
	"Uocg",
	"Docg",
	"Tocg",
	"Qaocg",
	"Qiocg",
	"Sxocg",
	"Spocg",
	"Ococg",
	"Noocg",
	"Nog",
	"Unog",
	"Dnog",
	"Tnog",
	"Qanog",
	"Qinog",
	"Sxnog",
	"Spnog",
	"Ocnog",
	"Nonog",
	"Ct",
}

function FormatNumber.Abbreviate(value: number): string
	local absValue = math.abs(value)
	if absValue >= 1e303 then
		return "INF"
	end
	if absValue < 1000 then
		return tostring(value)
	end

	local exponent = math.floor(math.log10(absValue) / 3)
	local suffix = SUFFIXES[exponent + 1]

	if not suffix then
		return "INF"
	end

	local base = value / (10 ^ (exponent * 3))
	return string.format("%.2f%s", base, suffix):gsub("%.00", "")
end

function FormatNumber.Comma(value: number): string
	if math.abs(value) >= 1e303 then
		return "INF"
	end
	local formatted = tostring(math.floor(value))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

function FormatNumber.Round(value: number, decimals: number?): number
	local mult = 10 ^ (decimals or 0)
	return math.floor(value * mult + 0.5) / mult
end

function FormatNumber.Map(value: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

return FormatNumber
