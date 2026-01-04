local ServerScriptService = game:GetService("ServerScriptService")

local ServicesFolder = ServerScriptService
	:WaitForChild("Server")
	:WaitForChild("Services")

local ServiceRegistry = require(ServicesFolder:WaitForChild("ServiceRegistry"))

for _, module in ipairs(ServicesFolder:GetChildren()) do
	if module:IsA("ModuleScript") and module.Name ~= "ServiceRegistry" then
		local service = require(module)
		ServiceRegistry.register(module.Name, service)

		if service.start then
			service.start()
		end
	end
end

print("[Server] Services carregados")
