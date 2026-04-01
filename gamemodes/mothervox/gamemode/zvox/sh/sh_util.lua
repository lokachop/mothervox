ZVox = ZVox or {}
if SERVER then
	util.AddNetworkString("zvox_command_notify")
end

if CLIENT then
	net.Receive("zvox_command_notify", function(len)
		local msg = net.ReadString()

		ZVox.CommandErrorNotify(LocalPlayer(), msg, true)
	end)
end


local _rateLimitLUT = {}
local function rateLimit(ply, intent, time)
	if not _rateLimitLUT[ply] then
		_rateLimitLUT[ply] = {}
	end

	if not _rateLimitLUT[ply][intent] then
		_rateLimitLUT[ply][intent] = 0
	end

	local nextCan = _rateLimitLUT[ply][intent]
	if CurTime() < nextCan then
		return true
	end

	_rateLimitLUT[ply][intent] = CurTime() + time
	return false
end


local _zvoxCol = Color(65, 201, 100)

local _whiteCol = Color(255, 255, 255)

local _clientCol = Color(255, 196, 128)
local _serverCol = Color(128, 196, 255)
function ZVox.CommandErrorNotify(ply, msg, server)
	if SERVER then
		if rateLimit(ply, "commandError", 0.2) then
			return
		end

		net.Start("zvox_command_notify")
			net.WriteString(msg)
		net.Send(ply)
		return
	end

	if not msg then
		msg = ply
	end
	MsgC(_zvoxCol, "[ZVox] ", server and _serverCol or _clientCol, msg, "\n")
end