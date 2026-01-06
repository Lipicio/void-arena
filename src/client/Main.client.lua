local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ControllersFolder = player:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Controllers")

for _, controller in ipairs(ControllersFolder:GetChildren()) do
	if controller:IsA("ModuleScript") then
		task.spawn(function()
			local ok, result = pcall(require, controller)
			if not ok then
				warn("❌ Erro ao carregar controller:", controller.Name, result)
			end
		end)
	end
end


print("[Client] Controllers carregados")
