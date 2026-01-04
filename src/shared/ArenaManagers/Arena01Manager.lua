-- =====================================================
-- Arena01Manager
-- Mecânica: chão caindo
-- =====================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ArenaConfig = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Configs")
		:WaitForChild("Arenas")
		:WaitForChild("Arena01Config")
)

local ArenaBase = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("ArenaManagers")
		:WaitForChild("ArenaBase")
)

local CharacterUtils = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Utils")
		:WaitForChild("CharacterUtils")
)


local Arena01Manager = {}
Arena01Manager.__index = Arena01Manager
setmetatable(Arena01Manager, ArenaBase)

-- =====================================================
-- CONSTRUCTOR
-- =====================================================
function Arena01Manager.new()
	local self = ArenaBase.new("Arena_01")
	setmetatable(self, Arena01Manager)
	return self
end

-- =====================================================
-- INTERNAL STATE
-- =====================================================
local grounds = {}
local killConnections = {}

-- =====================================================
-- UTILS
-- =====================================================
local function getGrounds(arena)
	local list = {}
	for _, model in ipairs(arena:WaitForChild("Grounds"):GetChildren()) do
		if model:IsA("Model") then
			model.PrimaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
			if model.PrimaryPart then
				table.insert(list, model)
			end
		end
	end
	return list
end

-- =====================================================
-- KILL FLOOR
-- =====================================================
local function bindKillFloor(self)
	local killFloor = self.ArenaModel:FindFirstChild("Floor_Arena", true)
	if not killFloor then
		warn("⚠️ KillFloor não encontrado na Arena_01")
		return
	end

	killConnections[#killConnections + 1] =
		killFloor.Touched:Connect(function(hit)
			local character = hit:FindFirstAncestorOfClass("Model")
			if not character then return end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end

			humanoid.Health = 0

			local player = Players:GetPlayerFromCharacter(character)
			if player then
				self:NotifyPlayerKilled(player)
			end
		end)
end

-- =====================================================
-- GROUND LOOP
-- =====================================================
local function warnGround(ground)
	TweenService:Create(
		ground.PrimaryPart,
		TweenInfo.new(ArenaConfig.GROUND_WARNING_TIME),
		{ Transparency = 0.5 }
	):Play()
end

local function dropGround(ground)
	for _, part in ipairs(ground:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
		end
	end
end

local function startGroundLoop(self)
	task.spawn(function()
		self:Shuffle(grounds)

		for _, ground in ipairs(grounds) do
			if not self.Running then return end

			warnGround(ground)
			task.wait(ArenaConfig.GROUND_WARNING_TIME)

			dropGround(ground)
			task.wait(ArenaConfig.GROUND_FALL_INTERVAL)
		end
	end)
end

-- =====================================================
-- OVERRIDES
-- =====================================================
function Arena01Manager:Load()
	local template = ReplicatedStorage
		:WaitForChild("Arenas")
		:WaitForChild("Arena_01")

	self.ArenaModel = template:Clone()
	self.ArenaModel.Parent = workspace

	grounds = getGrounds(self.ArenaModel)
	bindKillFloor(self)
end

function Arena01Manager:Start(players)
	ArenaBase.Start(self)

	-- Teleportar jogadores
	local spawns = {}
	for _, s in ipairs(self.ArenaModel:WaitForChild("Spawns"):GetChildren()) do
		if s:IsA("SpawnLocation") then
			table.insert(spawns, s)
		end
	end

	for _, player in ipairs(players) do
		if player.Character then
			CharacterUtils.SafeTeleport(
				player.Character,
				spawns[math.random(#spawns)].CFrame
			)
		end
	end	

	startGroundLoop(self)
end

function Arena01Manager:Stop()
	ArenaBase.Stop(self)
end

function Arena01Manager:Destroy()
	for _, conn in ipairs(killConnections) do
		conn:Disconnect()
	end
	killConnections = {}

	ArenaBase.Destroy(self)
end

return Arena01Manager
