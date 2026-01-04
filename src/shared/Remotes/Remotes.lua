local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "Remotes"
	RemotesFolder.Parent = ReplicatedStorage
end

local function getRemote(name)
	local remote = RemotesFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = RemotesFolder
	end
	return remote
end

return {
	-- server → client
	StartMatch = getRemote("StartMatch"),
	MatchEnded = getRemote("MatchEnded"),
	PlayerEliminated = getRemote("PlayerEliminated"),

	-- client → server
	RequestJoinMatch = getRemote("RequestJoinMatch"),
	ClientReady = getRemote("ClientReady"),
}
