local AnalyticsService = game:GetService("AnalyticsService")

export type Funnel = {
	MarkStep: (plr: Player, Step: number, Name: string) -> (),
}

local Funnel = {}

function Funnel.MarkStep(plr: Player, Step: number, Name: string)
	if not plr then
		return
	end

	local success, err = pcall(function()
		AnalyticsService:LogOnboardingFunnelStepEvent(plr, Step, Name)
	end)

	if not success then
		warn("[Funnel]: Failed to mark step for " .. plr.Name .. ": " .. tostring(err))
	end
end

return Funnel
