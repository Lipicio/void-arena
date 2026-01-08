local Remotes = require(script.Parent.Remotes)

local ArenaInfo = {}

-- Server → Client
function ArenaInfo.send(data)
	Remotes.ArenaInfo:FireAllClients(data)
end

-- Client listener
function ArenaInfo.onClient(callback)
	Remotes.ArenaInfo.OnClientEvent:Connect(callback)
end

return ArenaInfo
