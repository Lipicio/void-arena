local Remotes = require(script.Parent.Remotes)

local MusicContext = {}

-- =========================
-- Server → Client
-- =========================
function MusicContext.send(context, music)
	Remotes.MusicContext:FireAllClients({
		context = context,
		musicIds = music
	})
end

-- =========================
-- Client listener
-- =========================
function MusicContext.onClient(callback)
	Remotes.MusicContext.OnClientEvent:Connect(callback)
end

return MusicContext
