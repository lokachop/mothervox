-- Fun fact
-- The entire controls API is born to a random player joining the 24/7 testserver with a broken W key
-- They were confused as to if zvox rebound their controls, and asked if there was a way to change their controls
-- They were using the 1 key to walk forward rather than w, since their w key was broken
-- *They were also pasting the w anytime they had to say it*

ZVox = ZVox or {}

local controlRegistry = {}
local nameToIdxLUT = {}

function ZVox.GetControlRegistry()
	return controlRegistry
end

function ZVox.GetControlEntryByName(name)
	local idx = nameToIdxLUT[name]
	if not idx then
		return
	end

	return controlRegistry[idx]
end


-- should return a table of tables, sorted by category name
-- should be consistent, not random due to pairs()
function ZVox.GetCategorySortedRegistry()
	local categoryTable = {}
	local categoryIndexLUT = {}

	local lastIndexIdx = 0
	for i = 1, #controlRegistry do
		local entry = controlRegistry[i]

		local entryName = entry.name
		local entryCat = entry.cat

		if not categoryIndexLUT[entryCat] then
			lastIndexIdx = lastIndexIdx + 1
			categoryTable[lastIndexIdx] = {
				["name"] = entryCat,
			}

			categoryIndexLUT[entryCat] = lastIndexIdx
		end

		local idxInto = categoryIndexLUT[entryCat]

		local tblInto = categoryTable[idxInto]
		tblInto[#tblInto + 1] = entryName
	end

	-- sort alphabetically
	table.sort(categoryTable, function(a, b)
		local aName = a.name
		local bName = b.name

		return aName < bName
	end)

	return categoryTable
end




local lastIdx = 0
function ZVox.DeclareNewControl(name, dataTbl)
	lastIdx = lastIdx + 1

	controlRegistry[lastIdx] = {
		["name"] = name,

		["key"] = dataTbl.key,
		["defaultKey"] = dataTbl.key,

		["fancyName"] = dataTbl.fancyName or name,
		["cat"] = dataTbl.cat or "Misc.",

		["withCursor"] = dataTbl.withCursor or false,
	}

	nameToIdxLUT[name] = lastIdx
	ZVox.RecomputeControlConflictingTable()
end


function ZVox.IsControlDown(name)
	local ctrlEntry = ZVox.GetControlEntryByName(name)
	if not ctrlEntry then
		return false
	end

	if not ctrlEntry.withCursor and vgui.CursorVisible() then
		return false
	end

	local button = ctrlEntry.key
	return input.IsButtonDown(button)
end


function ZVox.RebindControl(name, newButton)
	local entry = ZVox.GetControlEntryByName(name)
	entry.key = newButton

	ZVox.RecomputeControlConflictingTable()
end

function ZVox.GetControlKey(name)
	local entry = ZVox.GetControlEntryByName(name)
	if not entry then
		return 0
	end

	return entry.key
end

local controlConflictLUT = {}
function ZVox.RecomputeControlConflictingTable()
	controlConflictLUT = {}

	local tmpConflictCalc = {}

	-- first fill with used count
	for i = 1, #controlRegistry do
		local entry = controlRegistry[i]

		local key = entry.key

		if not tmpConflictCalc[key] then
			tmpConflictCalc[key] = 0
		end

		tmpConflictCalc[key] = tmpConflictCalc[key] + 1
	end


	-- loop again, and check if > 1
	for i = 1, #controlRegistry do
		local entry = controlRegistry[i]

		local name = entry.name
		local key = entry.key

		local keyUseCount = tmpConflictCalc[key]

		controlConflictLUT[name] = keyUseCount > 1
	end
end

function ZVox.IsControlConflicting(name)
	return controlConflictLUT[name]
end



-- returns what button is down atm
-- only returns one
-- used for setting keys on settings
function ZVox.GetButtonDown()
	for i = 1, BUTTON_CODE_LAST do
		local down = input.IsButtonDown(i)

		if down then
			return i
		end
	end
end

function ZVox.GetButtonDownKeyboardOnly()
	for i = KEY_FIRST, KEY_END do
		local down = input.IsButtonDown(i)

		if down then
			return i
		end
	end
end

local buttonNiceNames = {
	[KEY_NONE] = "NONE",

	[KEY_0] = "0",
	[KEY_1] = "1",
	[KEY_2] = "2",
	[KEY_3] = "3",
	[KEY_4] = "4",
	[KEY_5] = "5",
	[KEY_6] = "6",
	[KEY_7] = "7",
	[KEY_8] = "8",
	[KEY_9] = "9",

	[KEY_PAD_0] = "KP 0",
	[KEY_PAD_1] = "KP 1",
	[KEY_PAD_2] = "KP 2",
	[KEY_PAD_3] = "KP 3",
	[KEY_PAD_4] = "KP 4",
	[KEY_PAD_5] = "KP 5",
	[KEY_PAD_6] = "KP 6",
	[KEY_PAD_7] = "KP 7",
	[KEY_PAD_8] = "KP 8",
	[KEY_PAD_9] = "KP 9",

	[KEY_PAD_DIVIDE]   = "KP /",
	[KEY_PAD_MULTIPLY] = "KP *",
	[KEY_PAD_MINUS]    = "KP -",
	[KEY_PAD_PLUS]     = "KP +",
	[KEY_PAD_ENTER]    = "KP ENTER",
	[KEY_PAD_DECIMAL]  = "KP .",

	[KEY_LBRACKET]   = "[",
	[KEY_RBRACKET]   = "]",
	[KEY_SEMICOLON]  = ";",
	[KEY_APOSTROPHE] = "APOSTROPHE",
	[KEY_BACKQUOTE]  = "BACKQUOTE",

	[KEY_COMMA]  = ",",
	[KEY_PERIOD] = ".",
	[KEY_SLASH]  = "/",
	[KEY_BACKSLASH] = "\\",
	[KEY_MINUS] = "-",
	[KEY_EQUAL] = "=",
	[KEY_ENTER] = "ENTER",
	[KEY_SPACE] = "SPACE",
	[KEY_BACKSPACE] = "BACKSPACE",
	[KEY_TAB] = "TAB",
	[KEY_CAPSLOCK] = "CAPSLOCK",
	[KEY_NUMLOCK] = "NUMLOCK",
	[KEY_ESCAPE] = "ESC",
	[KEY_SCROLLLOCK] = "SCROLLLOCK",
	[KEY_INSERT] = "INSERT",
	[KEY_DELETE] = "DEL",
	[KEY_HOME] = "HOME",
	[KEY_END] = "END",
	[KEY_PAGEUP] = "PAGEUP",
	[KEY_PAGEDOWN] = "PAGEDOWN",
	[KEY_BREAK] = "BREAK",
	[KEY_LSHIFT] = "LSHIFT",
	[KEY_RSHIFT] = "RSHIFT",
	[KEY_LALT] = "LALT",
	[KEY_RALT] = "RALT",
	[KEY_LCONTROL] = "LCONTROL",
	[KEY_RCONTROL] = "RCONTROL",
	[KEY_LWIN] = "LWIN",
	[KEY_RWIN] = "RWIN",
	[KEY_APP] = "APP",
	[KEY_UP] = "UPARROW",
	[KEY_LEFT] = "LEFTARROW",
	[KEY_DOWN] = "DOWNARROW",
	[KEY_RIGHT] = "RIGHTARROW",
	[KEY_F1] = "F1",
	[KEY_F2] = "F2",
	[KEY_F3] = "F3",
	[KEY_F4] = "F4",
	[KEY_F5] = "F5",
	[KEY_F6] = "F6",
	[KEY_F7] = "F7",
	[KEY_F8] = "F8",
	[KEY_F9] = "F9",
	[KEY_F10] = "F10",
	[KEY_F11] = "F11",
	[KEY_F12] = "F12",
	[KEY_CAPSLOCKTOGGLE] = "CAPSLOCK TOGGLE",
	[KEY_NUMLOCKTOGGLE] = "NUMLOCK TOGGLE",
	[KEY_SCROLLLOCKTOGGLE] = "SCROLLLOCK TOGGLE",


	-- mouse now
	[MOUSE_LEFT] = "LMB",
	[MOUSE_RIGHT] = "RMB",
	[MOUSE_MIDDLE] = "MMB",
	[MOUSE_4] = "MOUSE4",
	[MOUSE_5] = "MOUSE5",
	[MOUSE_WHEEL_UP] = "MWHEEL UP",
	[MOUSE_WHEEL_DOWN] = "MWHEEL DOWN",
}

for i = KEY_A, KEY_Z do
	local asciiChar = string.char(54 + i)

	buttonNiceNames[i] = asciiChar
end


function ZVox.GetButtonNiceName(key)
	return buttonNiceNames[key] or ("? #" .. key)
end


-- TODO: optimize
local controlListeners = {}
function ZVox.NewControlListener(controlName, listenerName, func)
	if not controlListeners[controlName] then
		controlListeners[controlName] = {}
	end

	controlListeners[controlName][listenerName] = func
end

local controlPrevDownTable = {}

-- THIS SUCKS
function ZVox.ControlListenerThink()
	for k, v in pairs(controlListeners) do
		local name = k
		local down = ZVox.IsControlDown(name)

		if down and not controlPrevDownTable[name] then
			controlPrevDownTable[name] = true

			for i, j in pairs(v) do
				local fine, err = pcall(j)
				if not fine then
					ZVox.PrintError("Error while running control hook \"" .. i .. "\" for the control \"" .. name .. "\"")
					ZVox.PrintError(err)
				end
			end

		elseif not down and controlPrevDownTable[name] then
			controlPrevDownTable[name] = false
		end
	end
end


function ZVox.SaveControlsToDisk()
	ZVox.PrintInfo("Saving the controls to disk...")

	local fBuff = ZVox.FB_NewFileBuffer()
	ZVox.FB_Write(fBuff, "CONT")
	ZVox.FB_WriteByte(fBuff, 1) -- v1

	local entryCount = #controlRegistry
	if entryCount > 65535 then
		ZVox.PrintError("Controls entryCount is over 65535, expect non-saved controls!")
	end
	ZVox.FB_WriteUShort(fBuff, entryCount)



	for i = 1, entryCount do
		local control = controlRegistry[i]

		local controlName = control.name
		local controlKey = control.key

		ZVox.FB_WriteUShort(fBuff, #controlName)
		ZVox.FB_Write(fBuff, controlName)

		ZVox.FB_WriteUShort(fBuff, controlKey)
	end

	ZVox.FB_DumpToDisk(fBuff, "zvox/zvox_controls.dat")
	ZVox.FB_Close(fBuff)
end

function ZVox.LoadControlsFromDisk()
	ZVox.PrintInfo("Loading the controls from disk...")

	local fBuff = ZVox.FB_NewFileBufferFromFile("zvox/zvox_controls.dat")
	if not fBuff then
		ZVox.PrintInfo("No controls file, creating one for next time...")
		ZVox.PrintInfo("Remember to check the controls with \"zvox_open_settings\"!")
		ZVox.SaveControlsToDisk()
		return
	end

	local magic = ZVox.FB_Read(fBuff, 4)
	if magic ~= "CONT" then
		ZVox.FB_Close(fBuff)
		ZVox.PrintError("Failed loading the controls from disk!")
		ZVox.PrintError("Magic doesn't match (file may be corrupted)")
		return
	end

	local ver = ZVox.FB_ReadByte(fBuff)
	-- we don't care about version yet

	local entryCount = ZVox.FB_ReadUShort(fBuff)
	for i = 1, entryCount do
		local nameLen = ZVox.FB_ReadUShort(fBuff)
		local name = ZVox.FB_Read(fBuff, nameLen)
		local key = ZVox.FB_ReadUShort(fBuff)


		local entry = ZVox.GetControlEntryByName(name)
		if not entry then
			ZVox.PrintError("Non-existant control \"" .. name .. "\", skipping...")
			continue
		end

		entry.key = key
	end

	ZVox.RecomputeControlConflictingTable()
	ZVox.FB_Close(fBuff)
end