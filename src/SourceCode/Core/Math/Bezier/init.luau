local Visualize = require(script.Visualize)
local Bezier = {}

function Bezier.Linear(t, p0, p1, visualize: boolean?, color: Color3?, duration: number?)
	local pos = p0 + (p1 - p0) * t
	if visualize then
		Visualize.DrawPoint(pos, color, duration)
	end
	return pos
end

function Bezier.Quadratic(t, p0, p1, p2, visualize: boolean?, color: Color3?, duration: number?)
	local invT = 1 - t
	local pos = invT ^ 2 * p0 + 2 * invT * t * p1 + t ^ 2 * p2
	if visualize then
		local tan = Bezier.QuadraticTangent(t, p0, p1, p2)
		Visualize.DrawPoint(CFrame.lookAlong(pos, tan), color, duration)
	end
	return pos
end

function Bezier.Cubic(t, p0, p1, p2, p3, visualize: boolean?, color: Color3?, duration: number?)
	local invT = 1 - t
	local pos = invT ^ 3 * p0 + 3 * invT ^ 2 * t * p1 + 3 * invT * t ^ 2 * p2 + t ^ 3 * p3
	if visualize then
		local tan = Bezier.CubicTangent(t, p0, p1, p2, p3)
		Visualize.DrawPoint(CFrame.lookAlong(pos, tan), color, duration)
	end
	return pos
end

function Bezier.VisualizeLinear(p0, p1, res, color, duration)
	res = res or 20
	for i = 0, res do
		Bezier.Linear(i / res, p0, p1, true, color, duration)
	end
end

function Bezier.VisualizeQuadratic(p0, p1, p2, res, color, duration)
	res = res or 20
	for i = 0, res do
		Bezier.Quadratic(i / res, p0, p1, p2, true, color, duration)
	end
end

function Bezier.VisualizeCubic(p0, p1, p2, p3, res, color, duration)
	res = res or 20
	for i = 0, res do
		Bezier.Cubic(i / res, p0, p1, p2, p3, true, color, duration)
	end
end

function Bezier.QuadraticTangent(t, p0, p1, p2)
	return (2 * (1 - t) * (p1 - p0) + 2 * t * (p2 - p1)).Unit
end

function Bezier.CubicTangent(t, p0, p1, p2, p3)
	local invT = 1 - t
	return (3 * invT ^ 2 * (p1 - p0) + 6 * invT * t * (p2 - p1) + 3 * t ^ 2 * (p3 - p2)).Unit
end

function Bezier.GetLength(p0, p1, p2, resolution)
	local length = 0
	local res = resolution or 10
	local lastPoint = p0
	for i = 1, res do
		local t = i / res
		local current = Bezier.Quadratic(t, p0, p1, p2)
		length += (current - lastPoint).Magnitude
		lastPoint = current
	end
	return length
end

function Bezier.GetControlPoint(p0, p2, height, offset)
	local mid = (p0 + p2) / 2
	local up = Vector3.new(0, height or 10, 0)
	local side = offset or Vector3.new(0, 0, 0)
	return mid + up + side
end

function Bezier.GetCFrame(t, p0, p1, p2)
	local pos = Bezier.Quadratic(t, p0, p1, p2)
	local tangent = Bezier.QuadraticTangent(t, p0, p1, p2)
	return CFrame.lookAlong(pos, tangent)
end

return Bezier
