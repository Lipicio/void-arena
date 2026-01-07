local Utils = {}

function Utils.tableSize(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count += 1
	end
	return count
end

return Utils