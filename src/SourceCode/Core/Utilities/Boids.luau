local RunService = game:GetService("RunService")

export type BoidSettings = {
	SeparationRadius: number,
	AlignmentRadius: number,
	CohesionRadius: number,
	BoundsCenter: vector,
	BoundsSize: vector,
	MaxSpeed: number,
	MinSpeed: number,
	MaxForce: number,
	SeparationWeight: number,
	AlignmentWeight: number,
	CohesionWeight: number,
	BoundsWeight: number,
	TargetWeight: number,
	WanderWeight: number,
	ObstacleWeight: number,
	ObstacleRadius: number,
	UpdateFrequency: number,
}

export type Boid = {
	Part: Instance,
	Model: Instance?,
	Velocity: vector,
	Acceleration: vector,
	Settings: BoidSettings,
	Target: vector?,
	Update: (self: Boid, boids: { Boid }, dt: number) -> (),
	Separate: (self: Boid, boids: { Boid }) -> vector,
	Align: (self: Boid, boids: { Boid }) -> vector,
	Cohere: (self: Boid, boids: { Boid }) -> vector,
	Seek: (self: Boid, targetPos: vector) -> vector,
	StayInBounds: (self: Boid) -> vector,
	Wander: (self: Boid) -> vector,
	AvoidObstacles: (self: Boid) -> vector,
}

export type BoidSystem = {
	Boids: { Boid },
	Settings: BoidSettings,
	Running: boolean,
	UpdateConnection: RBXScriptConnection?,
	AddBoid: (self: BoidSystem, part: Instance) -> Boid,
	CreateBoids: (self: BoidSystem, template: Instance, count: number, parentFolder: Instance?) -> { Boid },
	Start: (self: BoidSystem) -> (),
	Stop: (self: BoidSystem) -> (),
	SetTarget: (self: BoidSystem, targetPosition: vector) -> (),
	Clear: (self: BoidSystem) -> (),
	SetBounds: (self: BoidSystem, center: vector, size: vector) -> (),
	UpdateSettings: (self: BoidSystem, newSettings: { [string]: any }) -> (),
}

local BoidModule = {}

local DEFAULT_SETTINGS: BoidSettings = {
	SeparationRadius = 5,
	AlignmentRadius = 10,
	CohesionRadius = 15,
	BoundsCenter = vector.zero,
	BoundsSize = vector.create(50, 25, 50),
	MaxSpeed = 10,
	MinSpeed = 5,
	MaxForce = 1,
	SeparationWeight = 1.5,
	AlignmentWeight = 1,
	CohesionWeight = 1,
	BoundsWeight = 2,
	TargetWeight = 0.5,
	WanderWeight = 1.5,
	ObstacleWeight = 5,
	ObstacleRadius = 15,
	UpdateFrequency = 1 / 60,
}

local Boid = {} :: Boid
Boid.__index = Boid

function Boid.new(instance: Instance, settings: BoidSettings): Boid
	local self = setmetatable({}, Boid)

	if instance:IsA("Model") and instance.PrimaryPart then
		self.Part = instance.PrimaryPart
		self.Model = instance
	else
		self.Part = instance
		self.Model = nil
	end

	local RandomDirection
	repeat
		RandomDirection = vector.create(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1)
	until RandomDirection.Magnitude > 0.001

	self.Velocity = RandomDirection.Unit * math.random(settings.MinSpeed, settings.MaxSpeed)
	self.Acceleration = vector.zero
	self.Settings = settings
	self.Target = nil

	return self
end

function Boid:Update(boids: { Boid }, dt: number): ()
	local separation = self:Separate(boids) * self.Settings.SeparationWeight
	local alignment = self:Align(boids) * self.Settings.AlignmentWeight
	local cohesion = self:Cohere(boids) * self.Settings.CohesionWeight
	local bounds = self:StayInBounds() * self.Settings.BoundsWeight
	local wander = self:Wander() * self.Settings.WanderWeight
	local obstacle = self:AvoidObstacles() * self.Settings.ObstacleWeight

	local target = vector.zero
	if self.Target then target = self:Seek(self.Target) * self.Settings.TargetWeight end

	self.Acceleration = self.Acceleration + separation + alignment + cohesion + bounds + wander + target + obstacle

	self.Velocity = self.Velocity + self.Acceleration * dt

	if self.Velocity.Magnitude > self.Settings.MaxSpeed then
		self.Velocity = self.Velocity.Unit * self.Settings.MaxSpeed
	elseif self.Velocity.Magnitude < self.Settings.MinSpeed then
		self.Velocity = self.Velocity.Unit * self.Settings.MinSpeed
	end

	if self.Part and self.Part.Parent then
		local newPosition = self.Part.Position + self.Velocity * dt
		local newCFrame = CFrame.lookAt(newPosition, newPosition + self.Velocity.Unit)

		if self.Model then
			self.Model:PivotTo(newCFrame)
		else
			self.Part.CFrame = newCFrame
		end
	end

	self.Acceleration = vector.zero
end

function Boid:Separate(boids: { Boid }): vector
	local steer = vector.zero
	local count = 0

	for _, boid in boids do
		if boid ~= self and boid.Part and boid.Part.Parent then
			local distance = (self.Part.Position - boid.Part.Position).Magnitude

			if distance < self.Settings.SeparationRadius and distance > 0 then
				local diff = (self.Part.Position - boid.Part.Position).Unit
				diff = diff / distance
				steer = steer + diff
				count = count + 1
			end
		end
	end

	if count > 0 then steer = steer / count end

	if steer.Magnitude > 0 then
		steer = steer.Unit * self.Settings.MaxSpeed
		steer = steer - self.Velocity
		if steer.Magnitude > self.Settings.MaxForce then steer = steer.Unit * self.Settings.MaxForce end
	end

	return steer
end

function Boid:Align(boids: { Boid }): vector
	local sum = vector.zero
	local count = 0

	for _, boid in boids do
		if boid ~= self and boid.Part and boid.Part.Parent then
			local distance = (self.Part.Position - boid.Part.Position).Magnitude

			if distance < self.Settings.AlignmentRadius and distance > 0 then
				sum = sum + boid.Velocity
				count = count + 1
			end
		end
	end

	if count > 0 then
		sum = sum / count
		sum = sum.Unit * self.Settings.MaxSpeed

		local steer = sum - self.Velocity
		if steer.Magnitude > self.Settings.MaxForce then steer = steer.Unit * self.Settings.MaxForce end
		return steer
	else
		return vector.zero
	end
end

function Boid:Cohere(boids: { Boid }): vector
	local sum = vector.zero
	local count = 0

	for _, boid in boids do
		if boid ~= self and boid.Part and boid.Part.Parent then
			local distance = (self.Part.Position - boid.Part.Position).Magnitude

			if distance < self.Settings.CohesionRadius and distance > 0 then
				sum = sum + boid.Part.Position
				count = count + 1
			end
		end
	end

	if count > 0 then
		sum = sum / count
		return self:Seek(sum)
	else
		return vector.zero
	end
end

function Boid:Seek(targetPos: vector): vector
	local desired = targetPos - self.Part.Position

	if desired.Magnitude > 0 then
		desired = desired.Unit * self.Settings.MaxSpeed

		local steer = desired - self.Velocity
		if steer.Magnitude > self.Settings.MaxForce then steer = steer.Unit * self.Settings.MaxForce end
		return steer
	else
		return vector.zero
	end
end

function Boid:StayInBounds(): vector
	local steer = vector.zero
	local halfSize = self.Settings.BoundsSize / 2
	local center = self.Settings.BoundsCenter
	local position = self.Part.Position

	if position.X < center.X - halfSize.X then
		steer = steer + vector.create(1, 0, 0)
	elseif position.X > center.X + halfSize.X then
		steer = steer + vector.create(-1, 0, 0)
	end

	if position.Y < center.Y - halfSize.Y then
		steer = steer + vector.create(0, 1, 0)
	elseif position.Y > center.Y + halfSize.Y then
		steer = steer + vector.create(0, -1, 0)
	end

	if position.Z < center.Z - halfSize.Z then
		steer = steer + vector.create(0, 0, 1)
	elseif position.Z > center.Z + halfSize.Z then
		steer = steer + vector.create(0, 0, -1)
	end

	if steer.Magnitude > 0 then
		steer = steer.Unit * self.Settings.MaxSpeed
		steer = steer - self.Velocity
		if steer.Magnitude > self.Settings.MaxForce then steer = steer.Unit * self.Settings.MaxForce end
	end

	return steer
end

function Boid:Wander(): vector
	local wanderRadius = 2
	local wanderDistance = 5
	local wanderJitter = 0.5

	local randomVec = vector.create(math.random() * 2 - 1, math.random() * 2 - 1, math.random() * 2 - 1) * wanderJitter

	local wanderDirection = (self.Velocity.Unit * wanderDistance) + (randomVec.Unit * wanderRadius)

	return self:Seek(self.Part.Position + wanderDirection)
end

function Boid:AvoidObstacles(): vector
	local steer = vector.zero

	local direction = self.Velocity.Unit
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { self.Model or self.Part }

	local forwardResult = workspace:Raycast(self.Part.Position, direction * self.Settings.ObstacleRadius, raycastParams)

	local downResult = workspace:Raycast(self.Part.Position, vector.create(0, -self.Settings.ObstacleRadius, 0), raycastParams)

	if forwardResult then
		local distanceToObstacle = forwardResult.Distance
		local avoidanceStrength = 1 - (distanceToObstacle / self.Settings.ObstacleRadius)
		local normal = forwardResult.Normal

		local avoidanceForce = normal * self.Settings.MaxSpeed * avoidanceStrength
		steer = steer + avoidanceForce
	end

	if downResult then
		local distanceToFloor = downResult.Distance
		local minHeightAboveGround = 4

		if distanceToFloor < minHeightAboveGround then
			local upStrength = (1 - (distanceToFloor / minHeightAboveGround)) * self.Settings.MaxSpeed
			steer = steer + vector.create(0, upStrength, 0)
		end
	end

	if steer.Magnitude > 0 then
		if steer.Magnitude > self.Settings.MaxForce then steer = steer.Unit * self.Settings.MaxForce end
	end

	return steer
end

local BoidSystem = {} :: BoidSystem
BoidSystem.__index = BoidSystem

function BoidModule.new(settings: { [string]: any }?): BoidSystem
	local self = setmetatable({}, BoidSystem)

	self.Boids = {}
	self.Settings = settings or {}

	for key, value in DEFAULT_SETTINGS do
		if self.Settings[key] == nil then self.Settings[key] = value end
	end

	self.Running = false
	self.UpdateConnection = nil

	return self
end

function BoidSystem:AddBoid(part: Instance): Boid
	local boid = Boid.new(part, self.Settings)
	table.insert(self.Boids, boid)
	return boid
end

function BoidSystem:CreateBoids(template: Instance, count: number, parentFolder: Instance?): { Boid }
	local results: { Boid } = {}

	for i = 1, count do
		local newInstance = template:Clone()

		local halfSize = self.Settings.BoundsSize / 2
		local center = self.Settings.BoundsCenter

		local positionVec = vector.create(
			center.X + (math.random() * self.Settings.BoundsSize.X - halfSize.X),
			center.Y + (math.random() * self.Settings.BoundsSize.Y - halfSize.Y),
			center.Z + (math.random() * self.Settings.BoundsSize.Z - halfSize.Z)
		)

		if newInstance:IsA("Model") and newInstance.PrimaryPart then
			newInstance:PivotTo(CFrame.new(positionVec))
		else
			newInstance.Position = positionVec
		end

		newInstance.Parent = parentFolder or workspace

		local boid = self:AddBoid(newInstance)
		table.insert(results, boid)
	end

	return results
end

function BoidSystem:Start()
	if self.Running then return end

	self.Running = true

	local lastUpdate = tick()

	self.UpdateConnection = RunService.PreRender:Connect(function()
		local now = tick()
		local elapsed = math.min(now - lastUpdate, 0.1)

		if elapsed >= self.Settings.UpdateFrequency then
			lastUpdate = now

			for _, boid in self.Boids do
				if boid.Part and boid.Part.Parent then boid:Update(self.Boids, elapsed) end
			end
		end
	end)
end

function BoidSystem:Stop()
	if not self.Running then return end

	self.Running = false

	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end
end

function BoidSystem:SetTarget(targetPosition)
	for _, boid in self.Boids do
		boid.Target = targetPosition
	end
end

function BoidSystem:Clear()
	self:Stop()

	for _, boid in self.Boids do
		if boid.Part then boid.Part:Destroy() end
	end

	self.Boids = {}
end

function BoidSystem:SetBounds(center, size)
	self.Settings.BoundsCenter = center
	self.Settings.BoundsSize = size
end

function BoidSystem:UpdateSettings(newSettings)
	for key, value in newSettings do
		self.Settings[key] = value
	end
end

return BoidModule
