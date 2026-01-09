local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Controller = {}

local player = Players.LocalPlayer

local Network = ReplicatedStorage.Shared.Network
local MusicContext = require(Network.MusicContext)
local LastMap = nil

local GameConfig = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Configs")
		:WaitForChild("GameConfig")
)

-- =====================================================
-- Sound instance (LOCAL)
-- =====================================================
local sound = Instance.new("Sound")
sound.Name = "BackgroundMusic"
sound.Looped = true
sound.Volume = 0.02
sound.Parent = SoundService

-- =====================================================
-- Utils
-- =====================================================
local function stop()
	if sound.IsPlaying then
		sound:Stop()
	end
end

local function playRandom(ids)
	if not ids or #ids == 0 then return end

	stop()

	sound.SoundId = ids[math.random(#ids)]

	task.delay(0.1, function()
		pcall(function()
			sound:Play()
		end)
	end)
end

-- =====================================================
-- Context handler
-- =====================================================
MusicContext.onClient(function(data)
	if not data or not data.context then return end

    if LastMap == data.context then return    
	elseif data.context == "ARENA" then 
		playRandom(data.musicIds)
	elseif data.context == "LOBBY" then
		playRandom(GameConfig.LOBBY_MUSIC_IDS)
	end

    LastMap = data.context
end)

-- =====================================================
-- Segurança: sempre começa no lobby
-- =====================================================
task.delay(1, function()
	playRandom(GameConfig.LOBBY_MUSIC_IDS)
    LastMap = "LOBBY"
end)

return Controller
