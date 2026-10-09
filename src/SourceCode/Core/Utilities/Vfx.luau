export type Vfx = {
	Emit: (Model: Instance, multiplier: number?) -> (),
}

local Vfx = {}

function Vfx.Emit(Model: Instance, multiplier: number?)
	if not Model then
		warn("Model nil")
		return
	end

	multiplier = multiplier or 1
	for _, v in ipairs(Model:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			local count = v:GetAttribute("EmitCount") or 10
			v:Emit(count * multiplier)
		end
	end
end

return Vfx
