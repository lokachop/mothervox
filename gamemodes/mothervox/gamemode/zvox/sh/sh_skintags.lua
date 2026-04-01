ZVox = ZVox or {}
ZVOX_SKINTAG_TYPE_PREFAB = 1 --"PFAB"
ZVOX_SKINTAG_TYPE_SKIN = 2 --"SKIN"
ZVOX_SKINTAG_TYPE_CLIENTSKIN = 3 --"CLSK"

-- These are a BITMASK!
ZVOX_SKINTAG_FLAG_SLIM = 1

local valid_tag_types = {
	[ZVOX_SKINTAG_TYPE_PREFAB] = true,
	[ZVOX_SKINTAG_TYPE_SKIN] = true,
	[ZVOX_SKINTAG_TYPE_CLIENTSKIN] = true,
}

-- type is a constant
-- ex. ZVOX_SKINTAG_TYPE_SKIN
-- flags is for flags its 4 long string
-- data is the contents
function ZVox.ComposeSkinTag(tagType, flags, data, cape)
	tagType = tagType or 0
	if not valid_tag_types[tagType] then
		tagType = ZVOX_SKINTAG_TYPE_PREFAB
		flags = 0x0
		data = "prefab1"
		cape = ""
	end


	return {
		["type"] = tagType,
		["flags"] = flags,
		["data"] = data,
		["cape"] = cape or "",
	}
end

function ZVox.GetTypeFromSkinTag(skinTag)
	return skinTag.type
end
function ZVox.SetSkinTagType(skinTag, tagType)
	skinTag.type = tagType
end

function ZVox.GetFlagsFromSkinTag(skinTag)
	return skinTag.flags
end
function ZVox.SetSkinTagFlags(skinTag, flags)
	skinTag.flags = flags
end

function ZVox.GetContentsFromSkinTag(skinTag)
	return skinTag.data
end
function ZVox.SetSkinTagContents(skinTag, data)
	skinTag.data = data
end

function ZVox.GetCapeFromSkinTag(skinTag)
	return skinTag.cape
end
function ZVox.SetSkinTagCape(skinTag, cape)
	skinTag.cape = cape
end

function ZVox.IsSkinTagSlim(skinTag)
	return bit.band(ZVox.GetFlagsFromSkinTag(skinTag), ZVOX_SKINTAG_FLAG_SLIM) == 1
end


function ZVox.FB_WriteSkinTag(fBuff, skinTag)
	ZVox.FB_Write(fBuff, "STAG") -- magic

	ZVox.FB_WriteByte(fBuff, skinTag.type)
	ZVox.FB_WriteULong(fBuff, skinTag.flags)

	local data = skinTag.data
	ZVox.FB_WriteUShort(fBuff, #data)
	ZVox.FB_Write(fBuff, data)

	local cape = skinTag.cape
	ZVox.FB_WriteUShort(fBuff, #cape)
	ZVox.FB_Write(fBuff, cape)
end

local prefab_tag = ZVox.ComposeSkinTag(ZVOX_SKINTAG_TYPE_PREFAB, 0x0, "prefab1")
function ZVox.FB_ReadSkinTag(fBuff)
	if ZVox.FB_Read(fBuff, 4) ~= "STAG" then
		return prefab_tag
	end

	local tagType = ZVox.FB_ReadByte(fBuff)
	local tagFlags = ZVox.FB_ReadULong(fBuff)

	local dataLen = ZVox.FB_ReadUShort(fBuff)
	local data = ZVox.FB_Read(fBuff, dataLen)

	local capeLen = ZVox.FB_ReadUShort(fBuff)
	local cape = ZVox.FB_Read(fBuff, capeLen)

	return ZVox.ComposeSkinTag(tagType, tagFlags, data, cape)
end



-- good enough
local char_lut = {}
local char_lut_inv = {}
local lutSz = 0
for i = 33, 126 do
	local char = string.char(i)
	local idx = #char_lut + 1

	char_lut[idx] = char
	char_lut_inv[char] = idx

	lutSz = lutSz + 1
end
char_lut[0] = " "
char_lut_inv[" "] = 0

local _concatOut = {}
local function serializeFlags(flags)
	_concatOut[1] = char_lut[math.floor(flags % lutSz)]
	local d1 = math.floor(flags / lutSz)
	_concatOut[2] = char_lut[math.floor(d1 % lutSz)]
	local d2 = math.floor(d1 / lutSz)
	_concatOut[3] = char_lut[math.floor(d2 % lutSz)]
	local d3 = math.floor(d2 / lutSz)
	_concatOut[4] = char_lut[math.floor(d3 % lutSz)]

	return table.concat(_concatOut, "")
end

local function deSerializeFlags(serialFlags)
	local out1 = char_lut_inv[serialFlags[1]]
	local out2 = char_lut_inv[serialFlags[2]] * lutSz
	local out3 = char_lut_inv[serialFlags[3]] * lutSz * lutSz
	local out4 = char_lut_inv[serialFlags[4]] * lutSz * lutSz * lutSz

	return out1 + out2 + out3 + out4
end

local skintag_type_lut = {
	[ZVOX_SKINTAG_TYPE_PREFAB] = "PFAB",
	[ZVOX_SKINTAG_TYPE_SKIN] = "SKIN",
	[ZVOX_SKINTAG_TYPE_CLIENTSKIN] = "CLSK",
}
local _concat = {}
function ZVox.SerializeSkinTag(tag)
	_concat[1] = skintag_type_lut[tag.type]

	-- TODO: Reimplement when we have more flags
	local flags = tag.flags
	_concat[2] = serializeFlags(flags)

	_concat[3] = tag.data

	return table.concat(_concat, ":")
end



local skintag_type_lut_inv = {
	["PFAB"] = ZVOX_SKINTAG_TYPE_PREFAB,
	["SKIN"] = ZVOX_SKINTAG_TYPE_SKIN,
	["CLSK"] = ZVOX_SKINTAG_TYPE_CLIENTSKIN
}

function ZVox.DeSerializeSkinTag(serialTag)
	if not serialTag then
		return prefab_tag
	end

	local tagType = skintag_type_lut_inv[string.sub(serialTag, 1, 4)]
	if not tagType then
		return prefab_tag
	end

	-- TODO: Reimplement when we have more flags
	local tagFlags = deSerializeFlags(string.sub(serialTag, 6, 9))
	local tagData = string.sub(serialTag, 11, #serialTag)

	return ZVox.ComposeSkinTag(tagType, tagFlags, tagData)
end