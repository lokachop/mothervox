ZVox = ZVox or {}

--
-- Debug
-- 
local currOutboundAccum = 0
local outboundActionsPerSec = 0
function ZVox.GetOutboundActionsPerSec()
	return outboundActionsPerSec
end

local currInboundAccum = 0
local inboundActionsPerSec = 0
function ZVox.GetInboundActionsPerSec()
	return inboundActionsPerSec
end

local nextClear = CurTime()
local function actionsPerSecThink()
	if CurTime() <= nextClear then
		return
	end
	nextClear = CurTime() + 1

	outboundActionsPerSec = currOutboundAccum
	currOutboundAccum = 0

	inboundActionsPerSec = currInboundAccum
	currInboundAccum = 0
end

function ZVox.ActionDebugThink()
	actionsPerSecThink()
end

function ZVox.IncInboundActions()
	currInboundAccum = currInboundAccum + 1
end

function ZVox.IncOutboundActions()
	currOutboundAccum = currOutboundAccum + 1
end