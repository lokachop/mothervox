ZVox = ZVox or {}
local texRegistry = ZVox.GetTextureRegistry()
local c_white = Color(255, 255, 255)

ZVOX_RENDERING_ANIMATED_TEXTURE = false
ZVOX_RENDERING_ANIMATED_TEXTURE_RT = 0
ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME = 0

-- creates an animated textures
-- but how do they work?
-- they get stored as 16 * frames x 16 texture slices
-- and each redraw, it draws the next frame on the atlas
-- now to make pixelfuncs work with this we have a global that gets set which instructs RenderOnRT to offset it correctly
-- i'm splitting renderOnRT to a specialized texturefun one though
local _lastAnimID = 0
local animIDToTextureNameLUT = {}
local animTextureRegistry = {}
function ZVox.NewTextureAnimated(name, params, func)
	local regEntry = animTextureRegistry[ZVox.NAMESPACES_NamespaceConvert(name)]
	if regEntry then
		func(name, 0, 0)

		local frames = params.frames or 16
		local speed = params.speed or 0.1

		local rt = GetRenderTarget("zvox_animtex_rt_" .. ZVox.NAMESPACES_NamespaceConvert(name) .. "_frames_" .. frames, 16 * frames, 16)
		local mat = CreateMaterial("zvox_animtex_mat_" .. ZVox.NAMESPACES_NamespaceConvert(name) .. "_frames_" .. frames, "UnlitGeneric", {
			["$basetexture"] = rt:GetName(),
			["$nocull"] = 1,
			["$ignorez"] = 1,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1,
		})

		ZVOX_RENDERING_ANIMATED_TEXTURE = true
		ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME = 0
		ZVOX_RENDERING_ANIMATED_TEXTURE_RT = rt

		-- now lets render
		for i = 0, frames - 1 do
			ZVox.FlushConsistentRandom()

			ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME = i
			local delta = i / frames

			func(name, delta, i)
		end

		ZVOX_RENDERING_ANIMATED_TEXTURE = false
		ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME = 0

		regEntry.renderRT = rt
		regEntry.renderMat = mat
		regEntry.frames = frames
		regEntry.speed = speed
		return
	end


	_lastAnimID = _lastAnimID + 1
	animIDToTextureNameLUT[_lastAnimID] = ZVox.NAMESPACES_NamespaceConvert(name)

	ZVox.NewTexture(name, function()
		render.Clear(0, 0, 0, params.transp or 255)
	end)

	func(name, 0, 0)

	--name = ZVox.NAMESPACES_NamespaceConvert(name)

	local frames = params.frames or 16
	local speed = params.speed or 0.1
	-- TODO: non precomputed animated textures (ex. "movie" texture that's your screen)


	local rt = GetRenderTarget("zvox_animtex_rt_" .. ZVox.NAMESPACES_NamespaceConvert(name) .. "_frames_" .. frames, 16 * frames, 16)

	ZVox.RenderOnRT(rt, function()
		render.Clear(0, 0, 0, params.transp or 255)
	end)

	local mat = CreateMaterial("zvox_animtex_mat_" .. ZVox.NAMESPACES_NamespaceConvert(name) .. "_frames_" .. frames, "UnlitGeneric", {
		["$basetexture"] = rt:GetName(),
		["$nocull"] = 1,
		["$ignorez"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
	})

	animTextureRegistry[ZVox.NAMESPACES_NamespaceConvert(name)] = {
		["name"] = ZVox.NAMESPACES_NamespaceConvert(name),
		["frames"] = frames,
		["speed"] = speed,
		["renderRT"] = rt,
		["renderMat"] = mat,
		["currentFrame"] = 0,
	}

	ZVOX_RENDERING_ANIMATED_TEXTURE = true
	ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME = 0
	ZVOX_RENDERING_ANIMATED_TEXTURE_RT = rt

	-- now lets render
	for i = 0, frames - 1 do
		ZVox.FlushConsistentRandom()

		ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME = i
		local delta = i / frames

		func(name, delta, i)
	end

	ZVOX_RENDERING_ANIMATED_TEXTURE = false
	ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME = 0
end


function ZVox.IsTextureAnimated(name)
	return animTextureRegistry[name] ~= nil
end

function ZVox.GetAnimatedTextureEntry(name)
	return animTextureRegistry[name]
end


local function updateAnimTex(animReg, texReg)
	local animSpeed = animReg["speed"]
	local animFrames = animReg["frames"]

	if not animReg["nextRedraw"] then
		animReg["nextRedraw"] = 0
	end

	local frameIdx = ((CurTime() / animSpeed) % animFrames)
	frameIdx = math.floor(frameIdx)

	if animReg["currentFrame"] == frameIdx then
		return
	end

	animReg["currentFrame"] = frameIdx
	local currFrame = animReg["currentFrame"]

	local atlasRT = ZVox.GetTextureAtlasRT()

	-- let's redraw
	local matAnim = animReg["renderMat"]
	local coordAtlasTex = texReg["coord"]

	local cX = coordAtlasTex[1]
	local cY = coordAtlasTex[2]

	local frameSz = (1 / animFrames)

	ZVox.RenderOnRT_SubRect(atlasRT, cX, cY, 16, 16, function() -- TODO: unhardcode from 16x16 texutres
		if system.IsLinux() then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(matAnim)

			local frameDelta = currFrame / animFrames
			local frameDeltaAdd = (frameDelta + frameSz)

			--surface.DrawRect(cX, cY, 16, 16)
			surface.DrawTexturedRectUV(0, 0, 16, 16, frameDelta, 0, frameDeltaAdd, 1)
		else
			render.Clear(0, 0, 0, 0)

			local xC = -(16 * currFrame)
			local yC = 0
			local w = 16 * animFrames
			local h = 16


			local v1 = Vector(xC, yC, 0)
			local v2 = Vector(xC + w, yC, 0)
			local v3 = Vector(xC + w, yC + h, 0)
			local v4 = Vector(xC, yC + h, 0)

			render.SetMaterial(matAnim)
			render.DrawQuad(v1, v2, v3, v4, c_white)
		end
	end)

	-- also update the standalone tex
	ZVox.RenderOnRT(texReg.rt, function()
		if system.IsLinux() then
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(matAnim)

			local frameDelta = currFrame / animFrames
			local frameDeltaAdd = (frameDelta + frameSz)

			surface.DrawTexturedRectUV(0, 0, 16, 16, frameDelta, 0, frameDeltaAdd, 1)
		else
			render.Clear(0, 0, 0, 0)

			local xC = -(16 * currFrame)
			local yC = 0
			local w = 16 * animFrames
			local h = 16


			local v1 = Vector(xC, yC, 0)
			local v2 = Vector(xC + w, yC, 0)
			local v3 = Vector(xC + w, yC + h, 0)
			local v4 = Vector(xC, yC + h, 0)

			render.SetMaterial(matAnim)
			render.DrawQuad(v1, v2, v3, v4, c_white)
		end
	end)
end


-- updates animated textures on the atlas
function ZVox.UpdateAnimatedTextures()
	if not ZVOX_DO_ANIMATED_TEXTURES then
		return
	end


	for i = 1, _lastAnimID do
		local name = animIDToTextureNameLUT[i]

		local animReg = animTextureRegistry[name]
		if not animReg then
			continue
		end

		local texReg = ZVox.GetTextureByName(name)
		if not texReg then
			continue
		end

		updateAnimTex(animReg, texReg)
	end
end