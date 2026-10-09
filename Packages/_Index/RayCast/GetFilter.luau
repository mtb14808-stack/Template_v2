local GetFilter = {}

function GetFilter.FilterAllPlayers()
	local Filter = {}
	for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
		if Player.Character then table.insert(Filter, Player.Character) end
	end
	return Filter
end

function GetFilter.FilterPlayer(PlayerName: string)
	local Filter = {}
	local Player = game:GetService("Players"):FindFirstChild(PlayerName)
	if Player and Player.Character then table.insert(Filter, Player.Character) end
	return Filter
end

function GetFilter.ByFolder(Folder: Instance) return (typeof(Folder) == "Instance" and Folder:IsA("Folder")) and { Folder } or {} end

function GetFilter.CreateList(...)
	local FinalList = {}
	local Args = { ... }

	for _, Arg in ipairs(Args) do
		local DataToInsert = nil

		if type(Arg) == "string" then
			if Arg == "Players" and type(GetFilter.FilterAllPlayers) == "function" then
				DataToInsert = GetFilter.FilterAllPlayers()
			elseif type(GetFilter[Arg]) == "function" then
				DataToInsert = GetFilter[Arg]()
			elseif type(GetFilter["Filter" .. Arg]) == "function" then
				DataToInsert = GetFilter["Filter" .. Arg]()
			else
				DataToInsert = GetFilter.FilterPlayer(Arg)
			end
		elseif type(Arg) == "function" then
			DataToInsert = Arg()
		elseif typeof(Arg) == "Instance" and Arg:IsA("Folder") then
			DataToInsert = GetFilter.ByFolder(Arg)
		elseif type(Arg) == "table" then
			DataToInsert = Arg
		end

		if DataToInsert and type(DataToInsert) == "table" then
			for i = 1, #DataToInsert do
				table.insert(FinalList, DataToInsert[i])
			end
		end
	end

	return FinalList
end

return GetFilter
