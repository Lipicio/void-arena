local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controller = {}

local player = Players.LocalPlayer

local CountdownEvent = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Remotes")
	:WaitForChild("RoundCountdown")

local container = nil
local textLabel = nil

-- =====================================================
-- Utils
-- =====================================================
local function resolveUI()
	local playerGui = player:WaitForChild("PlayerGui")
	local hud = playerGui:WaitForChild("HUD", 5)
	if not hud then return end

	container = hud:WaitForChild("LobbyCountdown", 5)
	if not container then return end

	textLabel = container:WaitForChild("Text", 5)
end

local function hide()
	if container then
		container.Visible = false
	end
end

local function show(value)
	if container and textLabel then
		container.Visible = true
		textLabel.Text = "Próxima rodada em " .. value .. "s"
	end
end

-- =====================================================
-- Re-resolve UI quando o character respawnar
-- =====================================================
player.CharacterAdded:Connect(function()
	task.wait(0.2)
	resolveUI()
	hide()
end)

-- Primeira resolução
resolveUI()
hide()

-- =====================================================
-- Remote listener
-- =====================================================
CountdownEvent.OnClientEvent:Connect(function(action, value)
	if not container or not textLabel then
		resolveUI()
		if not container or not textLabel then return end
	end

	if action == "start" then
		show(value)

	elseif action == "update" then
		show(value)

	elseif action == "stop" then
		hide()
	end
end)

return Controller
