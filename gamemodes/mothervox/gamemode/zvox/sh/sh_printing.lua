ZVox = ZVox or {}

local colZVox = Color(85, 220, 154)
local colDebug = Color(188, 150, 224)
local colText = Color(220, 220, 220)
local colRealm = CLIENT and Color(255, 128, 0) or Color(0, 128, 255)


local PRINTER_TYPE_DEBUG = 1
local PRINTER_TYPE_INFO = 2
local PRINTER_TYPE_ERROR = 3
local PRINTER_TYPE_FATAL = 4

local printerTypeStrLUT = {
	[PRINTER_TYPE_DEBUG] = "[DEBUG]",
	[PRINTER_TYPE_INFO ] = "[INFO ]",
	[PRINTER_TYPE_ERROR] = "[ERROR]",
	[PRINTER_TYPE_FATAL] = "[FATAL]",
}

local printerTypeColLUT = {
	[PRINTER_TYPE_DEBUG] = Color(32, 32, 32),
	[PRINTER_TYPE_INFO ] = Color(135, 135, 230),
	[PRINTER_TYPE_ERROR] = Color(220, 96, 96),
	[PRINTER_TYPE_FATAL] = Color(255, 32, 32),
}


local printerLevelTresholdLUT = {
	[PRINTER_TYPE_DEBUG] = 0,
	[PRINTER_TYPE_INFO ] = 1,
	[PRINTER_TYPE_ERROR] = 1,
	[PRINTER_TYPE_FATAL] = 1,
}


function ZVox.INTERNAL_MakePrinter(printerType, isAddon)
	local typeStr = printerTypeStrLUT[printerType]
	local typeCol = printerTypeColLUT[printerType]
	local typeTreshold = printerLevelTresholdLUT[printerType]


	return function(...)
		local appInfo = ""
		if ZVOX_DEVMODE then
			local infoStruct = debug.getinfo(2, "lS")

			local source = infoStruct.source


			if isAddon then
				source = string.sub(source, 2)
				source = string.match(source, "zvox_addons/(.*)")
			else
				source = string.sub(source, 2)
				source = string.match(source, "gamemode/(.*)")
			end

			appInfo = " " .. source .. "::" .. tostring(infoStruct.currentline)
		end

		if ZVOX_DO_LOGGING then -- log even if we don't print, this is important
			ZVox.PushMessageToLogFile("[ZVox " .. (CLIENT and "cl" or "sv") .. "] " .. typeStr .. appInfo .. ": " .. table.concat({...}))
		end

		if ZVox.PrintLevel > typeTreshold then
			return
		end

		MsgC(colRealm, "[ZVox] ", typeCol, typeStr, colDebug, appInfo, colText, ": ", ..., "\n")
	end
end

local dbg = ZVox.INTERNAL_MakePrinter(PRINTER_TYPE_DEBUG)
local nfo = ZVox.INTERNAL_MakePrinter(PRINTER_TYPE_INFO)
local err = ZVox.INTERNAL_MakePrinter(PRINTER_TYPE_ERROR)
local ftl = ZVox.INTERNAL_MakePrinter(PRINTER_TYPE_FATAL)

ZVox.PrintDebug = dbg
ZVox.PrintInfo = nfo
ZVox.PrintError = err
ZVox.PrintFatal = ftl

--ZVox.PrintDebug("hello world!")
--ZVox.PrintInfo("hello world!")
--ZVox.PrintError("hello world!")
--ZVox.PrintFatal("hello world!")