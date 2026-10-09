export type FormatTime = {
	FormatHMS: (seconds: number) -> string,
	FormatMS: (seconds: number) -> string,
	ToReadable: (seconds: number) -> string,
	GetTimeLeft: (futureTimestamp: number) -> number,
}

local FormatTime = {}

function FormatTime.FormatHMS(seconds: number): string
	local hours = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hours, mins, secs)
end

function FormatTime.FormatMS(seconds: number): string
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", mins, secs)
end

function FormatTime.ToReadable(seconds: number): string
	if seconds <= 0 then
		return "0s"
	end

	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)

	if days > 0 then
		return string.format("%dd %dh", days, hours)
	elseif hours > 0 then
		return string.format("%dh %dm", hours, mins)
	elseif mins > 0 then
		return string.format("%dm %ds", mins, secs)
	else
		return string.format("%ds", secs)
	end
end

function FormatTime.GetTimeLeft(futureTimestamp: number): number
	local diff = futureTimestamp - os.time()
	return math.max(0, diff)
end

return FormatTime
