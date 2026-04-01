ZVox = ZVox or {}

local _READ_ADDR = 0

local function read_uint8_t(data)
	_READ_ADDR = _READ_ADDR + 1

	return string.byte(data, _READ_ADDR, _READ_ADDR)
end

-- TODO: optimize
local function read_uint32_t(data)
	local b1 = read_uint8_t(data)
	local b2 = read_uint8_t(data)
	local b3 = read_uint8_t(data)
	local b4 = read_uint8_t(data)

	return bit.lshift(b1, 24) + bit.lshift(b2, 16) + bit.lshift(b3, 8) + b4
end

local _concat = {}
local function read_chunk_name(data)
	_concat[1] = string.char(read_uint8_t(data))
	_concat[2] = string.char(read_uint8_t(data))
	_concat[3] = string.char(read_uint8_t(data))
	_concat[4] = string.char(read_uint8_t(data))

	return table.concat(_concat, "")
end


local magics = {
	137,
	80,
	78,
	71,
	13,
	10,
	26,
	10,
}


function ZVox.ParsePNGHeader(pngData)
	_READ_ADDR = 0

	for i = 1, 8 do
		local c = read_uint8_t(pngData)
		if magics[i] ~= c then
			ZVox.PrintError("PNGDec: Magic doesn't match!")
			return
		end
	end

	local len = read_uint32_t(pngData)
	local name = read_chunk_name(pngData)
	if name ~= "IHDR" then
		ZVox.PrintError("PNGDec: malformed PNG")
		return
	end

	-- parse the header now
	local width = read_uint32_t(pngData)
	local height = read_uint32_t(pngData)
	local bitDepth = read_uint8_t(pngData)
	local colorType = read_uint8_t(pngData)
	local compressionMethod = read_uint8_t(pngData)
	local filterMethod = read_uint8_t(pngData)
	local interlaceMethod = read_uint8_t(pngData)

	local head = {
		["width"] = width,
		["height"] = height,
		["bitDepth"] = bitDepth,
		["colorType"] = colorType,
		["compressionMethod"] = compressionMethod,
		["filterMethod"] = filterMethod,
		["interlaceMethod"] = interlaceMethod,
	}

	return head
end


-- enums
COLORTYPE_GRAYSCALE = 0x0
COLORTYPE_RGBTRIPLE = 0x2
COLORTYPE_PALETTE = 0x3
COLORTYPE_GRAYSCALEALPHA = 0x4
COLORTYPE_RGBA = 0x6 -- we only want to allow this one


local allowed_size_ratios = {
	["64x32"] = true,
	["64x64"] = true,
}

local allowed_colortypes = {
	[COLORTYPE_PALETTE] = true,
	[COLORTYPE_RGBA] = true,
}

local MAX_ALLOWED_SIZE = 1024 * 18 -- 18KiB

function ZVox.IsPNGSkinLegal(pngData)
	local head = ZVox.ParsePNGHeader(pngData)

	if not head then
		return false
	end

	if not allowed_colortypes[head.colorType] then
		return false
	end

	local sizeHash = head.width .. "x" .. head.height
	if not allowed_size_ratios[sizeHash] then
		return false
	end

	local fileSize = #pngData
	if fileSize > MAX_ALLOWED_SIZE then
		return false
	end

	return true
end

function ZVox.GetPNGName(pngData)
	return util.MD5(pngData)
end


-- TODO: ZVox.CleanUpPNG(pngData) func
-- to get rid of unneeded blocks and only leave the header and imagedata