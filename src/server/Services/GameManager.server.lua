print("🚀 Inicializando GameState")

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- =========================
-- CONFIG
-- =========================
local GameConfig = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Config")
		:WaitForChild("GameConfig")
)

-- =========================
-- STATE FORWARD DECLARATION
-- =========================
local onWaitingState
local onPlayingState
local onEndingState

-- =========================
-- GAME STATE
-- =========================
local GameState = {
	WAITING = "WAITING",
	PLAYING = "PLAYING",
	ENDING = "ENDING",
}

-- =========================
-- VARS
-- =========================

local currentState = nil
local MIN_PLAYERS = GameConfig.MIN_PLAYERS


-- =========================
-- LOBBY SPAWNS
-- =========================
local LobbySpawnsFolder = workspace
	:WaitForChild("Lobby")
	:WaitForChild("Spawns")

local function getLobbySpawns()
	local spawns = {}
	for _, obj in ipairs(LobbySpawnsFolder:GetChildren()) do
		if obj:IsA("SpawnLocation") then
			table.insert(spawns, obj)
		end
	end
	return spawns
end

-- =========================
-- ARENA
-- =========================
local ArenasFolder = ReplicatedStorage:WaitForChild("Arenas")
local currentArena = nil

local function loadArena(arenaName)
	if currentArena then
		currentArena:Destroy()
		currentArena = nil
	end

	local arenaTemplate = ArenasFolder:WaitForChild(arenaName)
	currentArena = arenaTemplate:Clone()
	currentArena.Parent = workspace
end

-- =========================
-- TELEPORT
-- =========================
local function teleportCharacter(character, spawnLocation)
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	if not hrp then
		return
	end

	hrp.CFrame = spawnLocation.CFrame + Vector3.new(0, 3, 0)
end


local function teleportPlayersToLobby()
	local lobbySpawns = getLobbySpawns()
	if #lobbySpawns == 0 then
		warn("⚠️ Nenhum Lobby Spawn encontrado")
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local spawn = lobbySpawns[math.random(1, #lobbySpawns)]
			if player.Character and player.Character.Parent then
				teleportCharacter(player.Character, spawn)
			end
		end
	end
end

local function teleportPlayersToArena()
	if not currentArena then
		warn("❌ Arena não carregada")
		return
	end

	local spawnsFolder = currentArena:WaitForChild("Spawns")
	local spawns = {}

	for _, obj in ipairs(spawnsFolder:GetChildren()) do
		if obj:IsA("SpawnLocation") then
			table.insert(spawns, obj)
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and #spawns > 0 then
			local spawn = spawns[math.random(1, #spawns)]
			teleportCharacter(player.Character, spawn)
		end
	end
end

-- =========================
-- GROUNDS
-- =========================
local function getGrounds(arena)
	local groundsFolder = arena:WaitForChild("Grounds")
	local grounds = {}

	for _, obj in ipairs(groundsFolder:GetChildren()) do

		if obj.PrimaryPart == nil then
			obj.PrimaryPart = obj:WaitForChild("Part")
		end
		
		if obj:IsA("Model") and obj.PrimaryPart then
			table.insert(grounds, obj)
		end
	end

	return grounds
end

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

local function warnGround(ground)
	local part = ground.PrimaryPart
	if not part then return end

	local tween = TweenService:Create(
		part,
		TweenInfo.new(GameConfig.GROUND_WARNING_TIME, Enum.EasingStyle.Sine),
		{ Transparency = 0.5 }
	)
	tween:Play()
end

local function dropGround(ground)
	for _, desc in ipairs(ground:GetDescendants()) do
		if desc:IsA("BasePart") then
			desc.Anchored = false
			desc.CanCollide = false
		end
	end
end

local function startGroundLoop(arena)
	
	print("🔄 Iniciando loop de chão")

	local grounds = getGrounds(arena)
	shuffle(grounds)

	local index = 1

	while index <= #grounds do
		if #Players:GetPlayers() <= 0 then
			break
		end

		local batch = {}
		for i = 1, GameConfig.GROUNDS_PER_CYCLE do
			if grounds[index] then
				table.insert(batch, grounds[index])
				index += 1
			end
		end

		for _, ground in ipairs(batch) do
			warnGround(ground)
		end

		task.wait(GameConfig.GROUND_WARNING_TIME)

		for _, ground in ipairs(batch) do
			dropGround(ground)
		end

		task.wait(GameConfig.GROUND_FALL_INTERVAL)
	end
end

-- =========================
-- VICTORY SYSTEM
-- =========================
local matchRunning = false
local alivePlayers = {}
local victoryDeclared = false

local function resetMatchState()
	matchRunning = false
	victoryDeclared = false
	alivePlayers = {}
end

local function getWinner()	
	for player, alive in pairs(alivePlayers) do
		if alive then
			return player
		end
	end

	return nil
end

local function declareVictory(player)
	if victoryDeclared then return end
	victoryDeclared = true
	
	if player then
		print("🏆 VENCEDOR:", player.Name)
	else
		print("Dessa vez não tivemos vencedores")
	end

	setGameState(GameState.ENDING)
end

local function checkVictoryCondition()
	local aliveCount = 0
	for _, alive in pairs(alivePlayers) do
		if alive then
			aliveCount += 1
		end
	end

	if aliveCount <= 1 then
		local winner = getWinner()
		declareVictory(winner)		
	end

end

-- =========================
-- PLAYER TRACKING
-- =========================
local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	alivePlayers[player] = true

	humanoid.Died:Connect(function()
		alivePlayers[player] = false
		print("💀 Eliminado:", player.Name)
		checkVictoryCondition()
	end)
end

local function registerPlayers()
	alivePlayers = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			onCharacterAdded(player, player.Character)
		end

		player.CharacterAdded:Connect(function(character)
			if matchRunning then
				onCharacterAdded(player, character)
			end
		end)
	end
end

-- =========================
-- GAME STATE HANDLERS
-- =========================
onWaitingState = function()
	print("🟢 ESTADO: WAITING")

	resetMatchState()
	teleportPlayersToLobby()

	task.delay(GameConfig.LOBBY_WAIT_TIME, function()
		if currentState == GameState.WAITING then
			print("⏱️ Iniciando partida")
			setGameState(GameState.PLAYING)
		end
	end)
end

onPlayingState = function()
	print("🔴 ESTADO: PLAYING")

	matchRunning = true
	loadArena("Arena_01")
	teleportPlayersToArena()
	registerPlayers()

	task.spawn(function()
		if matchRunning then
			startGroundLoop(currentArena)
		end
	end)
end

onEndingState = function()
	print("🟡 ESTADO: ENDING")

	matchRunning = false

	task.delay(GameConfig.END_MATCH_DELAY, function()
		if currentArena then
			currentArena:Destroy()
			currentArena = nil
		end
		setGameState(GameState.WAITING)
	end)
end

-- =========================
-- GAME STATE CORE
-- =========================
function setGameState(newState)
	if currentState == newState then return end

	print("🔄 GameState:", currentState, "->", newState)
	currentState = newState

	if newState == GameState.WAITING then
		onWaitingState()
	elseif newState == GameState.PLAYING then
		onPlayingState()
	elseif newState == GameState.ENDING then
		onEndingState()
	end
end

local function canStartMatch()
	return #Players:GetPlayers() >= MIN_PLAYERS
end

local function tryStartGame()
	if canStartMatch() then
		print("👥 Jogadores suficientes. Iniciando jogo.")
		setGameState(GameState.WAITING)
	else
		print("⏳ Aguardando jogadores... (" .. #Players:GetPlayers() .. "/" .. MIN_PLAYERS .. ")")
	end
end

-- =========================
-- BOOT
-- =========================

print("✅ GameManager carregado")

task.wait(2)
tryStartGame()

Players.PlayerAdded:Connect(function(player)
	print("➕ Jogador entrou:", player.Name)
	task.wait(1) -- garante Character
	tryStartGame()
end)

Players.PlayerRemoving:Connect(function(player)
	print("➖ Jogador saiu:", player.Name)

	-- Se cair para menos do mínimo durante WAITING ou PLAYING
	if #Players:GetPlayers() - 1 < MIN_PLAYERS then
		print("⚠️ Jogadores insuficientes, retornando ao lobby")
		setGameState(GameState.WAITING)
	end
end)
