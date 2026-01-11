print("👤 PlayerService iniciado")

local Players = game:GetService("Players")

-- =====================================================
-- Lobby Spawns
-- =====================================================
local LobbySpawnsFolder = workspace
	:WaitForChild("Lobby")
	:WaitForChild("Spawns")

local function getLobbySpawns()
	local spawns = LobbySpawnsFolder:GetChildren()
	if #spawns == 0 then
		warn("⚠️ Nenhum Spawn encontrado no Lobby")
	end
	return spawns
end

-- =====================================================
-- Teleporte seguro
-- =====================================================
local function teleportCharacterToLobby(character)
	if not character then return end

	-- Garante que o character terminou de spawnar
	local hrp = character:WaitForChild("HumanoidRootPart", 10)
	if not hrp then
		warn("❌ HumanoidRootPart não encontrado para teleporte")
		return
	end

	local spawns = getLobbySpawns()
	if #spawns == 0 then return end

	local spawn = spawns[math.random(#spawns)]
	hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
end

-- =====================================================
-- Player lifecycle
-- =====================================================
local function onCharacterAdded(player, character)
	-- Pequeno delay para estabilizar física
	task.wait()

	teleportCharacterToLobby(character)
end

local function onPlayerAdded(player)
	print("➕ Player conectado:", player.Name)

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

-- =====================================================
-- Bind
-- =====================================================
Players.PlayerAdded:Connect(onPlayerAdded)

-- Caso o script carregue depois de players já conectados
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
