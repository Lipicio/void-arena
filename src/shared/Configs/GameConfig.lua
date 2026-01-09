local GameConfig = {}

-- =========================
-- MATCH FLOW (GLOBAL)
-- =========================

-- Quantidade mínima de jogadores para iniciar
GameConfig.MIN_PLAYERS = 1

-- Tempo de espera no lobby antes de iniciar a partida
GameConfig.LOBBY_WAIT_TIME = 5

-- Tempo após vitória antes de resetar
GameConfig.END_MATCH_DELAY = 5

GameConfig.LOBBY_MUSIC_IDS = {
	"rbxassetid://1841998846",
	"rbxassetid://113158443139294",
	"rbxassetid://1843265221",
}

return GameConfig
