ZVox = ZVox or {}

local cameraMode = false
ZVox.NewControlListener("cam_hide", "switch_hide", function()
	cameraMode = not cameraMode
	ZVox.PrintDebug("Camera mode: " .. (cameraMode and "ON" or "OFF"))
end)

function ZVox.GetCameraModeState()
	return cameraMode
end

function ZVox.SetCameraModeState(state)
	cameraMode = state
end