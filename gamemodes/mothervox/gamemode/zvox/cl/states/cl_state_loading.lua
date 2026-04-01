ZVox = ZVox or {}

local state = ZVox.NewState(ZVOX_STATE_LOADING)

function state:Think()
end

function state:Render(pos, ang, fov)
	ZVox.RenderLoadScreen()

	return true
end


function state:OnEnter()
end

function state:OnExit()
end