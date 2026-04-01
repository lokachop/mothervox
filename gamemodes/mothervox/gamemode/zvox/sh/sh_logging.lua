ZVox = ZVox or {}

ZVOX_DO_LOGGING = ZVOX_DO_LOGGING or file.Exists("zvox/enable_logging", "DATA")
if not ZVOX_DO_LOGGING then
	if ZVox.LogFileHandle then
		ZVox.LogFileHandle:Flush()
		ZVox.LogFileHandle:Close()
	end

	function ZVox.PushMessageToLogFile(msg) end
	function ZVox.CloseLogFile() end

	return
end

ZVox.LogFileHandle = ZVox.LogFileHandle
if not ZVox.LogFileHandle then
	ZVox.LogFileHandle = file.Open("zvox/zvox_log.txt", "w", "DATA")

	ZVox.LogFileHandle:Write(os.date("%d/%m/%Y (DD/MM/YYYY) %H:%M"))
	ZVox.LogFileHandle:Write("\n")
	ZVox.LogFileHandle:Write("-== " .. ZVOX_VERSION .. " Loaded ==-\n")
	ZVox.LogFileHandle:Flush()
else
	ZVox.LogFileHandle:Write("--==Lua refresh @@ " .. tostring(os.date("%H:%M")) .. ", sys" .. string.format("%5.4f", SysTime()) .. "==--\n")
	ZVox.LogFileHandle:Flush()
end

local function writeTimestamp()
	ZVox.LogFileHandle:Write("[" .. tostring(os.date("%H:%M")) .. ",sys" .. string.format("%5.8f", SysTime()) .. "] ")
end

function ZVox.PushMessageToLogFile(msg)
	writeTimestamp()

	ZVox.LogFileHandle:Write(msg .. "\n")
	ZVox.LogFileHandle:Flush()
end

function ZVox.CloseLogFile()
	ZVox.PushMessageToLogFile("-== " .. ZVOX_VERSION .. " shutting down ==-")

	ZVox.LogFileHandle:Close()
end