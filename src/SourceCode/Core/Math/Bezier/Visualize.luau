local Debris = game:GetService("Debris")

local Visualize = {}

local DEFAULT_DURATION = 1.5
local DEFAULT_COLOR = Color3.fromRGB(255, 0, 0)

local debugFolder = workspace:FindFirstChild("BezierCurveDebug") or Instance.new("Folder", workspace)
debugFolder.Name = "BezierCurveDebug"

function Visualize.DrawPoint(cf, color, duration, size)
	local part = Instance.new("Part")
	part.Name = "DebugPoint"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Size = size or Vector3.new(0.4, 0.4, 0.4)
	part.Color = color or DEFAULT_COLOR
	part.Material = Enum.Material.Neon

	part.CFrame = typeof(cf) == "CFrame" and cf or CFrame.new(cf)
	part.Parent = debugFolder

	Debris:AddItem(part, duration or DEFAULT_DURATION)
end

function Visualize.DrawControlPoint(pos, color, duration)
	local ctrl = Instance.new("Part")
	ctrl.Shape = Enum.PartType.Ball
	ctrl.Size = Vector3.new(0.6, 0.6, 0.6)
	ctrl.Anchored = true
	ctrl.CanCollide = false
	ctrl.Color = color or Color3.new(1, 1, 1)
	ctrl.Material = Enum.Material.SmoothPlastic
	ctrl.Position = pos
	ctrl.Parent = debugFolder
	Debris:AddItem(ctrl, duration or DEFAULT_DURATION)
end

return Visualize
