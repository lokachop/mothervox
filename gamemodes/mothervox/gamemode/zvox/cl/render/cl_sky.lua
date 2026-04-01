ZVox = ZVox or {}

local _skyRT = GetRenderTarget("zvox_sky_rt", 256, 256)
local _skyMat = CreateMaterial("zvox_sky_mat", "UnlitGeneric", {
	["$basetexture"] = _skyRT:GetName(),
	["$vertexcolor"] = 1,
})

local _fadeItr = 256

-- Recomputes the sky texture to match the sky of that universe
function ZVox.RecomputeSkyTexture(univ)
	ZVox.PrintInfo("Recomputing Sky Texture...")
	local cols = ZVox.GetUniverseSkyGradient(univ)

	ZVox.RenderOnRT(_skyRT, function()
		local sqrSize = 256 / _fadeItr

		for i = 0, _fadeItr do
			local delta = i / _fadeItr
			local r, g, b = ZVox.GetColorAtGradientPoint(delta, cols)

			surface.SetDrawColor(r, g, b)
			surface.DrawRect(0, (256 - i) * sqrSize, 256, sqrSize)
		end
	end)
end


local matrixCenter = Matrix()
matrixCenter:Identity()

local SKY_SIZE_SCL = Vector(8, 8, 8)
local SKY_DO_DEBUG_FIXEDTRANSLATE = false


local meshSky = ZVox.GetSphereMesh(24, 24, true)
local function renderSkySphere(univObj, timeDelta)
	matrixCenter:Identity()
	matrixCenter:SetTranslation(ZVox.GetCamPos()) -- so it is always on the center of view
	matrixCenter:Scale(SKY_SIZE_SCL)

	if SKY_DO_DEBUG_FIXEDTRANSLATE then
		matrixCenter:SetTranslation(Vector(48.5, 64.5, 64))
	end

	cam.PushModelMatrix(matrixCenter)
		if not ZVOX_DO_WIREFRAME then
			render.SetMaterial(_skyMat)
		end
		meshSky:Draw()
	cam.PopModelMatrix()
end




local _sunRT = GetRenderTargetEx("zvox_sun_rt", 32, 32, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 1, 4, IMAGE_FORMAT_RGBA8888)
local _sunMat = CreateMaterial("zvox_sun_mat", "UnlitGeneric", {
	["$basetexture"] = _sunRT:GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
})
ZVox.PixelFuncOnRT(_sunRT, function(x, y)
	local xD = x / 32
	local yD = y / 32

	local l1 = math.abs(xD - .5) * 2
	local l2 = math.abs(yD - .5) * 2

	l1 = l1 ^ .85
	l2 = l2 ^ .85

	local dist = math.max((l1 + l2), 0)


	--local dist = math.Distance(xD, yD, .5, .5)
	--dist = dist * 2

	dist = 1 - dist
	return 255, math.min(64 + dist * 300, 255), dist * 64, math.max(dist * 196, 0)
end)

local meshSun = ZVox.GetPlaneMeshMulti({
	{
		["pos"] = Vector(-.125, -.125, 0),
		["scl"] = Vector(.25, .25, .25),
		["rot"] = Angle(0, 0, 90),
		["uv"] = {0, 0, 1, 1},
		["uvScale"] = 1,
	},
})

local meshSun2 = ZVox.GetPlaneMeshMulti({
	{
		["pos"] = Vector(-.125, -.125, 0),
		["scl"] = Vector(.25, .25, .25),
		["rot"] = Angle(45, 0, 90),
		["uv"] = {0, 0, 1, 1},
		["uvScale"] = 1,
	},
})
local function renderSun(univObj, timeDelta)
	if not ZVox.GetUniverseRenderSun(univObj) then
		return
	end

	local pow = .9

	matrixCenter:Identity()
	matrixCenter:SetTranslation(ZVox.GetCamPos())
	matrixCenter:Scale(SKY_SIZE_SCL)

	if SKY_DO_DEBUG_FIXEDTRANSLATE then
		matrixCenter:SetTranslation(Vector(48.5, 64.5, 64))
	end

	matrixCenter:Rotate(Angle(-15, 0, timeDelta * 360))
	matrixCenter:Translate(Vector(0, -pow, 0))
	matrixCenter:Rotate(Angle(CurTime() * 1, 0, 0))

	cam.PushModelMatrix(matrixCenter)
		if not ZVOX_DO_WIREFRAME then
			render.SetMaterial(_sunMat)
		end
		meshSun:Draw()
		meshSun2:Draw()
	cam.PopModelMatrix()

end



local _starRT = GetRenderTargetEx("zvox_star2_rt", 16, 16, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 1, 4, IMAGE_FORMAT_RGBA8888)
local _starMat = CreateMaterial("zvox_star2_mat", "UnlitGeneric", {
	["$basetexture"] = _starRT:GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
})
ZVox.PixelFuncOnRT(_starRT, function(x, y)
	--local xD = x / 16
	--local yD = y / 16

	--local dist = math.Distance(xD, yD, .5, .5)
	--dist = dist * 1.75

	--dist = 1 - dist
	--return 255, 255, 255, math.max(dist * 255, 0)



	local xD = x / 16
	local yD = y / 16

	local l1 = math.abs(xD - .5) * 2
	local l2 = math.abs(yD - .5) * 2

	l1 = l1 ^ .55
	l2 = l2 ^ .55

	local dist = math.max((l1 + l2), 0)


	--local dist = math.Distance(xD, yD, .5, .5)
	--dist = dist * 2

	dist = 1 - dist
	dist = math.min(math.max(dist, 0), 1)

	return 255 * dist, 255 * dist, 255 * dist, 255
end)
local meshStars = ZVox.GetStarMesh(.95 * 8)
local vecStarCol = Vector(1, 1, 1)
local function renderStars(univObj, timeDelta)
	local sunDelta = 1 - ZVox.GetUniverseSunDelta(univObj)
	vecStarCol:SetUnpacked(sunDelta, sunDelta, sunDelta)

	_starMat:SetVector("$color", vecStarCol)

	matrixCenter:Identity()
	matrixCenter:SetTranslation(ZVox.GetCamPos())
	matrixCenter:Rotate(Angle(-15, 0, timeDelta * 360))

	if SKY_DO_DEBUG_FIXEDTRANSLATE then
		matrixCenter:SetTranslation(Vector(48.5, 64.5, 64))
	end

	cam.PushModelMatrix(matrixCenter)
		render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD)
			if not ZVOX_DO_WIREFRAME then
				render.SetMaterial(_starMat)
			end
			meshStars:Draw()
		render.OverrideBlend(false)
	cam.PopModelMatrix()
end


local _moonRT = GetRenderTargetEx("zvox_moon_rt", 16, 16, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 1, 4, IMAGE_FORMAT_RGBA8888)
local _moonMat = CreateMaterial("zvox_moon_mat", "UnlitGeneric", {
	["$basetexture"] = _moonRT:GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
})
ZVox.PixelFuncOnRT(_moonRT, function(x, y)
	local val = .6 + (math.random() * .2)

	local xD = (x + 1) / 16
	local yD = (y + 1) / 16

	local dist = math.Distance(xD, yD, .5, .5)
	dist = dist * 2.1

	local valRGB = val * 128
	dist = 1 - dist

	local distMul = math.max(math.min(dist, 1), 0)


	return valRGB, valRGB, valRGB, math.min(distMul * 1024, 255)
end)

local meshMoon = ZVox.GetPlaneMeshMulti({
	{
		["pos"] = Vector(-.125, -.125, 0),
		["scl"] = Vector(.25, .25, .25),
		["rot"] = Angle(0, 0, -90),
		["uv"] = {0, 0, 1, 1},
		["uvScale"] = 1,
	},
})

local moonRotAngPost = Angle(-90, 0, 0)
local function renderMoon(univObj, timeDelta)
	if not ZVox.GetUniverseRenderMoon(univObj) then
		return
	end


	local pow = .9

	matrixCenter:Identity()
	matrixCenter:SetTranslation(ZVox.GetCamPos())
	matrixCenter:Scale(SKY_SIZE_SCL)

	if SKY_DO_DEBUG_FIXEDTRANSLATE then
		matrixCenter:SetTranslation(Vector(48.5, 64.5, 64))
	end

	matrixCenter:Rotate(Angle(-15, 0, timeDelta * 360))
	matrixCenter:Translate(Vector(0, pow, 0))
	matrixCenter:Rotate(moonRotAngPost)
	cam.PushModelMatrix(matrixCenter)
		if not ZVOX_DO_WIREFRAME then
			render.SetMaterial(_moonMat)
		end
		meshMoon:Draw()
	cam.PopModelMatrix()
end



local meshClouds = ZVox.GetPlaneMeshOp(32, 32, true, Vector(4, 4, 4), -Vector(2, 2, -.2),
function(pos, norm, scale) -- COL
	local normPos = (pos / scale)
	normPos:Add(Vector(1, 1, 1))
	normPos:Div(2)

	local dist2D = math.Distance(normPos[1], normPos[2], .5, .5)
	dist2D = math.pow(dist2D, 2) * 24
	dist2D = dist2D ^ 2
	dist2D = math.min(dist2D, 1)


	return 255, 255, 255, (1 - dist2D) * 255
end, function(pos, norm, scale) -- UV
	local normPos = pos / scale

	local u = normPos[1] * 3
	local v = normPos[2] * 3

	return u, v
end)

-- use GetRenderTargetEx here since we need to make it transparent
local cloudMats = {}
local cloudItr = 8
local cloudSeparation = .08 / cloudItr
for i = 1, cloudItr do
	local cloudRT = GetRenderTargetEx("zvox_cloud_rt_itr_" .. i, 64, 64, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 1, 4, IMAGE_FORMAT_RGBA8888)

	cloudMats[i] = CreateMaterial("zvox_cloud_mat_itr_" .. i, "UnlitGeneric", {
		["$basetexture"] = cloudRT:GetName(),
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
	})

	local iDelta = i / cloudItr

	iDelta = 1 - math.abs((iDelta - .5) * 2)



	local _percClear = Lerp(iDelta, .6, .3)
	ZVox.PixelFuncOnRT(cloudRT, function(x, y)
		local dx = x / 64
		local dy = y / 64

		local coordMulX = 6.5
		local coordMulY = 5.2341
		local offX = 0
		local offY = .3


		local finalX = (dx * coordMulX) + offX
		local finalY = (dy * coordMulY) + offY

		local rectSzX = (64 / 64) * coordMulX
		local rectSzY = (64 / 64) * coordMulY

		--local val = ZVox.Simplex2D(finalX, finalY)
		local val = ZVox.TileableNoise(ZVox.Simplex2D, finalX, finalY, rectSzX, rectSzY)
		val = (val + 1) * .5
		val = val * 255


		val = math.max(val - (255 * _percClear), 0)
		val = val + (1 / _percClear)


		local alphaVal = math.min(val * (3 / cloudItr), 255)
		local darkenVal = 255 - math.min(val * (2 / cloudItr), 255)
		darkenVal = darkenVal * 0.5

		return darkenVal, darkenVal, darkenVal, alphaVal
	end)
end

local matrixCloudTransform = Matrix()
matrixCloudTransform:Identity()
local function renderClouds(univObj, timeDelta)
	if not ZVox.GetUniverseRenderClouds(univObj) then
		return
	end



	local camPos = ZVox.GetCamPos()
	local camUp = (camPos[3] - 1036) * .004

	matrixCenter:Identity()
	matrixCenter:SetTranslation(camPos) -- so it is always on the center of view
	matrixCenter:Scale(SKY_SIZE_SCL)

	if SKY_DO_DEBUG_FIXEDTRANSLATE then
		matrixCenter:SetTranslation(Vector(48.5, 64.5, 64))
	end

	matrixCenter:Translate(Vector(0, 0, -camUp))

	local globalTranslateMul = .25
	local timeTransform = CurTime() * .05 * globalTranslateMul
	matrixCloudTransform:SetTranslation(Vector((camPos[1] * .01 * globalTranslateMul) + timeTransform, (camPos[2] * .01 * globalTranslateMul) + (timeTransform * .25), 0))


	if ZVOX_DO_SMOOTH_CLOUDS then
		render.PushFilterMag(TEXFILTER.LINEAR)
		render.PushFilterMin(TEXFILTER.LINEAR)
	end
	for i = 1, cloudItr do
		local mat = cloudMats[i]
		if not mat then
			return
		end
		mat:SetMatrix("$basetexturetransform", matrixCloudTransform)
		if not ZVOX_DO_WIREFRAME then
			render.SetMaterial(mat)
		end

		matrixCenter:Translate(Vector(0, 0, cloudSeparation))
		cam.PushModelMatrix(matrixCenter)
			meshClouds:Draw()
		cam.PopModelMatrix()
	end
	if ZVOX_DO_SMOOTH_CLOUDS then
		render.PopFilterMin()
		render.PopFilterMag()
	end
end

local lastUnivName = "NONE_THIS_DONT_EXIST"
local vec_white = Vector(1, 1, 1)
local wfMat = Material("editor/wireframe")
function ZVox.RenderSky(univObj)
	if ZVOX_DO_WIREFRAME then
		render.SetMaterial(wfMat)
	end

	-- update sky tint to the day and night colour
	local skyTint = ZVox.GetUniverseTrueSkyTint(univObj) or vec_white
	_skyMat:SetVector("$color", skyTint)
	for i = 1, cloudItr do
		local mat = cloudMats[i]
		mat:SetVector("$color", skyTint)
	end

	local time = ZVox.GetUniverseTrueTime(univObj)
	local timeDelta = -(time / 86400)

	-- sun
	renderSun(univObj, timeDelta)

	-- moon
	renderMoon(univObj, timeDelta)

	-- clouds
	ZVox.ClearRTDepth()
	renderClouds(univObj, timeDelta)

	ZVox.ClearRTDepth() -- so everything else can draw over it, as the mesh is meant to be the background
end

function ZVox.RenderPostClouds(univObj)
	local time = ZVox.GetUniverseTrueTime(univObj)
	local timeDelta = -(time / 86400)

	render.CullMode(MATERIAL_CULLMODE_CW)
	renderClouds(univObj, timeDelta)
	render.CullMode(MATERIAL_CULLMODE_CCW)
end