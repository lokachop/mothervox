ZVox = ZVox or {}

local math = math
local math_floor = math.floor

-- 512 x 512 atlas
-- 16 x 16 textures
-- =
-- 1024 diff textures max on atlas
local ATLAS_SIZE = 512
local ATLAS_AXIS_SIZE = ATLAS_SIZE / 16
local MAX_TEXTURES = ATLAS_SIZE * ATLAS_SIZE / (16 * 16)


local _textures = {}
local _texIDtoNameLUT = {}
function ZVox.GetTextureRegistry()
	return _textures
end

function ZVox.GetTextureIDToNameLUT()
	return _texIDtoNameLUT
end

function ZVox.GetTextureByName(name)
	return _textures[name]
end

local _lastTexID = 0
function ZVox.NewTexture(name, func)
	if not name then
		return
	end

	name = ZVox.NAMESPACES_NamespaceConvert(name)

	if _textures[name] then
		ZVox.RenderOnRT_TextureSpecialized(_textures[name].rt, func)
		return
	end


	if _lastTexID > MAX_TEXTURES then
		error("[ZVox] too many textures (" .. tostring(_lastTexID) .. "> " .. MAX_TEXTURES .. ")")
	end

	local rt = GetRenderTargetEx("zvox_tex_rt_" .. name, 16, 16,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(256),
	0,
	IMAGE_FORMAT_BGRA8888
	)
	local mat = CreateMaterial("zvox_tex_mat_" .. name, "UnlitGeneric", {
		["$basetexture"] = rt:GetName(),
		["$nocull"] = 1,
		["$ignorez"] = 1, -- These will only be drawn to the atlas / ui, so we don't need Z sorting which causes trouble
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
	})

	local mat_z = CreateMaterial("zvox_tex_mat_z_" .. name, "UnlitGeneric", {
		["$basetexture"] = rt:GetName(),
		["$nocull"] = 0,
		["$ignorez"] = 0, -- We need z for these for the particles
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
	})

	ZVox.RenderOnRT_TextureSpecialized(rt, func) -- this draws to the rt

	_textures[name] = {
		["rt"] = rt,
		["mat"] = mat,
		["mat_z"] = mat_z,
		["idx"] = _lastTexID,
		["uv"] = {0, 0},
		["coord"] = {0, 0},
	}
	_texIDtoNameLUT[_lastTexID] = name

	_lastTexID = _lastTexID + 1
end

function ZVox.GetTextureCount()
	return _lastTexID - 1
end

local _texEmissiveRegistry = {}
function ZVox.GetTexEmissiveRegistry()
	return _texEmissiveRegistry
end

function ZVox.SetTextureEmissive(name, emissive)
	if not _textures[ZVox.NAMESPACES_NamespaceConvert(name)] then
		return
	end

	_texEmissiveRegistry[ZVox.NAMESPACES_NamespaceConvert(name)] = emissive
end

function ZVox.GetTextureEmissive(name)
	return _texEmissiveRegistry[name] or false
end


-- Helper funcs

-- Per-pixel texture value
function ZVox.NewTexturePixelFunc(name, pixelFunc)
	if not name then
		return
	end

	ZVox.NewTexture(name, function()
		render.Clear(0, 0, 0, 0)

		local oW, oH = ScrW(), ScrH()
		for i = 0, (16 * 16) -1 do
			local xc = i % 16
			local yc = math_floor(i / 16)

			local fine, r, g, b, alpha = pcall(pixelFunc, xc, yc) -- if this errors, we're cooked, catch errors
			if not fine then
				continue
			end

			render.SetViewPort(xc, yc, 1, 1)
			render.Clear(r, g, b, alpha or 255) -- port to mesh.Begin POINTS method
			-- sadly mesh.Begin with MATERIAL_POINTS seems to turn the RT black?
			-- strange and weird and it means that i sadly can't use it
		end
		render.SetViewPort(0, 0, oW, oH)
	end)
end

-- Applies an operation to a texture
function ZVox.TextureOp(name, func)
	if not name then
		return
	end

	name = ZVox.NAMESPACES_NamespaceConvert(name)

	local tex = _textures[name]
	if not tex then
		return
	end

	ZVox.RenderOnRT_TextureSpecialized(tex.rt, func)
end

function ZVox.TextureOpPixelFunc(name, func)
	ZVox.TextureOp(name, function()
		--local oW, oH = ScrW(), ScrH()


		for i = 0, (16 * 16) -1 do
			local xc = i % 16
			local yc = math_floor(i / 16)

			local fine, r, g, b, alpha = pcall(func, xc, yc) -- if this errors, we're cooked, catch errors
			if not fine then
				continue
			end

			if not r then
				continue
			end
			alpha = alpha or 255

			--if system.IsLinux() then
				--render.SetViewPort(xc, yc, 1, 1)
				--render.Clear(r, g, b, alpha)
			--else
				surface.SetDrawColor(r, g, b, alpha)
				surface.DrawRect(xc, yc, 1, 1)
			--end
		end

		--render.SetViewPort(0, 0, oW, oH)
	end)
end

function ZVox.TextureHexWriteOp(name, hex, r, g, b)
	r = r or 0
	g = g or 0
	b = b or 0

	local oX = 0
	if ZVOX_RENDERING_ANIMATED_TEXTURE then
		oX = ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME * 16 -- TODO unhardcode when hires textures
	end

	ZVox.TextureOp(name, function()
		local oW, oH = ScrW(), ScrH()
		for i = 0, (16 * 16) - 1 do
			local xc = i % 16
			local yc = math.floor(i / 16)
			local row = hex[yc + 1]
			if not row then
				continue
			end


			local xcBand = 15 - xc

			local bitGet = bit.band(row, 2^xcBand)

			if bitGet == 0 then
				continue
			end

			render.SetViewPort(xc + oX, yc, 1, 1)
			render.Clear(r, g, b, 255)
		end
		render.SetViewPort(0, 0, oW, oH)
	end)
end

function ZVox.TextureHexWriteMultiOp(name, data)
	for i = 1, #data do
		local entry = data[i]
		local col = entry[1]
		local hexData = entry[2]


		ZVox.TextureHexWriteOp(name, hexData, col.r, col.g, col.b)
	end
end

function ZVox.TextureHexMaskOp(name, hex, func)
	ZVox.TextureOp(name, function()
		local oW, oH = ScrW(), ScrH()
		for i = 0, (16 * 16) - 1 do
			local xc = i % 16
			local yc = math.floor(i / 16)
			local row = hex[yc + 1]
			if not row then
				continue
			end


			local xcBand = 15 - xc

			local bitGet = bit.band(row, 2^xcBand)

			if bitGet == 0 then
				continue
			end

			local fine, r, g, b, alpha = pcall(func, xc, yc) -- if this errors, we're cooked, catch errors
			if not fine then
				continue
			end

			if not r then
				continue
			end

			--render.SetViewPort(xc, yc, 1, 1)
			--render.Clear(r, g, b, alpha)

			surface.SetDrawColor(r, g, b, alpha)
			surface.DrawRect(xc, yc, 1, 1)
		end
		render.SetViewPort(0, 0, oW, oH)
	end)
end


function ZVox.BevelOp(name, r, g, b, a)
	ZVox.TextureOp(name, function()
		surface.SetDrawColor(r, g, b, a or 255)
		surface.DrawRect(0, 0, 1, 16)
		surface.DrawRect(0, 0, 16, 1)

		surface.DrawRect(15, 0, 1, 16)
		surface.DrawRect(0, 15, 16, 1)
	end)
end


function ZVox.BevelPixelFuncOp(name, func)
	ZVox.TextureOpPixelFunc(name, function(x, y)
		if not ((x == 0 or x == 15) or (y == 0 or y == 15)) then
			return
		end

		local fine, r, g, b, alpha = pcall(func, x, y) -- if this errors, we're cooked, catch errors
		if not fine then
			return
		end

		if not r then
			return
		end

		return r, g, b, alpha
	end)
end

local _texAtlasRT = GetRenderTargetEx("zvox_texatlas_rt", ATLAS_SIZE, ATLAS_SIZE,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_SEPARATE,
	bit.bor(256),
	0,
	IMAGE_FORMAT_BGRA8888
)
local _texAtlasMat = CreateMaterial("zvox_texatlas_mat", "UnlitGeneric", {
	["$basetexture"] = _texAtlasRT:GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
})
function ZVox.GetTextureAtlasRT()
	return _texAtlasRT
end

function ZVox.GetTextureAtlasMat()
	return _texAtlasMat
end

local _texAtlasMatAlphaTest = CreateMaterial("zvox_texatlas_mat_alphatest", "UnlitGeneric", {
	["$basetexture"] = _texAtlasRT:GetName(),
	["$vertexcolor"] = 1,
	["$alphatest"] = 1,
})

function ZVox.GetTextureAtlasMatAlphaTest()
	return _texAtlasMatAlphaTest
end

local bSize = 16 / ATLAS_SIZE
function ZVox.GetTextureAtlasBlockSize()
	return bSize, bSize
end

function ZVox.GetTextureAtlasSize()
	return ATLAS_SIZE
end

function ZVox.SetTextureAtlasTint(vec)
	_texAtlasMat:SetVector("$color", vec)
	_texAtlasMatAlphaTest:SetVector("$color", vec)
end


function ZVox.RecomputeTextureAtlas()
	-- go thru all of the textures and place them in the atlas according to their index
	-- each axis of the atlas is 16 textures
	ZVox.RenderOnRT(_texAtlasRT, function()
		render.Clear(0, 0, 0, 0)

		for i = 0, (_lastTexID - 1) do
			local texName = _texIDtoNameLUT[i]
			local texture = _textures[texName]
			local mat = texture.mat

			local xc = (i % ATLAS_AXIS_SIZE) * 16
			local yc = math_floor(i / ATLAS_AXIS_SIZE) * 16

			_textures[texName].uv = {xc / ATLAS_SIZE, yc / ATLAS_SIZE}
			_textures[texName].coord = {xc, yc}

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(xc, yc, 16, 16)
		end
	end)

	ZVox.PrintInfo("Done recomputing texture atlas!")
	ZVox.PrintInfo("| " .. tostring(_lastTexID - 1) .. "/" .. MAX_TEXTURES .. " textures allocated...")
end

function ZVox.GetMaxTextureCount()
	return MAX_TEXTURES
end

ZVox.NewTexturePixelFunc("error", function(x, y)
	local checkCase1 = (x < 8 and y < 8)
	local checkCase2 = (y > 7 and x > 7)
	local isCheck = checkCase1 or checkCase2

	if isCheck then
		return 255, 0, 255
	else
		return 0, 0, 0
	end
end)


file.CreateDir("zvox/debug/texture_export")
function ZVox.DebugExportAllTextures()
	ZVox.CommandErrorNotify("Textures will be exported in 4s, close the ESC menu or it will error!")


	timer.Simple(4, function()
		-- check that they have closed
		local data = render.Capture({
			format = "png",
			x = 0,
			y = 0,
			w = 1,
			h = 1,
			alpha = false
		})

		if not data then
			ZVox.CommandErrorNotify("Failed to exported, close the ESC menu next time!")
			return
		end

		local texCount = ZVox.GetTextureCount()
		local idToNameLUT = ZVox.GetTextureIDToNameLUT()

		for i = 1, texCount do
			local texName = idToNameLUT[i]

			local tex = ZVox.GetTextureByName(texName)
			local rt = tex.rt

			render.PushRenderTarget(rt)
				local realPNGData = render.Capture({
					format = "png",
					x = 0,
					y = 0,
					w = 16, -- TODO: unhardcode when hires support
					h = 16,
					alpha = true
				})
			render.PopRenderTarget()

			local fPath = "zvox/debug/texture_export/" .. texName .. ".png"
			local fPtr = file.Open(fPath, "wb", "DATA")
			if not fPtr then
				ZVox.CommandErrorNotify("Failed to save \"" .. texName .. "\"!")
				return
			end

			fPtr:Write(realPNGData)
			fPtr:Close()
		end

		ZVox.CommandErrorNotify("Exported all textures to \"zvox/debug/texture_export/\"!")
	end)
end

concommand.Add("zvox_debug_export_all_textures", function()
	ZVox.DebugExportAllTextures()
end)