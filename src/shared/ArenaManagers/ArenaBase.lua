-- =====================================================
-- ArenaBase
-- Classe base para todas as arenas
-- =====================================================

local ArenaBase = {}
ArenaBase.__index = ArenaBase

-- =====================================================
-- CONSTRUCTOR
-- =====================================================
function ArenaBase.new(arenaName, config)
	local self = setmetatable({}, ArenaBase)

	self.ArenaName = arenaName
	self.ArenaModel = nil
	self.Running = false
	self.Config = config

	-- Callback injetado pelo GameManager
	self.OnPlayerKilled = nil

	return self
end

-- =====================================================
-- LOAD / DESTROY
-- =====================================================
function ArenaBase:Load()
	error("ArenaBase:Load() deve ser implementado pela arena filha")
end

function ArenaBase:Start(players)
	self.Running = true
end

function ArenaBase:Stop()
	self.Running = false
end

function ArenaBase:Destroy()
	if self.ArenaModel then
		self.ArenaModel:Destroy()
		self.ArenaModel = nil
	end
end

-- =====================================================
-- PLAYER DEATH NOTIFY
-- =====================================================
function ArenaBase:NotifyPlayerKilled(player)
	if self.OnPlayerKilled then
		self.OnPlayerKilled(player)
	end
end

-- =====================================================
-- UTILS
-- =====================================================
function ArenaBase:Shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

return ArenaBase
