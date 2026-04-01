ZVox = ZVox or {}
-- filebuffer, a clone to the NikNaks bitbuffer
-- NikNak's restrictive license is pretty dumb so we have to implement our own
-- Reasons NikNak's license is not suitable for this project:
--     - "Redistribution in the Steam® Workshop with or without modification, is not permitted without specific prior written permission."
--       | This makes it so for the workshop released builds of ZVox, that we have to add NikNaks as a required addon, which makes the installation
--       | process more confusing
--       | Requiring the whole library aswell is pretty heavy, meanwhile we only care about the filebuffer, this can be solved with scripts to unload the
--       | rest of the modules after init, but it still feels a hack and i feel like using small bits of it on separate should be allowed
--       | if you're seeing this nak, take it as a small suggestion that perhaps overly restrictive licenses on libraries aren't a good thing!
--
-- Also, this file (ONLY) is licensed under the MIT license, rather than the global license, refer to README for more info
-- So feel free to use it with your work

local math = math
local math_floor = math.floor
local math_log = math.log
local math_abs = math.abs
local math_ceil = math.ceil
local math_pow = math.pow

local table = table
local table_concat = table.concat

local string = string
local string_char = string.char
local string_byte = string.byte

local bit = bit
local bit_band = bit.band
local bit_bor = bit.bor
local bit_rshift = bit.rshift

--Used for bit-shifting
local f08 = math_pow(2, 8)
local f16 = math_pow(2,16)
local f24 = math_pow(2,24)
local f32 = math_pow(2,32)
local f40 = math_pow(2,40)
local f48 = math_pow(2,48)


local _IDX_CONTENTS = 1
local _IDX_CURSOR = 2
function ZVox.FB_NewFileBuffer()
	return {
		[_IDX_CONTENTS] = {},
		[_IDX_CURSOR] = 1,
	}
end

function ZVox.FB_NewFileBufferFromData(data)
	local buff = ZVox.FB_NewFileBuffer()
	for i = 1, #data do
		buff[_IDX_CONTENTS][i] = data[i]
	end

	return buff
end

function ZVox.FB_NewFileBufferFromFile(filePath)
	local fPtr = file.Open(filePath, "rb", "DATA")
	if not fPtr then
		return
	end

	local cont = fPtr:Read()
	fPtr:Close()

	local buff = ZVox.FB_NewFileBuffer()
	for i = 1, #cont do
		buff[_IDX_CONTENTS][i] = cont[i]
	end

	return buff
end


function ZVox.FB_Seek(buff, bytePos)
	buff[_IDX_CURSOR] = bytePos
end

function ZVox.FB_Skip(buff, bytesSkip)
	buff[_IDX_CURSOR] = buff[_IDX_CURSOR] + bytesSkip
end

function ZVox.FB_Tell(buff)
	return buff[_IDX_CURSOR]
end

function ZVox.FB_EndOfFile(buff)
	return buff[_IDX_CONTENTS][buff[_IDX_CURSOR]] == nil
end

function ZVox.FB_Size(buff)
	return #buff[_IDX_CONTENTS]
end

function ZVox.FB_Close(buff)
	buff[_IDX_CURSOR] = nil
	buff[_IDX_CONTENTS] = nil

	buff = nil
end

function ZVox.FB_Clear(buff)
	buff[_IDX_CURSOR] = 1
	buff[_IDX_CONTENTS] = {}
end

function ZVox.FB_GetContents(buff)
	return table_concat(buff[_IDX_CONTENTS], "")
end

function ZVox.FB_DumpToDisk(buff, filePath)
	local fPtr = file.Open(filePath, "wb", "DATA")
	if not fPtr then
		return false
	end

	fPtr:Write(ZVox.FB_GetContents(buff))
	fPtr:Close()

	return true
end

function ZVox.FB_Write(buff, data)
	local cursor = buff[_IDX_CURSOR]

	for i = 1, #data do
		buff[_IDX_CONTENTS][cursor + (i - 1)] = data[i]
	end
	buff[_IDX_CURSOR] = cursor + #data
end

function ZVox.FB_Read(buff, len)
	local cursor = buff[_IDX_CURSOR]

	local _concatRet = {}
	for i = 1, len do
		_concatRet[i] = buff[_IDX_CONTENTS][cursor + (i - 1)]
	end
	buff[_IDX_CURSOR] = cursor + len

	return table_concat(_concatRet, "")
end

--
-- BOOL
--
function ZVox.FB_WriteBool(buff, bool)
	local cursor = buff[_IDX_CURSOR]

	buff[_IDX_CONTENTS][cursor] = string_char(bool and 0x1 or 0x0)
	buff[_IDX_CURSOR] = cursor + 1
end

function ZVox.FB_ReadBool(buff)
	local cursor = buff[_IDX_CURSOR]
	buff[_IDX_CURSOR] = cursor + 1

	return string_byte(buff[_IDX_CONTENTS][cursor]) == 0x1
end


--
-- UNSIGNED INT
--
local uint8_t_mask = 0xFF
function ZVox.FB_WriteByte(buff, uint8_t)
	local cursor = buff[_IDX_CURSOR]

	buff[_IDX_CONTENTS][cursor] = string_char(bit_band(uint8_t_mask, uint8_t))
	buff[_IDX_CURSOR] = cursor + 1
end

function ZVox.FB_ReadByte(buff)
	local cursor = buff[_IDX_CURSOR]
	buff[_IDX_CURSOR] = cursor + 1

	return string_byte(buff[_IDX_CONTENTS][cursor])
end


--
-- SIGNED LONG 
--
function ZVox.FB_WriteLong(buff, int32_t)
	local cursor = buff[_IDX_CURSOR]

	buff[_IDX_CONTENTS][cursor] = string_char(bit_band(int32_t, 0xFF))
	buff[_IDX_CONTENTS][cursor + 1] = string_char(bit_band(bit_rshift(int32_t, 8), 0xFF))
	buff[_IDX_CONTENTS][cursor + 2] = string_char(bit_band(bit_rshift(int32_t, 16), 0xFF))
	buff[_IDX_CONTENTS][cursor + 3] = string_char(bit_band(bit_rshift(int32_t, 24), 0xFF))
	buff[_IDX_CURSOR] = cursor + 4
end

local sign_invert_long = 4294967296
function ZVox.FB_ReadLong(buff)
	local cursor = buff[_IDX_CURSOR]
	buff[_IDX_CURSOR] = cursor + 4

	-- read sign bit
	local f1 = string_byte(buff[_IDX_CONTENTS][cursor])
	local f2 = string_byte(buff[_IDX_CONTENTS][cursor + 1])
	local f3 = string_byte(buff[_IDX_CONTENTS][cursor + 2])
	local f4 = string_byte(buff[_IDX_CONTENTS][cursor + 3])
	local sign = bit_band(f4, 0x80)

	if sign > 0 then
		return -(sign_invert_long - (f1 + (f2 * f08) + (f3 * f16) + (f4 * f24)))
	else
		return f1 + (f2 * f08) + (f3 * f16) + (f4 * f24)
	end
end


--
-- UNSIGNED LONG 
--
function ZVox.FB_WriteULong(buff, uint32_t)
	local cursor = buff[_IDX_CURSOR]

	buff[_IDX_CONTENTS][cursor] = string_char(bit_band(uint32_t, 0xFF))
	buff[_IDX_CONTENTS][cursor + 1] = string_char(bit_band(bit_rshift(uint32_t, 8), 0xFF))
	buff[_IDX_CONTENTS][cursor + 2] = string_char(bit_band(bit_rshift(uint32_t, 16), 0xFF))
	buff[_IDX_CONTENTS][cursor + 3] = string_char(bit_band(bit_rshift(uint32_t, 24), 0xFF))
	buff[_IDX_CURSOR] = cursor + 4
end

function ZVox.FB_ReadULong(buff)
	local cursor = buff[_IDX_CURSOR]
	buff[_IDX_CURSOR] = cursor + 4

	local f1 = string_byte(buff[_IDX_CONTENTS][cursor])
	local f2 = string_byte(buff[_IDX_CONTENTS][cursor + 1])
	local f3 = string_byte(buff[_IDX_CONTENTS][cursor + 2])
	local f4 = string_byte(buff[_IDX_CONTENTS][cursor + 3])

	return f1 + (f2 * f08) + (f3 * f16) + (f4 * f24)
end


--
-- SIGNED SHORT 
--
function ZVox.FB_WriteShort(buff, int16_t)
	local cursor = buff[_IDX_CURSOR]

	buff[_IDX_CONTENTS][cursor] = string_char(bit_band(int16_t, 0xFF))
	buff[_IDX_CONTENTS][cursor + 1] = string_char(bit_band(bit_rshift(int16_t, 8), 0xFF))
	buff[_IDX_CURSOR] = cursor + 2
end

local sign_invert_short = 65536
function ZVox.FB_ReadShort(buff)
	local cursor = buff[_IDX_CURSOR]
	buff[_IDX_CURSOR] = cursor + 2

	-- read sign bit
	local f1 = string_byte(buff[_IDX_CONTENTS][cursor])
	local f2 = string_byte(buff[_IDX_CONTENTS][cursor + 1])
	local sign = bit_band(f2, 0x80)

	if sign > 0 then
		return -(sign_invert_short - (f1 + (f2 * f08)))
	else
		return f1 + (f2 * f08)
	end
end


--
-- UNSIGNED SHORT 
--
function ZVox.FB_WriteUShort(buff, uint16_t)
	local cursor = buff[_IDX_CURSOR]

	buff[_IDX_CONTENTS][cursor] = string_char(bit_band(uint16_t, 0xFF))
	buff[_IDX_CONTENTS][cursor + 1] = string_char(bit_band(bit_rshift(uint16_t, 8), 0xFF))
	buff[_IDX_CURSOR] = cursor + 2
end

function ZVox.FB_ReadUShort(buff)
	local cursor = buff[_IDX_CURSOR]
	buff[_IDX_CURSOR] = cursor + 2

	local f1 = string_byte(buff[_IDX_CONTENTS][cursor])
	local f2 = string_byte(buff[_IDX_CONTENTS][cursor + 1])

	return f1 + (f2 * f08)
end



-- IEEE 754 methods use this
-- https://stackoverflow.com/questions/9168049/parsing-ieee754-double-precision-floats-in-pure-lua
local log2 = math_log(2)

--
-- DOUBLE 
--
local pow2to52 = math_pow(2,52)
function ZVox.FB_WriteDouble(buff, number)
	local cursor = buff[_IDX_CURSOR]

	--Separate out the sign, exponent and fraction
	local sign      = number < 0 and 1 or 0
	local exponent  = math_ceil(math_log(math_abs(number)) / log2) - 1
	local fraction  = math_abs(number) / math_pow(2,exponent) - 1

	--Make sure the exponent stays in range - allowed values are -1023 through 1024
	if (exponent < -1023) then
		--We allow this case for subnormal numbers and just clamp the exponent and re-calculate the fraction
		--without the offset of 1
		exponent = -1023
		fraction = math_abs(number) / math_pow(2,exponent)
	elseif (exponent > 1024) then
		--If the exponent ever goes above this value, something went horribly wrong and we should probably stop
		return
	end

	--Handle special cases
	if (number == 0) then
		--Zero
		exponent = -1023
		fraction = 0
	elseif (math_abs(number) == math.huge) then
		--Infinity
		exponent = 1024
		fraction = 0
	elseif (number ~= number) then
		--NaN
		exponent = 1024
		fraction = (pow2to52-1) / pow2to52
	end

	--Prepare the values for encoding
	local expOut = exponent + 1023                                  --The exponent is an 11 bit offset-binary
	local fractionOut = fraction * pow2to52                         --The fraction is 52 bit, so multiplying it by 2^52 will give us an integer

	buff[_IDX_CONTENTS][cursor] = string_char(math_floor(fractionOut % 256))
	buff[_IDX_CONTENTS][cursor + 1] = string_char(math_floor(fractionOut / f08) % 256)
	buff[_IDX_CONTENTS][cursor + 2] = string_char(math_floor(fractionOut / f16) % 256)
	buff[_IDX_CONTENTS][cursor + 3] = string_char(math_floor(fractionOut / f24) % 256)
	buff[_IDX_CONTENTS][cursor + 4] = string_char(math_floor(fractionOut / f32) % 256)
	buff[_IDX_CONTENTS][cursor + 5] = string_char(math_floor(fractionOut / f40) % 256)
	buff[_IDX_CONTENTS][cursor + 6] = string_char((expOut % 16) * 16 + math_floor(fractionOut / f48))
	buff[_IDX_CONTENTS][cursor + 7] = string_char(128 * sign + math_floor(expOut / 16))
	buff[_IDX_CURSOR] = cursor + 8
end

function ZVox.FB_ReadDouble(buff, number)
	local cursor = buff[_IDX_CURSOR]
	buff[_IDX_CURSOR] = cursor + 8

	local f1 = string_byte(buff[_IDX_CONTENTS][cursor])
	local f2 = string_byte(buff[_IDX_CONTENTS][cursor + 1])
	local f3 = string_byte(buff[_IDX_CONTENTS][cursor + 2])
	local f4 = string_byte(buff[_IDX_CONTENTS][cursor + 3])
	local f5 = string_byte(buff[_IDX_CONTENTS][cursor + 4])
	local f6 = string_byte(buff[_IDX_CONTENTS][cursor + 5])
	local f7 = string_byte(buff[_IDX_CONTENTS][cursor + 6])
	local f8 = string_byte(buff[_IDX_CONTENTS][cursor + 7])

	--Separate out the values
	local sign = f8 >= 128 and 1 or 0

	local exponent = (f8 % 128) * 16 + math.floor(f7 / 16)

	local fraction = (f7 % 16) * f48
					+ f6 * f40 + f5 * f32 + f4 * f24
					+ f3 * f16 + f2 * f08 + f1

	--Handle special cases
	if (exponent == 2047) then
		if (fraction == 0) then --Infinities
			return math_pow(-1,sign) * math.huge
		end

		if (fraction == pow2to52-1) then --NaN
			return 0 / 0
		end
	end

	--Combine the values and return the result
	if (exponent == 0) then
	   --Handle subnormal numbers
	   return math_pow(-1, sign) * math_pow(2,exponent - 1023) * (fraction / pow2to52)
	else
	   --Handle normal numbers
	   return math_pow(-1, sign) * math_pow(2,exponent - 1023) * (fraction / pow2to52 + 1)
	end
end



--
-- FLOAT 
--
local pow2to23 = math_pow(2,23)
function ZVox.FB_WriteFloat(buff, number)
	local cursor = buff[_IDX_CURSOR]

	--Separate out the sign, exponent and fraction
	local sign      = number < 0 and 1 or 0
	local exponent  = math_ceil(math_log(math_abs(number)) / log2) - 1
	local fraction  = math_abs(number) / math_pow(2, exponent) - 1

	--Make sure the exponent stays in range - allowed values are -127 through 128
	if (exponent < -127) then
		--We allow this case for subnormal numbers and just clamp the exponent and re-calculate the fraction
		--without the offset of 1
		exponent = -127
		fraction = math_abs(number) / math_pow(2,exponent)
	elseif (exponent > 128) then
		--If the exponent ever goes above this value, something went horribly wrong and we should probably stop
		return
	end

	--Handle special cases
	if (number == 0) then --Zero
		exponent = -127
		fraction = 0
	elseif (math_abs(number) == math.huge) then --Infinity
		exponent = 128
		fraction = 0
	elseif (number ~= number) then --NaN
		exponent = 128
		fraction = (pow2to23-1) / pow2to23
	end

	--Prepare the values for encoding
	local expOut = exponent + 127                                  --The exponent is an 8 bit offset-binary
	local fractionOut = fraction * pow2to23                         --The fraction is 23 bit, so multiplying it by 2^23 will give us an integer

	buff[_IDX_CONTENTS][cursor] = string_char(math_floor(fractionOut % 256)) -- 8
	buff[_IDX_CONTENTS][cursor + 1] = string_char(math_floor(fractionOut / f08) % 256) -- 16
	buff[_IDX_CONTENTS][cursor + 2] = string_char((expOut % 2) * 128 + math_floor(fractionOut / f16)) -- 23
	buff[_IDX_CONTENTS][cursor + 3] = string_char((128 * sign) + math_floor(expOut / 2))
	buff[_IDX_CURSOR] = cursor + 4
end

function ZVox.FB_ReadFloat(buff, number)
	local cursor = buff[_IDX_CURSOR]
	buff[_IDX_CURSOR] = cursor + 4

	local f1 = string_byte(buff[_IDX_CONTENTS][cursor])
	local f2 = string_byte(buff[_IDX_CONTENTS][cursor + 1])
	local f3 = string_byte(buff[_IDX_CONTENTS][cursor + 2])
	local f4 = string_byte(buff[_IDX_CONTENTS][cursor + 3])

	--Separate out the values
	local sign = f4 >= 128 and 1 or 0
	local exponent = (f4 % 128) * 2 + math.floor(f3 / 128)
	local fraction = (f3 % 128) * f16
					+ f2 * f08 + f1


	--Handle special cases
	if (exponent == 128) then
		if (fraction == 0) then --Infinities
			return math_pow(-1,sign) * math.huge
		end

		if (fraction == pow2to23-1) then --NaN
			return 0 / 0
		end
	end

	--Combine the values and return the result
	if (exponent == 0) then
	   --Handle subnormal numbers
	   return math_pow(-1, sign) * math_pow(2,exponent - 127) * (fraction / pow2to23)
	else
	   --Handle normal numbers
	   return math_pow(-1, sign) * math_pow(2,exponent - 127) * (fraction / pow2to23 + 1)
	end
end



-- helper methods
function ZVox.FB_WriteString(fBuff, str)
	ZVox.FB_WriteULong(fBuff, #str)
	ZVox.FB_Write(fBuff, str)
end

function ZVox.FB_ReadString(fBuff)
	return ZVox.FB_Read(fBuff, ZVox.FB_ReadULong(fBuff))
end

