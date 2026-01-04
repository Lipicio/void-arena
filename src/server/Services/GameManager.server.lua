-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Config
local GameConfig = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Config")
		:WaitForChild("GameConfig")
)

-- =========================
-- GROUNDS
-- =========================

local function getGrounds(arena)
	local groundsFolder = arena:WaitForChild("Grounds")
	local grounds = {}

	for _, obj in ipairs(groundsFolder:GetChildren()) do
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

	-- efeito simples de warning (pode evoluir depois)
	local tween = TweenService:Create(
		part,
		TweenInfo.new(GameConfig.GROUND_WARNING_TIME, Enum.EasingStyle.Sine),
		{ Transparency = 0.5 }
	)
	tween:Play()
end

local function dropGround(ground)
	if not ground.PrimaryPart then return end

	for _, desc in ipairs(ground:GetDescendants()) do
		if desc:IsA("BasePart") then
			desc.Anchored = false
			desc.CanCollide = false
		end
	end
end

-- =========================
-- PLAYER CHECK
-- =========================

local function getAlivePlayers()
	local alive = {}

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				table.insert(alive, player)
			end
		end
	end

	return alive
end

-- =========================
-- CORE LOOP
-- =========================

local function startGroundLoop(arena)
	local grounds = getGrounds(arena)
	shuffle(grounds)

	local index = 1

	while index <= #grounds do
		-- condição de vitória
		if #getAlivePlayers() <= 1 then
			break
		end

		-- selecionar grounds do ciclo
		local batch = {}
		for i = 1, GameConfig.GROUNDS_PER_CYCLE do
			if grounds[index] then
				table.insert(batch, grounds[index])
				index += 1
			end
		end

		-- warning
		for _, ground in ipairs(batch) do
			warnGround(ground)
		end

		task.wait(GameConfig.GROUND_WARNING_TIME)

		-- drop
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
	for player, isAlive in pairs(alivePlayers) do
		if isAlive then
			return player
		end
	end
	return nil
end

local function declareVictory(player)
	if victoryDeclared then return end
	victoryDeclared = true

	print("🏆 VENCEDOR:", player.Name)

	-- Aqui no futuro:
	-- • UI de vitória
	-- • Rewards / Coins
	-- • Stats
	-- • Leaderboard

	task.delay(GameConfig.END_MATCH_DELAY, function()
		-- Volta jogadores para o lobby
		teleportPlayersToLobby()

		-- Limpa arena
		if currentArena then
			currentArena:Destroy()
			currentArena = nil
		end

		resetMatchState()
	end)
end

local function checkVictoryCondition()
	if victoryDeclared then return end

	local aliveCount = 0
	for _, isAlive in pairs(alivePlayers) do
		if isAlive then
			aliveCount += 1
		end
	end

	if aliveCount == 1 then
		local winner = getWinner()
		if winner then
			declareVictory(winner)
		end
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

