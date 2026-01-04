local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(
	ReplicatedStorage
		:WaitForChild("Shared")
		:WaitForChild("Remotes")
		:WaitForChild("Remotes")
)

local MatchController = {}

print("[Client] MatchController carregado")

-- avisa o server que este client está pronto
Remotes.ClientReady:FireServer()

Remotes.StartMatch.OnClientEvent:Connect(function(data)
	print("[Client] Round começou!")
	print("[Client] Tempo do round:", data.roundTime)
end)

return MatchController
