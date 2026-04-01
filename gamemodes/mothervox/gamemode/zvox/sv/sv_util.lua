ZVox = ZVox or {}

function ZVox.SV_GetNetOmitForUniverse(univ, ply)
	local omit = {}

	if ply then
		omit = {ply}
	end

	for k, v in player.Iterator() do
		if v._zvox_enabled and (v._zvox_universe == univ) then
			continue
		end

		omit[#omit + 1] = v
	end

	return omit
end

function ZVox.SV_GetPlayerZVoxUniverse(ply)
	return ply._zvox_universe
end

function ZVox.SV_GetPlayerZVoxActive(ply)
	return ply._zvox_enabled
end


function ZVox.SV_GetUniversePlayers(univ)
	local plys = {}
	for k, v in player.Iterator() do
		if not v._zvox_enabled then
			continue
		end

		if (v._zvox_universe ~= univ) then
			continue
		end

		plys[#plys + 1] = v
	end

	return plys
end

-- TODO: implement it so it doesn't recompute it like this
-- it should add 1 when a client connects to one and remove one when a client disconnects
-- this is wasteful!

local _univPlayerCounts = {}
function ZVox.SV_RecomputeUniversePlayerCounts()
	_univPlayerCounts = {} -- TODO: bad!, with the new method it should not need to create new objects
	for k, v in player.Iterator() do
		if not v._zvox_enabled then
			continue
		end

		local univ = ZVox.SV_GetPlayerZVoxUniverse(v)
		if not _univPlayerCounts[univ] then
			_univPlayerCounts[univ] = 0
		end

		_univPlayerCounts[univ] = _univPlayerCounts[univ] + 1
	end
end


function ZVox.SV_GetUniversePlayerCount(univ)
	return _univPlayerCounts[univ] or 0
end