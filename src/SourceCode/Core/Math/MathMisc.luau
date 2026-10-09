--!strict
local Misc = {}

-- Rimappa un valore da un vecchio intervallo [oldMin, oldMax] a uno nuovo [newMin, newMax]
function Misc.Remap(value: number, oldMin: number, oldMax: number, newMin: number, newMax: number): number
	return newMin + (value - oldMin) * (newMax - newMin) / (oldMax - oldMin)
end

-- Calcola la percentuale di un valore rispetto al totale (es. 50 su 200 = 25%)
function Misc.ToPercentage(value: number, total: number): number
	if total == 0 then return 0 end
	return (value / total) * 100
end

-- Teorema di Pitagora (Magnitude): calcola la distanza/lunghezza di un vettore 2D a partire da X e Y
function Misc.GetMagnitude(x: number, y: number): number return math.sqrt(x * x + y * y) end

-- Calcola quanti roll/punti mancano per raggiungere la prossima soglia/pity (es. ogni 25 roll)
function Misc.CheckStepProgress(currentValue: number, step: number): (number, boolean)
	if step <= 0 then return 0, false end

	local remainder = currentValue % step
	local isAtStep = (currentValue > 0) and (remainder == 0)
	local remaining = if isAtStep then 0 else (step - remainder)

	return remaining, isAtStep
end

return Misc
