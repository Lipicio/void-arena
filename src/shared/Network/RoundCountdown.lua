local Remotes = require(script.Parent.Remotes)

local RoundCountdown = {}

-- =========================
-- Server → Client
-- =========================
function RoundCountdown.start(seconds)
	Remotes.RoundCountdown:FireAllClients("start", seconds)
end

function RoundCountdown.update(seconds)
	Remotes.RoundCountdown:FireAllClients("update", seconds)
end

function RoundCountdown.stop()
	Remotes.RoundCountdown:FireAllClients("stop")
end

-- =========================
-- Client listener
-- =========================
function RoundCountdown.onClient(callback)
	Remotes.RoundCountdown.OnClientEvent:Connect(callback)
end

return RoundCountdown
