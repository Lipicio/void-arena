local GameConfig = {}

-- =========================
-- MATCH / ROUND SETTINGS
-- =========================

-- Tempo (em segundos) entre cada queda de chão
GameConfig.GROUND_FALL_INTERVAL = 0.5

-- Quantidade de Grounds que caem por ciclo
GameConfig.GROUNDS_PER_CYCLE = 5

-- Tempo de delay visual antes do chão cair (efeito / warning)
GameConfig.GROUND_WARNING_TIME = 0.8

-- Quantidade minima de jogadores para a partida começar
GameConfig.MIN_PLAYERS = 1


-- =========================
-- MATCH FLOW
-- =========================

-- Tempo de espera no lobby antes de iniciar a partida
GameConfig.LOBBY_WAIT_TIME = 5

-- Tempo após vitória antes de resetar
GameConfig.END_MATCH_DELAY = 1


return GameConfig
