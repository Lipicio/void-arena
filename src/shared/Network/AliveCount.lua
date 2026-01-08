local Remotes = require(script.Parent.Remotes)

local AliveCount = {}

-- =========================
-- Server → Client
-- =========================
function AliveCount.send(alive, total)
	Remotes.AliveCount:FireAllClients({
		alive = alive,
		total = total
	})
end

-- =========================
-- Client listener
-- =========================
function AliveCount.onClient(callback)
	Remotes.AliveCount.OnClientEvent:Connect(callback)
end

return AliveCount
