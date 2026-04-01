ZVox = ZVox or {}
local math = math
local math_min = math.min
local math_floor = math.floor

local table = table
local table_concat = table.concat
local table_move = table.move

local string = string
local string_byte = string.byte
local string_char = string.char

local unpack = unpack

local CONCAT_STEP_SIZE = 8 * 8 * 8
function ZVox.OLD_SerializeChunkVoxelData(voxelData)
	local charArray = {}
	for i = 1, #voxelData, CONCAT_STEP_SIZE do
		local endPack = math_min(i + CONCAT_STEP_SIZE, #voxelData)
		charArray[#charArray + 1] = string_char(unpack(voxelData, i - 1, endPack))
	end

	return table_concat(charArray, "")
end

function ZVox.OLD_DeSerializeChunkVoxelData(data)
	local byteArray = {}
	local _temp = {}
	for i = 0, #data, CONCAT_STEP_SIZE do
		local endAdd = math_min(i + CONCAT_STEP_SIZE, #data)

		_temp = {string_byte(data, i + 1, endAdd)}
		table_move(_temp, 1, CONCAT_STEP_SIZE, i, byteArray)
	end

	return byteArray
end


local STRING_EMPTY = ""
local THRESHOLD_7BIT  = (2^7) -- - 1
local THRESHOLD_14BIT = (2^14) -- - 1
local THRESHOLD_21BIT = (2^21) -- - 1
local THRESHOLD_28BIT = (2^28) -- - 1

local toCharLongArr = {}
local function toCharLong(num)
	if num >= THRESHOLD_21BIT then -- 28bit
		--toCharLongArr[1] = string_char((math_floor(num) % 128) + 128)
		--toCharLongArr[2] = string_char((math_floor(num / THRESHOLD_7BIT) % 128) + 128)
		--toCharLongArr[3] = string_char((math_floor(num / THRESHOLD_14BIT) % 128) + 128)
		--toCharLongArr[4] = string_char(math_floor(num / THRESHOLD_21BIT) % 128)

		return string_char((math_floor(num) % 128) + 128) .. string_char((math_floor(num / THRESHOLD_7BIT) % 128) + 128) .. string_char((math_floor(num / THRESHOLD_14BIT) % 128) + 128) .. string_char(math_floor(num / THRESHOLD_21BIT) % 128)
	elseif num >= THRESHOLD_14BIT then -- 21bit
		--toCharLongArr[1] = string_char((math_floor(num) % 128) + 128)
		--toCharLongArr[2] = string_char((math_floor(num / THRESHOLD_7BIT) % 128) + 128)
		--toCharLongArr[3] = string_char(math_floor(num / THRESHOLD_14BIT) % 128)
		--toCharLongArr[4] = nil

		return string_char((math_floor(num) % 128) + 128) .. string_char((math_floor(num / THRESHOLD_7BIT) % 128) + 128) .. string_char(math_floor(num / THRESHOLD_14BIT) % 128)
	elseif num >= THRESHOLD_7BIT then -- 14bit
		--toCharLongArr[1] = string_char((math_floor(num) % 128) + 128)
		--toCharLongArr[2] = string_char(math_floor(num / THRESHOLD_7BIT) % 128)
		--toCharLongArr[3] = nil
		--toCharLongArr[4] = nil

		return string_char((math_floor(num) % 128) + 128) .. string_char(math_floor(num / THRESHOLD_7BIT) % 128)
	else -- 7bit
		return string_char(math_floor(num) % 128)
	end

	--return table_concat(toCharLongArr, STRING_EMPTY)
end

-- this does runlength encoding
local RLE_MAX = 255

local chDataArray = {}
function ZVox.SerializeChunkVoxelData(voxelData)
	chDataArray = {}
	local dataLen = #voxelData


	local writePtr = 1

	local len = 1
	local dataNext = 0
	local prev = voxelData[0]
	for i = 0, #voxelData do
		dataNext = voxelData[i + 1]

		if (i < dataLen) and (prev == dataNext) and (len < RLE_MAX) then
			len = len + 1
		else
			chDataArray[writePtr] = string_char(len)
			chDataArray[writePtr + 1] = toCharLong(prev)

			writePtr = writePtr + 2

			len = 1
		end
		prev = dataNext
	end

	return table_concat(chDataArray, "")
end

local deSerialMultTable = {
	[0] = 1,
	[1] = THRESHOLD_7BIT,
	[2] = THRESHOLD_14BIT,
	[3] = THRESHOLD_21BIT,
}
function ZVox.DeSerializeChunkVoxelData(data)
	local retData = {}
	local pushAccum = 0
	local valMultiplicative = 0
	local valAcc = 0
	local read = 0

	local lenFlag = false
	local currLen = 0

	for i = 1, #data do
		if not lenFlag then
			currLen = string_byte(data[i])
			lenFlag = true
		else
			read = string_byte(data[i])
			valAcc = valAcc + ((read % 128) * deSerialMultTable[valMultiplicative])
			valMultiplicative = valMultiplicative + 1
			if read >= 128 then -- there's a next one
				continue
			end

			lenFlag = false -- done reading varint, write with len
			for j = 0, currLen - 1 do
				retData[pushAccum + j] = valAcc
			end
			pushAccum = pushAccum + currLen

			valAcc = 0
			valMultiplicative = 0
		end
	end
	return retData
end