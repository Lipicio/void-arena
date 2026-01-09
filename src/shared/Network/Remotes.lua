local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folder = ReplicatedStorage:FindFirstChild("Remotes")
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "Remotes"
	folder.Parent = ReplicatedStorage
end

local function get(name)
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

return {
	RoundCountdown = get("RoundCountdown"),
	ArenaInfo = get("ArenaInfo"),
	AliveCount = get("AliveCount"),
	MusicContext = get("MusicContext"),
}
