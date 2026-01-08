local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controller = {}
local player = Players.LocalPlayer

local Network = ReplicatedStorage.Shared.Network
local ArenaInfo = require(Network.ArenaInfo)

local frame, label

local function resolveUI()
	local hud = player:WaitForChild("PlayerGui"):WaitForChild("HUD")
	frame = hud:WaitForChild("TopLeftHUD"):WaitForChild("ArenaPill")
	label = frame:WaitForChild("Text")
	frame.Visible = false
end

player.CharacterAdded:Connect(function()
	task.wait(0.2)
	resolveUI()
end)

resolveUI()

ArenaInfo.onClient(function(data)
	if not frame or not label then resolveUI() end
	if not data or not data.name then return end

	label.Text = "🏟 " .. data.name
	frame.Visible = true
end)

return Controller
