local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Morph = require(ReplicatedStorage.SourceCode.Core.Utilities.Morph)

type Promise = typeof(Promise.new())

export type ApplyPlayerAppearance = (userId: number, dummy: Model) -> Promise
export type ApplyCharacterAppearance = (userId: number, dummy: Model, player: Player) -> Promise

export type AppearanceModule = {
	applyPlayerAppearance: ApplyPlayerAppearance,
	applyCharacterAppearance: ApplyCharacterAppearance,
}

local Appearance = {} :: AppearanceModule

function Appearance.applyPlayerAppearance(userId: number, dummy: Model): Promise
	return Promise.new(function(resolve, reject)
		local humanoid = dummy:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			reject("Dummy model is missing a Humanoid")
			return
		end

		local success, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
		end)

		if not success or not result then
			reject("Failed to retrieve HumanoidDescription: " .. tostring(result))
			return
		end

		local applySuccess, applyError = pcall(function()
			humanoid:ApplyDescriptionAsync(result)
		end)

		if applySuccess then
			resolve()
		else
			reject("Failed to apply HumanoidDescription: " .. tostring(applyError))
		end
	end)
end

function Appearance.applyCharacterAppearance(userId: number, dummy: Model, player: Player): Promise
	return Appearance.applyPlayerAppearance(userId, dummy):andThen(function()
		return Promise.new(function(resolve, reject)
			local success, err = pcall(function()
				Morph.MorphPlayerByDummy(player, dummy)
			end)

			if success then
				resolve()
			else
				reject("Failed to morph player: " .. tostring(err))
			end
		end)
	end)
end

return Appearance
