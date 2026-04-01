ZVox = ZVox or {}

function GM:StartCommand(ply, cmd)
	cmd:ClearMovement()
	cmd:ClearButtons()
	cmd:SetImpulse(0)
end