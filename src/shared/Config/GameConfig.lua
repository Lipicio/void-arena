local GameConfig = {}

-- =========================
-- MATCH / ROUND SETTINGS
-- =========================

-- Tempo (em segundos) entre cada queda de chão
GameConfig.GROUND_FALL_INTERVAL = 2.5

-- Quantidade de Grounds que caem por ciclo
GameConfig.GROUNDS_PER_CYCLE = 1

-- Tempo de delay visual antes do chão cair (efeito / warning)
GameConfig.GROUND_WARNING_TIME = 0.8


-- =========================
-- MATCH FLOW
-- =========================

-- Tempo de espera no lobby antes de iniciar a partida
GameConfig.LOBBY_WAIT_TIME = 10

-- Tempo após vitória antes de resetar
GameConfig.END_MATCH_DELAY = 5


return GameConfig
