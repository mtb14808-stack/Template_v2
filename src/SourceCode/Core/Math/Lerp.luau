--!strict
local Lerp = {}

-- Esegue l'interpolazione lineare classica tra due numeri 'a' e 'b' dato un fattore 't'
function Lerp.Number(a: number, b: number, t: number): number return a + (b - a) * t end

-- Limita un valore all'interno di un intervallo compreso tra 'min' e 'max'
function Lerp.Clamp(value: number, min: number, max: number): number return math.clamp(value, min, max) end

-- Calcola la percentuale/progresso 't' (Inverse Lerp) dato un valore interno all'intervallo [a, b]
function Lerp.Inverse(a: number, b: number, value: number): number
	if b == a then return 0 end
	return (value - a) / (b - a)
end

-- Rimappa un valore da un intervallo di origine [oldMin, oldMax] a uno di destinazione [newMin, newMax]
function Lerp.Remap(value: number, oldMin: number, oldMax: number, newMin: number, newMax: number): number
	local t = (value - oldMin) / (oldMax - oldMin)
	return newMin + (newMax - newMin) * t
end

-- Interpolazione lineare tra due angoli in GRADI mantenendo sempre il percorso più breve
function Lerp.Angle(a: number, b: number, t: number): number
	local d = (b - a) % 360
	if d > 180 then
		d -= 360
	end
	return a + d * t
end

-- Interpolazione lineare tra due angoli in RADIANTI mantenendo sempre il percorso più breve
function Lerp.Radian(a: number, b: number, t: number): number
	local tau = math.pi * 2
	local d = (b - a) % tau
	if d > math.pi then
		d -= tau
	end
	return a + d * t
end

-- Interpolazione fluida (Smoothstep): parte lenta, accelera al centro e rallenta alla fine
function Lerp.Smooth(a: number, b: number, t: number): number
	t = math.clamp(t, 0, 1)
	local smoothT = t * t * (3 - 2 * t)
	return a + (b - a) * smoothT
end

-- Interpolazione lineare garantita nell'intervallo [a, b] (forza 't' tra 0 e 1)
function Lerp.Clamped(a: number, b: number, t: number): number
	t = math.clamp(t, 0, 1)
	return a + (b - a) * t
end

-- Interpolazione numerica precisa che evita imprecisioni sui float quando 't' è vicino a 1
function Lerp.Precise(a: number, b: number, t: number): number
	if t < 0.5 then
		return a + (b - a) * t
	else
		return b - (b - a) * (1 - t)
	end
end

-- Simula una molla/oscillazione elastica (Spring) da 'a' a 'b' con smorzamento personalizzabile
function Lerp.Spring(a: number, b: number, t: number, damping: number?): number
	local d = damping or 0.5
	t = math.clamp(t, 0, 1)
	local springT = 1 - math.exp(-d * t) * math.cos(math.pi * 2 * t)
	return a + (b - a) * springT
end

return Lerp
