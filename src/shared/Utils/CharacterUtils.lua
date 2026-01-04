-- =====================================================
-- CharacterUtils
-- Utilidades para manipulação segura de Characters
-- =====================================================

local RunService = game:GetService("RunService")
local CharacterUtils = {}

-- =====================================================
-- Reset completo do estado físico / animação
-- =====================================================
function CharacterUtils.ResetCharacterState(character)
	if not character or not character:IsA("Model") then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not hrp then return end

	-- 1️⃣ Força saída do estado sentado
	humanoid.Sit = false

	-- 2️⃣ Remove referência ao assento (CRÍTICO)
	if humanoid.SeatPart then
		humanoid.SeatPart:Sit(nil)
	end

	-- 3️⃣ Garante que o personagem não está travado
	humanoid.PlatformStand = false
	humanoid.AutoRotate = true

	-- 4️⃣ Zera forças residuais
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.AssemblyAngularVelocity = Vector3.zero

	-- 5️⃣ Força estados físicos válidos
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

	-- 6️⃣ Reforço por alguns frames (EVITA RE-SIT)
	local frames = 0
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if frames >= 5 then
			conn:Disconnect()
			return
		end

		humanoid.Sit = false
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

		frames += 1
	end)
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
