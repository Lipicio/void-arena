-- =====================================================
-- CharacterUtils (Pipeline de transição de estado)
-- =====================================================

local CharacterUtils = {}

function CharacterUtils.SafeTeleport(character, targetCFrame, yOffset)
	if not character or not targetCFrame then return end

	local offset = yOffset or 3	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")	

	if not humanoid or not hrp then return end

	humanoid.Jump = true-- Teleportar
	hrp.CFrame = targetCFrame + Vector3.new(0, offset, 0)
end

return CharacterUtils
