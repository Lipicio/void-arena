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
-- GAME STATE
-- =========================
local GameState = {
	WAITING = "WAITING",
	PLAYING = "PLAYING",
	ENDING = "ENDING",
}

local currentState = nil
local MIN_PLAYERS = GameConfig.MIN_PLAYERS or 1

-- =========================
-- MATCH VARS
-- =========================
local matchRunning = false
local alivePlayers = {}
local victoryDeclared = false

-- =========================
-- LOBBY
-- =========================
local LobbySpawnsFolder = workspace:WaitForChild("Lobby"):WaitForChild("Spawns")

local function getLobbySpawns()
	local t = {}
	for _, s in ipairs(LobbySpawnsFolder:GetChildren()) do
		if s:IsA("SpawnLocation") then
			table.insert(t, s)
		end
	end
	return t
end

local function teleportToLobby(character)
	local spawns = getLobbySpawns()
	if #spawns == 0 then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.CFrame = spawns[math.random(#spawns)].CFrame + Vector3.new(0, 3, 0)
end

-- =========================
-- ARENA
-- =========================
local ArenasFolder = ReplicatedStorage:WaitForChild("Arenas")
local currentArena = nil

local function loadArena(name)
	if currentArena then
		currentArena:Destroy()
	end

	currentArena = ArenasFolder:WaitForChild(name):Clone()
	currentArena.Parent = workspace
end

local function teleportPlayersToArena()
	if not currentArena then return end

	local spawns = {}
	for _, s in ipairs(currentArena:WaitForChild("Spawns"):GetChildren()) do
		if s:IsA("SpawnLocation") then
			table.insert(spawns, s)
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and #spawns > 0 then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = spawns[math.random(#spawns)].CFrame + Vector3.new(0, 3, 0)
			end
		end
	end
end

-- =========================
-- GROUNDS
-- =========================
local function getGrounds(arena)
	local list = {}
	for _, m in ipairs(arena:WaitForChild("Grounds"):GetChildren()) do
		if m:IsA("Model") then
			m.PrimaryPart = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
			if m.PrimaryPart then
				table.insert(list, m)
			end
		end
	end
	return list
end

local function shuffle(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

local function warnGround(g)
	local p = g.PrimaryPart
	if not p then return end

	TweenService:Create(
		p,
		TweenInfo.new(GameConfig.GROUND_WARNING_TIME),
		{ Transparency = 0.5 }
	):Play()
end

local function dropGround(g)
	for _, d in ipairs(g:GetDescendants()) do
		if d:IsA("BasePart") then
			d.Anchored = false
			d.CanCollide = false
		end
	end
end

local function startGroundLoop(arena)
	print("🔄 Iniciando loop de chão")

	local grounds = getGrounds(arena)
	shuffle(grounds)

	for _, g in ipairs(grounds) do
		if not matchRunning then
			print("🛑 Loop do chão interrompido")
			return
		end

		warnGround(g)
		task.wait(GameConfig.GROUND_WARNING_TIME)
		dropGround(g)
		task.wait(GameConfig.GROUND_FALL_INTERVAL)
	end
end

-- =========================
-- VICTORY
-- =========================
local function checkVictory()
	if not matchRunning or victoryDeclared then return end

	local alive = 0
	local last

	for p, isAlive in pairs(alivePlayers) do
		if isAlive then
			alive += 1
			last = p
		end
	end

	if alive <= 1 then
		victoryDeclared = true
		matchRunning = false

		if last then
			print("🏆 VENCEDOR:", last.Name)
		else
			print("⚠️ Rodada sem vencedor")
		end

		setGameState(GameState.ENDING)
	end
end

-- =========================
-- PLAYER LIFECYCLE
-- =========================
local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")

	if currentState ~= GameState.PLAYING then
		task.wait()
		teleportToLobby(character)
		return
	end

	alivePlayers[player] = true

	humanoid.Died:Connect(function()
		if not alivePlayers[player] then return end
		alivePlayers[player] = false
		print("💀 Eliminado:", player.Name)
		checkVictory()
	end)
end

-- =========================
-- GAME STATES
-- =========================
local function onWaiting()
	print("🟢 ESTADO: WAITING")

	matchRunning = false
	victoryDeclared = false
	alivePlayers = {}

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			teleportToLobby(p.Character)
		end
	end

	task.delay(GameConfig.LOBBY_WAIT_TIME, function()
		if currentState == GameState.WAITING then
			setGameState(GameState.PLAYING)
		end
	end)
end

local function onPlaying()
	print("🔴 ESTADO: PLAYING")

	matchRunning = true
	victoryDeclared = false
	alivePlayers = {}

	loadArena("Arena_01")
	teleportPlayersToArena()

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			onCharacterAdded(p, p.Character)
		end
		p.CharacterAdded:Connect(function(c)
			onCharacterAdded(p, c)
		end)
	end

	task.spawn(function()
		startGroundLoop(currentArena)
	end)
end

local function onEnding()
	print("🟡 ESTADO: ENDING")

	task.delay(GameConfig.END_MATCH_DELAY, function()
		if currentArena then
			currentArena:Destroy()
			currentArena = nil
		end
		setGameState(GameState.WAITING)
	end)
end

-- =========================
-- STATE CORE
-- =========================
function setGameState(state)
	if currentState == state then return end

	print("🔄 GameState:", currentState, "->", state)
	currentState = state

	if state == GameState.WAITING then
		onWaiting()
	elseif state == GameState.PLAYING then
		onPlaying()
	elseif state == GameState.ENDING then
		onEnding()
	end
end

-- =========================
-- BOOT
-- =========================
print("✅ GameManager carregado")

task.wait(2)

if #Players:GetPlayers() >= MIN_PLAYERS then
	setGameState(GameState.WAITING)
else
	print("⏳ Aguardando jogadores")
end

Players.PlayerAdded:Connect(function()
	if #Players:GetPlayers() >= MIN_PLAYERS then
		setGameState(GameState.WAITING)
	end
end)
