ZVox = ZVox or {}

ZVox.LoadSettingsFromDisk() -- load settings
ZVox.LoadControlsFromDisk() -- load controls

-- set states
if ZVox.CurrentState == -1 then
	ZVox.SetState(ZVOX_STATE_MAINMENU)
else
	if not ZVOX_DO_STATE_REFRESH_ON_LUA_REFRESH then
		return
	end
	ZVox.SetState(ZVox.CurrentState)
end

HAD_WARNED_WRONG_BRANCH = HAD_WARNED_WRONG_BRANCH or false
if (BRANCH ~= "x86-64") and not HAD_WARNED_WRONG_BRANCH then
	ZVox.OpenWrongBranchWarning()
	HAD_WARNED_WRONG_BRANCH = true
end
