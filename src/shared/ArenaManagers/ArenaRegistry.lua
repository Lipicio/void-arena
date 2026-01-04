-- =====================================================
-- ArenaRegistry
-- Central de registro e rotação de arenas
-- =====================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArenaRegistry = {}

local ArenaManagersFolder = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("ArenaManagers")

-- =====================================================
-- REGISTRO DE ARENAS
-- =====================================================
-- weight = chance relativa (ex: 2 aparece o dobro de 1)
ArenaRegistry.RegisteredArenas = {
	{
		name = "Arena01",
		module = "Arena01Manager",
		weight = 1,
		enabled = true,
	},
}

-- =====================================================
-- UTILS
-- =====================================================
local function getWeightedPool()
	local pool = {}

	for _, arena in ipairs(ArenaRegistry.RegisteredArenas) do
		if arena.enabled then
			for i = 1, arena.weight do
				table.insert(pool, arena)
			end
		end
	end

	return pool
end

-- =====================================================
-- PUBLIC API
-- =====================================================
function ArenaRegistry:GetRandomArena()
	local pool = getWeightedPool()
	if #pool == 0 then
		error("❌ Nenhuma arena registrada ou habilitada")
	end

	return pool[math.random(#pool)]
end

function ArenaRegistry:CreateArenaManager()
	local arenaData = self:GetRandomArena()

	if not arenaData or not arenaData.module then
		error("❌ ArenaRegistry: arena inválida ou sem módulo")
	end

	local moduleScript = ArenaManagersFolder:FindFirstChild(arenaData.module)

	if not moduleScript or not moduleScript:IsA("ModuleScript") then
		error("❌ ArenaRegistry: ModuleScript inválido -> " .. tostring(arenaData.module))
	end

	local ArenaClass = require(moduleScript)

	if type(ArenaClass) ~= "table" or not ArenaClass.new then
		error("❌ ArenaRegistry: ArenaManager não expõe .new()")
	end

	return ArenaClass.new()
end

return ArenaRegistry
