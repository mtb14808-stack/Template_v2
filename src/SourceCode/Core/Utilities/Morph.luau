export type Morph = {
	MorphPlayer: (player: Player, morphModel: Model) -> (),
	MorphPlayerByDummy: (player: Player, dummy: Model) -> (),
}

local Morph = {} :: Morph

local function getCharacter(player: Player): Model
	return player.Character or player.CharacterAdded:Wait()
end

function Morph.MorphPlayer(player: Player, morphModel: Model)
	if not player or not player:IsA("Player") then
		return
	end

	if not morphModel or not morphModel:IsA("Model") then
		warn("[Morph]: Invalid Morph model provided.")
		return
	end

	local oldChar = getCharacter(player)
	local oldHumanoid = oldChar:WaitForChild("Humanoid", 5) :: Humanoid?
	local oldRoot = oldChar:WaitForChild("HumanoidRootPart", 5) :: BasePart?

	if not oldHumanoid or not oldRoot then
		warn("[Morph]: Old character is invalid or incomplete.")
		return
	end

	local savedCFrame = oldRoot.CFrame
	local savedHealth = oldHumanoid.Health
	local savedMaxHealth = oldHumanoid.MaxHealth
	local savedWalkSpeed = oldHumanoid.WalkSpeed
	local savedJumpPower = oldHumanoid.JumpPower
	local savedJumpHeight = oldHumanoid.JumpHeight

	local newChar = morphModel:Clone()
	newChar.Name = player.Name

	local newRoot = newChar:WaitForChild("HumanoidRootPart", 5) :: BasePart?
	local newHumanoid = newChar:WaitForChild("Humanoid", 5) :: Humanoid?

	if not newRoot or not newHumanoid then
		warn("[Morph]: The Morph model is missing HumanoidRootPart or Humanoid.")
		newChar:Destroy()
		return
	end

	newRoot.CFrame = savedCFrame
	newHumanoid.MaxHealth = savedMaxHealth
	newHumanoid.Health = savedHealth
	newHumanoid.WalkSpeed = savedWalkSpeed
	newHumanoid.JumpPower = savedJumpPower
	newHumanoid.JumpHeight = savedJumpHeight

	player.Character = newChar
	newChar.Parent = workspace

	oldChar:Destroy()
end

function Morph.MorphPlayerByDummy(player: Player, dummy: Model)
	if not player or not player:IsA("Player") or not dummy or not dummy:IsA("Model") then
		return
	end

	local oldChar = getCharacter(player)
	local oldHumanoid = oldChar:WaitForChild("Humanoid", 5) :: Humanoid?
	local oldRoot = oldChar:WaitForChild("HumanoidRootPart", 5) :: BasePart?

	if not oldHumanoid or not oldRoot then
		warn("[Morph]: Missing character parts.")
		return
	end

	local originalCFrame = oldRoot.CFrame
	local originalHealth = oldHumanoid.Health
	local originalMaxHealth = oldHumanoid.MaxHealth
	local originalSpeed = oldHumanoid.WalkSpeed
	local originalJump = oldHumanoid.JumpPower
	local originalJumpHeight = oldHumanoid.JumpHeight

	local charClone = dummy:Clone()
	charClone.Name = player.Name

	local newRoot = charClone:WaitForChild("HumanoidRootPart", 5) :: BasePart?
	local newHumanoid = charClone:WaitForChild("Humanoid", 5) :: Humanoid?

	if not newRoot or not newHumanoid then
		warn("[Morph]: Dummy is missing HumanoidRootPart or Humanoid.")
		charClone:Destroy()
		return
	end

	newRoot.CFrame = originalCFrame
	newHumanoid.MaxHealth = originalMaxHealth
	newHumanoid.Health = originalHealth
	newHumanoid.WalkSpeed = originalSpeed
	newHumanoid.JumpPower = originalJump
	newHumanoid.JumpHeight = originalJumpHeight

	player.Character = charClone
	charClone.Parent = workspace

	oldChar:Destroy()
end

return Morph
