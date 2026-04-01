ZVox = ZVox or {}


local _actBuff = {}
local _actBuffUniv = nil
local _actBuffStarted = false
function ZVox.BeginActionBuffer(univ)
	if _actBuffStarted then
		ZVox.PrintError("Beginning new action buffer with already started action buffer!")
		ZVox.PrintError("Something went wrong!")
	end

	_actBuffStarted = true
	_actBuff = {}
	_actBuffUniv = univ
end


function ZVox.PushActionToActionBuffer(act)
	_actBuff[#_actBuff + 1] = act
end

function ZVox.FlushActionBuffer()
	for i = 1, #_actBuff do
		local act = _actBuff[i]

		ZVox.CL_ExecuteAction(act)
	end
	_actBuffStarted = false
end