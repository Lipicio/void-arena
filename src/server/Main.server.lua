local ServerScriptService = game:GetService("ServerScriptService")

local ServicesFolder = ServerScriptService:WaitForChild("Server"):WaitForChild("Services")

for _, service in ipairs(ServicesFolder:GetChildren()) do
	if service:IsA("ModuleScript") then
		task.spawn(function()
			require(service)
		end)
	end
end

print("[Server] Services carregados")
