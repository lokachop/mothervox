ZVox = ZVox or {}

local stateRegistry = {}
function ZVox.NewState(stateID)
	stateRegistry[stateID] = {}

	return stateRegistry[stateID]
end

function ZVox.GetStateRegistryEntry(stateID)
	return stateRegistry[stateID]
end

ZVox.CurrentState = ZVox.CurrentState or -1
function ZVox.SetState(newState)
	local new = stateRegistry[newState]
	if not new then
		return
	end

	local curr = stateRegistry[ZVox.CurrentState]
	if curr and curr.OnExit then
		curr.OnExit()
	end

	ZVox.CurrentState = newState

	if new.OnEnter then
		new.OnEnter()
	end
end

function ZVox.GetState()
	return ZVox.CurrentState
end



function ZVox.CallStateThink()
	local curr = stateRegistry[ZVox.CurrentState]

	if curr and curr.Think then
		curr:Think()
	end
end

function ZVox.CallStateRender(pos, ang, fov)
	local curr = stateRegistry[ZVox.CurrentState]

	if curr and curr.Render then
		cam.Start2D()
			local ret = curr:Render(pos, ang, fov)
		cam.End2D()

		return ret
	end
end