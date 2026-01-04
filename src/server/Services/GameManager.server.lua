-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Paths
local ArenasFolder = ReplicatedStorage:WaitForChild("Arenas")
local LobbySpawnsFolder = workspace
	:WaitForChild("Lobby")
	:WaitForChild("Spawns")

-- State
local currentArena = nil
local arenaSpawns = {}

-- Utils
local function getRandomFromTable(t)
	return t[math.random(1, #t)]
end

local function getLobbySpawns()
	local spawns = {}
	for _, obj in ipairs(LobbySpawnsFolder:GetChildren()) do
		if obj:IsA("SpawnLocation") then
			table.insert(spawns, obj)
		end
	end
	return spawns
end

local function getArenaSpawns(arena)
	local spawnsFolder = arena:WaitForChild("Spawns")
	local spawns = {}

	for _, obj in ipairs(spawnsFolder:GetChildren()) do
		if obj:IsA("SpawnLocation") then
			table.insert(spawns, obj)
		end
	end

	return spawns
end

local function teleportCharacter(character, spawnLocation)
	local hrp = character:WaitForChild("HumanoidRootPart")
	hrp.CFrame = spawnLocation.CFrame + Vector3.new(0, 3, 0)
end

-- Arena Control
local function loadArena(arenaName)
	if currentArena then
		currentArena:Destroy()
		currentArena = nil
	end

	local arenaTemplate = ArenasFolder:WaitForChild(arenaName)
	currentArena = arenaTemplate:Clone()
	currentArena.Parent = workspace

	arenaSpawns = getArenaSpawns(currentArena)
end

local function teleportPlayersToArena()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local spawn = getRandomFromTable(arenaSpawns)
			teleportCharacter(player.Character, spawn)
		end
	end
end

local function teleportPlayersToLobby()
	local lobbySpawns = getLobbySpawns()

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local spawn = getRandomFromTable(lobbySpawns)
			teleportCharacter(player.Character, spawn)
		end
	end
end

-- Test flow (temporário)
task.delay(5, function()
	print("Carregando Arena_01...")
	loadArena("Arena_01")

	task.wait(2)

	print("Teleportando jogadores para arena...")
	teleportPlayersToArena()

	task.wait(15)

	print("Voltando jogadores para o lobby...")
	teleportPlayersToLobby()

	if currentArena then
		currentArena:Destroy()
	end
end)
