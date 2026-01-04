-- =====================================================
-- CharacterUtils
-- Utilidades para manipulação segura de Characters
-- =====================================================

local CharacterUtils = {}

-- =====================================================
-- Reset completo do estado físico / animação
-- =====================================================
function CharacterUtils.ResetCharacterState(character)
	if not character or not character:IsA("Model") then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not hrp then return end

	-- Sai do estado sentado (Seat / VehicleSeat)
	humanoid.Sit = false

	-- Força transição de estado para soltar qualquer constraint invisível
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	-- Zera forças residuais
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	-- Garante estado padrão de movimento
	humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

-- =====================================================
-- Teleporte seguro (com reset de estado)
-- =====================================================
function CharacterUtils.SafeTeleport(character, cframe, yOffset)
	if not character or not cframe then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	CharacterUtils.ResetCharacterState(character)

	local offset = yOffset or 3
	hrp.CFrame = cframe + Vector3.new(0, offset, 0)
end

-- =====================================================
-- Força o personagem a cair (útil para arenas / void)
-- =====================================================
function CharacterUtils.ForceFall(character)
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

return CharacterUtils
