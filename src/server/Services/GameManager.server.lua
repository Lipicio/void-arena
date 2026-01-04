print("🎮 GameManager iniciado")

-- =====================================================
-- SERVICES
-- =====================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- =====================================================
-- CONFIG
-- =====================================================
local GameConfig = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Configs")
		:WaitForChild("GameConfig")
)

-- =====================================================
-- GAME STATE
-- =====================================================
local GameState = {
	WAITING = "WAITING",
	PLAYING = "PLAYING",
	ENDING  = "ENDING",
}

local currentState = nil
local MIN_PLAYERS = GameConfig.MIN_PLAYERS or 2

-- =====================================================
-- MATCH STATE
-- =====================================================
local matchRunning = false
local alivePlayers = {}
local victoryDeclared = false

-- =====================================================
-- ARENA MANAGEMENT
-- =====================================================
local currentArenaManager = nil
local ArenaManagersFolder = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ArenaManagers")

-- =====================================================
-- LOBBY
-- =====================================================
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

local function teleportCharacterToLobby(character)
	local spawns = getLobbySpawns()
	if #spawns == 0 then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.CFrame = spawns[math.random(#spawns)].CFrame + Vector3.new(0, 3, 0)
end

local function teleportAllToLobby()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			teleportCharacterToLobby(player.Character)
		end
	end
end

-- =====================================================
-- PLAYER TRACKING
-- =====================================================
local function resetAlivePlayers()
	alivePlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		alivePlayers[player] = true
	end
end

local function getAliveCount()
	local count = 0
	local lastAlive = nil

	for player, alive in pairs(alivePlayers) do
		if alive then
			count += 1
			lastAlive = player
		end
	end

	return count, lastAlive
end

local function declareVictory(winner)
	if victoryDeclared then return end
	victoryDeclared = true
	matchRunning = false

	if winner then
		print("🏆 VENCEDOR:", winner.Name)
	else
		print("⚠️ Rodada sem vencedor")
	end

	setGameState(GameState.ENDING)
end

local function onPlayerKilled(player)
	if not matchRunning then return end
	if not alivePlayers[player] then return end

	alivePlayers[player] = false
	print("💀 Eliminado:", player.Name)

	local aliveCount, lastAlive = getAliveCount()
	if aliveCount <= 1 then
		declareVictory(lastAlive)
	end
end

-- =====================================================
-- PLAYER LIFECYCLE
-- =====================================================
local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")

	-- Fora da partida → sempre lobby
	if currentState ~= GameState.PLAYING then
		task.wait()
		teleportCharacterToLobby(character)
		return
	end

	-- Durante a partida → conecta morte
	humanoid.Died:Connect(function()
		onPlayerKilled(player)
	end)
end

local function bindPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			onCharacterAdded(player, player.Character)
		end

		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)
	end
end

-- =====================================================
-- ARENA SELECTION
-- =====================================================
local function loadArenaManager(arenaName)
	if currentArenaManager then
		currentArenaManager:Stop()
		currentArenaManager:Destroy()
		currentArenaManager = nil
	end

	local arenaModule = ArenaManagersFolder:WaitForChild(arenaName)
	currentArenaManager = require(arenaModule)

	-- Callback injetado no ArenaManager
	currentArenaManager.OnPlayerKilled = onPlayerKilled

	currentArenaManager:Load()
end

-- =====================================================
-- GAME STATES
-- =====================================================
local function onWaitingState()
	print("🟢 ESTADO: WAITING")

	matchRunning = false
	victoryDeclared = false
	resetAlivePlayers()

	teleportAllToLobby()

	task.delay(GameConfig.LOBBY_WAIT_TIME, function()
		if currentState == GameState.WAITING then
			setGameState(GameState.PLAYING)
		end
	end)
end

local function onPlayingState()
	print("🔴 ESTADO: PLAYING")

	matchRunning = true
	victoryDeclared = false
	resetAlivePlayers()

	local ArenaRegistry = require(
	ReplicatedStorage
			:WaitForChild("Shared")
			:WaitForChild("ArenaManagers")
			:WaitForChild("ArenaRegistry")
	)

	currentArenaManager = ArenaRegistry:CreateArenaManager()
	currentArenaManager.OnPlayerKilled = onPlayerKilled
	currentArenaManager:Load()

	currentArenaManager:Start(Players:GetPlayers())
	bindPlayers()
end

local function onEndingState()
	print("🟡 ESTADO: ENDING")

	task.delay(GameConfig.END_MATCH_DELAY, function()
		if currentArenaManager then
			currentArenaManager:Stop()
			currentArenaManager:Destroy()
			currentArenaManager = nil
		end

		setGameState(GameState.WAITING)
	end)
end

-- =====================================================
-- GAME STATE CORE
-- =====================================================
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

-- =====================================================
-- START CONDITIONS
-- =====================================================
local function tryStartGame()
	if #Players:GetPlayers() >= MIN_PLAYERS then
		setGameState(GameState.WAITING)
	else
		print("⏳ Aguardando jogadores...")
	end
end

-- =====================================================
-- BOOT
-- =====================================================
task.wait(2)
tryStartGame()

Players.PlayerAdded:Connect(function()
	tryStartGame()
end)

Players.PlayerRemoving:Connect(function(player)
	if alivePlayers[player] then
		alivePlayers[player] = false
	end

	local aliveCount, lastAlive = getAliveCount()
	if matchRunning and aliveCount <= 1 then
		declareVictory(lastAlive)
	end
end)
