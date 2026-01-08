print("🎮 GameManager iniciado")

-- =====================================================
-- SERVICES
-- =====================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- =====================================================
-- CONFIG
-- =====================================================
local Shared = ReplicatedStorage:WaitForChild("Shared")

local GameConfig = require(Shared.Configs.GameConfig)
local Utils = require(Shared.Utils.Utils)

-- Network
local Network = Shared.Network
local CountdownNet = require(Network.RoundCountdown)
local ArenaInfoNet = require(Network.ArenaInfo)
local AliveCountNet = require(Network.AliveCount)

-- garante criação dos RemoteEvents
require(Network.Remotes)

-- =====================================================
-- MUSIC
-- =====================================================
local music = Instance.new("Sound")
music.Name = "BackgroundMusic"
music.Looped = true
music.Volume = 0.05
music.Parent = SoundService

-- =====================================================
-- GAME STATE
-- =====================================================
local GameState = {
	WAITING = "WAITING",
	PLAYING = "PLAYING",
	ENDING  = "ENDING",
}

local currentState
local MIN_PLAYERS = GameConfig.MIN_PLAYERS or 2

-- =====================================================
-- MATCH STATE
-- =====================================================
local matchRunning = false
local victoryDeclared = false
local alivePlayers = {}

-- =====================================================
-- ARENA
-- =====================================================
local currentArenaManager

-- =====================================================
-- LOBBY
-- =====================================================
local LobbySpawns = workspace:WaitForChild("Lobby"):WaitForChild("Spawns")

local function teleportToLobby(character)
	local spawns = LobbySpawns:GetChildren()
	if #spawns == 0 then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.CFrame = spawns[math.random(#spawns)].CFrame + Vector3.new(0, 3, 0)
end

local function teleportAllToLobby()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			teleportToLobby(player.Character)
		end
	end
end

-- =====================================================
-- ALIVE TRACKING
-- =====================================================
local function resetAlive()
	alivePlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		alivePlayers[player] = true
	end
end

local function getAliveCount()
	local alive = 0
	local last

	for player, isAlive in pairs(alivePlayers) do
		if isAlive then
			alive += 1
			last = player
		end
	end

	return alive, last
end

local function broadcastAlive()
	local alive = getAliveCount()
	AliveCountNet.send(alive, Utils.tableSize(alivePlayers))
end

local function declareVictory(winner)
	if victoryDeclared then return end
	victoryDeclared = true
	matchRunning = false
	setGameState(GameState.ENDING)
end

local function onPlayerKilled(player)
	if not matchRunning or not alivePlayers[player] then return end

	alivePlayers[player] = false
	local alive, last = getAliveCount()

	broadcastAlive()

	if alive <= 1 then
		declareVictory(last)
	end
end

-- =====================================================
-- PLAYER LIFECYCLE
-- =====================================================
local function bindPlayer(player)
	local function onCharacter(character)
		if currentState ~= GameState.PLAYING then
			task.wait()
			teleportToLobby(character)
			return
		end

		character:WaitForChild("Humanoid").Died:Connect(function()
			onPlayerKilled(player)
		end)
	end

	if player.Character then
		onCharacter(player.Character)
	end

	player.CharacterAdded:Connect(onCharacter)
end

-- =====================================================
-- STATES
-- =====================================================
local function onWaiting()
	matchRunning = false
	victoryDeclared = false

	local waitTime = GameConfig.LOBBY_WAIT_TIME
	CountdownNet.start(waitTime)

	task.spawn(function()
		for t = waitTime, 1, -1 do
			if currentState ~= GameState.WAITING then
				CountdownNet.stop()
				return
			end
			CountdownNet.update(t)
			task.wait(1)
		end

		CountdownNet.stop()
		setGameState(GameState.PLAYING)
	end)
end

local function onPlaying()
	matchRunning = true
	resetAlive()

	local ArenaRegistry = require(Shared.ArenaManagers.ArenaRegistry)
	currentArenaManager = ArenaRegistry:CreateArenaManager()

	currentArenaManager.OnPlayerKilled = onPlayerKilled
	currentArenaManager:Load()
	currentArenaManager:Start(Players:GetPlayers())

	music.SoundId = GameConfig.MUSIC_IDS[math.random(#GameConfig.MUSIC_IDS)]
	music:Play()

	for _, player in ipairs(Players:GetPlayers()) do
		bindPlayer(player)
	end

	ArenaInfoNet.send({
		name = currentArenaManager.Config.NAME
	})

	broadcastAlive()
end

local function onEnding()
	teleportAllToLobby()
	broadcastAlive()

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
-- CORE
-- =====================================================
function setGameState(state)
	if currentState == state then return end
	currentState = state

	if state == GameState.WAITING then
		onWaiting()
	elseif state == GameState.PLAYING then
		onPlaying()
	elseif state == GameState.ENDING then
		onEnding()
	end
end

-- =====================================================
-- BOOT
-- =====================================================
task.wait(2)

local function tryStart()
	if #Players:GetPlayers() >= MIN_PLAYERS then
		setGameState(GameState.WAITING)
	end
end

tryStart()

Players.PlayerAdded:Connect(tryStart)
Players.PlayerRemoving:Connect(function(player)
	alivePlayers[player] = nil
end)
