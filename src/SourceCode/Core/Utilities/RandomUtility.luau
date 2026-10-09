--!strict
local GroupService = game:GetService("GroupService")
local SocialService = game:GetService("SocialService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")

export type RandomUtility = {
	PromptFollowEvent: (EVENT_ID: string) -> (),
	PromptFavoriteGame: (PlaceId: number) -> boolean,
	PromptFriendInvite: () -> boolean,
	PromptGroupInvite: (GroupId: number) -> boolean,
}

local RandomUtility = {}

function RandomUtility.PromptFollowEvent(EVENT_ID: string)
	task.spawn(pcall, SocialService.PromptRsvpToEventAsync, SocialService, EVENT_ID)
end

function RandomUtility.PromptFavoriteGame(PlaceId: number): boolean
	local success, result = pcall(function()
		return AvatarEditorService:PromptSetFavorite(PlaceId, Enum.AvatarItemType.Asset, true)
	end)

	if not success then
		warn("Error When Prompting Favorite Game: " .. tostring(result))
		return false
	end

	return true
end

function RandomUtility.PromptFriendInvite(): boolean
	local player = Players.LocalPlayer
	if not player then
		warn("LocalPlayer not found")
		return false
	end

	local success, canInvite = pcall(function()
		return SocialService:CanSendGameInviteAsync(player)
	end)

	if success and canInvite then
		SocialService:PromptGameInvite(player)
		return true
	end

	warn("Player can't be invited: " .. tostring(canInvite))
	return false
end

function RandomUtility.PromptGroupInvite(GroupId: number): boolean
	local success, err = pcall(function()
		return GroupService:PromptJoinAsync(GroupId)
	end)

	if not success then
		warn("Error When Prompting Join Group: " .. tostring(err))
		return false
	end

	return true
end

return RandomUtility
