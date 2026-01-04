local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Remotes")
		:WaitForChild("Remotes")
)

local MatchService = {}

function MatchService.start()
	print("[Server] MatchService iniciado")

	Remotes.ClientReady.OnServerEvent:Connect(function(player)
		print("[Server] Client pronto:", player.Name)
		MatchService.startMatch(player)
	end)
end

function MatchService.startMatch(player)
	print("[Server] Partida iniciada para:", player.Name)

	Remotes.StartMatch:FireClient(player, {
		roundTime = 60
	})
end

return MatchService