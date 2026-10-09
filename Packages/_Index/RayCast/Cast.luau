local WorkspaceService = game:GetService("Workspace")
local Visualize = require(script.Parent.Visualize)
local DEBUG_FOLDER_NAME = "RayCastDebug"
local Cast = {}

local function GetSafeParams(list, filterType)
	local enumValue = Enum.RaycastFilterType.Exclude
	if typeof(filterType) == "string" then
		pcall(function()
			enumValue = Enum.RaycastFilterType[filterType]
		end)
	end

	local finalTable = typeof(list) == "table" and table.clone(list) or {}
	local debugFolder = WorkspaceService:FindFirstChild(DEBUG_FOLDER_NAME)

	if debugFolder then
		table.insert(finalTable, debugFolder)
	end

	local rp = RaycastParams.new()
	rp.FilterDescendantsInstances = finalTable
	rp.FilterType = enumValue
	return rp
end

function Cast.RayCast(Origin: Vector3, Direction: Vector3, List: {}, Type: string, Debug: boolean): RaycastResult?
	if typeof(Origin) ~= "Vector3" or typeof(Direction) ~= "Vector3" then
		return nil
	end
	local params = GetSafeParams(List, Type)
	if not params then
		return nil
	end
	if Debug then
		Visualize.VisualizeNormalCast(Origin, Direction)
	end
	return WorkspaceService:Raycast(Origin, Direction, params)
end

function Cast.SphereCast(
	Origin: Vector3,
	Direction: Vector3,
	Radius: number,
	List: {},
	Type: string,
	Debug: boolean
): RaycastResult?
	if typeof(Origin) ~= "Vector3" or typeof(Direction) ~= "Vector3" or typeof(Radius) ~= "number" then
		return nil
	end
	local params = GetSafeParams(List, Type)
	if not params then
		return nil
	end
	local Results = WorkspaceService:Spherecast(Origin, Radius, Direction, params)
	if Debug then
		Visualize.VisualizeSphereCast(Origin, Direction, Radius, Results)
	end
	return Results
end

function Cast.ShapeCast(
	CF: CFrame,
	Size: Vector3,
	Direction: Vector3,
	List: {},
	Type: string,
	Debug: boolean
): RaycastResult?
	if typeof(CF) ~= "CFrame" or typeof(Size) ~= "Vector3" or typeof(Direction) ~= "Vector3" then
		return nil
	end
	local params = GetSafeParams(List, Type)
	if not params then
		return nil
	end
	if Debug then
		Visualize.VisualizeShapeCast(CF, Size, Direction)
	end
	return WorkspaceService:Blockcast(CF, Size, Direction, params)
end

return Cast
