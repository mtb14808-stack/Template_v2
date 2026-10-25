local HttpService = game:GetService("HttpService")

export type Http = {
	GetID: () -> string,
	Get: (url: string) -> any?,
	Post: (url: string, dataTable: { [string]: any }) -> any?,
}

local Http: Http = {} :: any

function Http.GetID(): string
	return HttpService:GenerateGUID()
end

function Http.Get(url: string): any?
	local success, response = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if success then
		local decodeSuccess, decodedData = pcall(function()
			return HttpService:JSONDecode(response)
		end)

		if decodeSuccess then
			return decodedData
		else
			warn("Errore durante il Decode JSON: " .. tostring(response))
			return nil
		end
	else
		warn("HTTP GET ERROR [" .. url .. "]: " .. tostring(response))
		return nil
	end
end

function Http.Post(url: string, dataTable: { [string]: any }): any?
	local jsonPayload = HttpService:JSONEncode(dataTable)

	local success, response = pcall(function()
		return HttpService:PostAsync(url, jsonPayload, Enum.HttpContentType.ApplicationJson)
	end)

	if success then
		local decodeSuccess, decodedData = pcall(function()
			return HttpService:JSONDecode(response)
		end)

		return decodeSuccess and decodedData or response
	else
		warn("HTTP POST ERROR: " .. tostring(response))
		return nil
	end
end

return Http
