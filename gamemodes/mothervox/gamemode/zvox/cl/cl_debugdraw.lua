ZVox = ZVox or {}
ZVox.DebugDraw = ZVox.DebugDraw or false

function ZVox.SetDebugDraw(bool)
	ZVox.DebugDraw = bool
end

function ZVox.GetDebugDraw()
	return ZVox.DebugDraw
end

function ZVox.ToggleDebugDraw()
	ZVox.DebugDraw = not ZVox.DebugDraw
end

ZVox.NewControlListener("cam_debug", "open_dd", function()
	if not ZVOX_DEVMODE then
		return
	end

	ZVox.ToggleDebugDraw()
	ZVox.PrintInfo("Debug Draw: " .. (ZVox.DebugDraw and "ON" or "OFF"))
end)


-- bad from deepdive
local git_branch = nil
local git_current = nil
local function reComputeGitID()
	if git_branch == nil then
		return
	end


	if file.Exists("addons/zvox/.git/refs/heads/" .. git_branch, "GAME") then
		local git_nfo = file.Read("addons/zvox/.git/refs/heads/" .. git_branch, "GAME")
		if not git_nfo then
			return
		end
		git_current = string.sub(git_nfo, 1, 7)
	end
end

local function reComputeGitBranch()
	if file.Exists("addons/zvox/.git/HEAD", "GAME") then
		local git_nfo = file.Read("addons/zvox/.git/HEAD", "GAME")
		if not git_nfo then
			return
		end

		local git_new = string.match(git_nfo, "ref: refs/heads/(.+)$")
		if not git_new then
			return
		end

		git_branch = string.sub(git_new, 1, -2)
	end
end
reComputeGitBranch()
reComputeGitID()



-- from LK3D
local concat_friendly = {}
concat_friendly[3] = ","
concat_friendly[5] = ","
concat_friendly[7] = ")"

local head_str = "v("
local patt_form = "%5.1f"
local function friendly_vstr(vec)
	concat_friendly[1] = head_str
	concat_friendly[2] = string.format(patt_form, vec[1])
	concat_friendly[4] = string.format(patt_form, vec[2])
	concat_friendly[6] = string.format(patt_form, vec[3])

	return table.concat(concat_friendly, "")
end

local patt_form_d = "%5.2f"
local function friendly_vstr_d(vec)
	concat_friendly[1] = head_str
	concat_friendly[2] = string.format(patt_form_d, vec[1])
	concat_friendly[4] = string.format(patt_form_d, vec[2])
	concat_friendly[6] = string.format(patt_form_d, vec[3])

	return table.concat(concat_friendly, "")
end

local patt_form_voxl = "%3.0f"
local function friendly_vstr_voxl(vec)
	concat_friendly[1] = head_str
	concat_friendly[2] = string.format(patt_form_voxl, vec[1])
	concat_friendly[4] = string.format(patt_form_voxl, vec[2])
	concat_friendly[6] = string.format(patt_form_voxl, vec[3])

	return table.concat(concat_friendly, "")
end


local head_str_a = "a("
local patt_form_a = "%5.1f"
local function friendly_astr(ang)
	concat_friendly[1] = head_str_a
	concat_friendly[2] = string.format(patt_form_a, ang[1])
	concat_friendly[4] = string.format(patt_form_a, ang[2])
	concat_friendly[6] = string.format(patt_form_a, ang[3])

	return table.concat(concat_friendly, "")
end

local function friendly_num(num)
	return string.format("%4.3f", num)
end

local divStr = string.rep("-", 24)


local _debugDrawHeight = 0
local function incDebugDrawHeight()
	_debugDrawHeight = _debugDrawHeight + 28
end



local c_gray = Color(128, 128, 128)
local function debugDrawSeparator()
	ZVox.DrawRetroTextShadowed(nil, divStr, 8, _debugDrawHeight, c_gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
end

-- https://stackoverflow.com/questions/10989788/format-integer-in-lua
local function reformatInt(i)
	return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local maxTextures = ZVox.GetMaxTextureCount()
local memUsage = "0"
local nextMemCheck = 0
local c_stats = Color(255, 120, 140)
local function debugDrawStats()
	if CurTime() > nextMemCheck then
		memUsage = reformatInt(math.floor(collectgarbage("count")))
		nextMemCheck = CurTime() + 1
	end

	debugDrawSeparator()


	ZVox.DrawRetroTextShadowed(nil, "Voxel ID Count: " .. ZVox.GetVoxelCount() .. " / 268435456", 8, _debugDrawHeight, c_stats, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	ZVox.DrawRetroTextShadowed(nil, "Texture Count: " .. ZVox.GetTextureCount() .. " / " .. maxTextures, 8, _debugDrawHeight, c_stats, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	ZVox.DrawRetroTextShadowed(nil, "Lua Mem Usage: " .. memUsage .. " KiB", 8, _debugDrawHeight, c_stats, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
end

local c_cam = Color(255, 180, 140)
local function debugDrawCam()
	debugDrawSeparator()

	ZVox.DrawRetroTextShadowed(nil, "Cam Pos: " .. friendly_vstr(ZVox.CamPos), 8, _debugDrawHeight, c_cam, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
	ZVox.DrawRetroTextShadowed(nil, "Cam Ang: " .. friendly_astr(ZVox.CamAng), 8, _debugDrawHeight, c_cam, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
end

local c_ply = Color(255, 180, 255)
local function debugDrawPlayer()
	debugDrawSeparator()

	ZVox.DrawRetroTextShadowed(nil, "Ply Pos: " .. friendly_vstr(ZVox.GetPlayerPos()), 8, _debugDrawHeight, c_ply, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
	ZVox.DrawRetroTextShadowed(nil, "Ply Vel: " .. friendly_vstr_d(ZVox.GetPlayerVel()) .. " (" .. tostring(friendly_num(ZVox.GetPlayerVel():Length())) .. ")", 8, _debugDrawHeight, c_ply, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
	ZVox.DrawRetroTextShadowed(nil, "Ply Grounded: " .. (ZVox.GetPlayerGrounded() and "true" or "false"), 8, _debugDrawHeight, c_ply, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
end


local c_voxl = Color(140, 255, 180)
local function debugDrawEyeTrace()
	local eyeTrace = ZVox.GetEyeTrace()
	if not eyeTrace.Hit then
		return
	end

	if not eyeTrace.VoxelID then
		return
	end

	debugDrawSeparator()

	local lookAtBlockPos = eyeTrace.HitMapPos
	ZVox.DrawRetroTextShadowed(nil, "Voxel Pos: " .. friendly_vstr_voxl(lookAtBlockPos), 8, _debugDrawHeight, c_voxl, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	local voxID = eyeTrace.VoxelID
	ZVox.DrawRetroTextShadowed(nil, "Voxel ID: " .. tostring(voxID), 8, _debugDrawHeight, c_voxl, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	local voxState = eyeTrace.VoxelState
	ZVox.DrawRetroTextShadowed(nil, "Voxel State: " .. tostring(voxState), 8, _debugDrawHeight, c_voxl, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	ZVox.DrawRetroTextShadowed(nil, "Voxel Name: " .. ZVox.GetVoxelName(voxID), 8, _debugDrawHeight, c_voxl, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
end

local c_mesh = Color(180, 140, 255)
local function debugDrawRendering()
	debugDrawSeparator()

	local remeshCount = ZVox.GetToRemeshCount() or 0
	ZVox.DrawRetroTextShadowed(nil, "To Remesh: " .. remeshCount, 8, _debugDrawHeight, c_mesh, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	local remeshSecCount = ZVox.GetRemeshesPerSec() or 0
	ZVox.DrawRetroTextShadowed(nil, "Remesh/s: " .. remeshSecCount, 8, _debugDrawHeight, c_mesh, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	ZVox.DrawRetroTextShadowed(nil, "Particles: " .. (ZVox.GetActiveParticleCount()), 8, _debugDrawHeight, c_mesh, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
end

local c_univ = Color(140, 180, 255)
local function debugDrawUniverse()
	local univ = ZVox.GetActiveUniverse()
	if not univ then
		return
	end
	debugDrawSeparator()


	ZVox.DrawRetroTextShadowed(nil, "Univ Name: " .. univ.name, 8, _debugDrawHeight, c_univ, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	local cSizeX = univ.chunkSizeX
	local cSizeY = univ.chunkSizeY
	local cSizeZ = univ.chunkSizeZ
	ZVox.DrawRetroTextShadowed(nil, "Univ Chunk Count: " .. tostring(cSizeX .. "x" .. cSizeY .. "x" .. cSizeZ), 8, _debugDrawHeight, c_univ, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
	ZVox.DrawRetroTextShadowed(nil, "Cam Chunk Idx: " .. (ZVox.GetCamChunkIndex()), 8, _debugDrawHeight, c_univ, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
end

local c_multiplayer = Color(180, 255, 140)
local function debugDrawMP()
	debugDrawSeparator()

	local inboundActions = ZVox.GetInboundActionsPerSec() or 0

	ZVox.DrawRetroTextShadowed(nil, "Inbound act/s: " .. inboundActions, 8, _debugDrawHeight, c_multiplayer, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()

	local outBoundActions = ZVox.GetOutboundActionsPerSec() or 0

	ZVox.DrawRetroTextShadowed(nil, "Outbound act/s: " .. outBoundActions, 8, _debugDrawHeight, c_multiplayer, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	incDebugDrawHeight()
end


local matAtlas = ZVox.GetTextureAtlasMat()
local atlasSz = ZVox.GetTextureAtlasSize()


local function debugDrawAtlas()
	local renderSz = atlasSz * 1
	local pad = 32


	local atlasX = (ScrW() - renderSz) - pad
	local atlasY = pad

	render.PushFilterMag(ZVOX_FILTERMODE)
	render.PushFilterMin(ZVOX_FILTERMODE)
		surface.SetDrawColor(16, 16, 32, 196)
		surface.DrawRect(atlasX, atlasY, renderSz, renderSz)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(matAtlas)
		surface.DrawTexturedRect(atlasX, atlasY, renderSz, renderSz)
	render.PopFilterMag()
	render.PopFilterMin()
end

local niceBranchLUT = {
	["unknown"] = "UNSUPPORTED none 32bit",
	["dev"] = "UNSUPPORTED dev 32bit",
	["prerelease"] = "UNSUPPORTED prerelease 32bit",
	["x86-64"] = "x86-64 64bit",
}

local gameBranch = niceBranchLUT[BRANCH] or "Unknown?"
local gameOS = jit.os
local c_white = Color(255, 255, 255)
function ZVox.DebugDrawInfo()
	if not ZVox.DebugDraw then
		return
	end

	if ZVox.GetCameraModeState() then
		return
	end

	_debugDrawHeight = 74

	ZVox.DrawRetroTextShadowed(nil, ZVOX_VERSION .. " @ " .. gameBranch .. " (" .. gameOS .. ")", 8, _debugDrawHeight, c_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 4)
	_debugDrawHeight = _debugDrawHeight + 36

	if git_branch then
		ZVox.DrawRetroTextShadowed(nil, "branch - " .. git_branch, 8, _debugDrawHeight, c_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 4)
		_debugDrawHeight = _debugDrawHeight + 36
	end

	if git_current then
		ZVox.DrawRetroTextShadowed(nil, "commit - " .. git_current, 8, _debugDrawHeight, c_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 4)
		_debugDrawHeight = _debugDrawHeight + 36
	end

	debugDrawStats()

	debugDrawCam()

	debugDrawPlayer()

	debugDrawUniverse()

	debugDrawRendering()

	debugDrawMP()

	debugDrawEyeTrace()

	debugDrawAtlas()
end


local cubeMeshWF = ZVox.GetCubeLineMesh(Vector(0, 0, 0), Vector(1, 1, 1), 255, 255, 255)
local cubeMesh = ZVox.GetCubeMesh(Vector(.5, .5, .5), Vector(.5, .5, .5), false)


local _redRT, _redMat = ZVox.NewRTMatPair("red_rt_notex", 4, 4, function()
	render.Clear(255, 0, 255, 255)
end)

local _redRTTransp, _redMatTransp = ZVox.NewRTMatPairAlpha("red_rt_notex_transp", 4, 4, function()
	render.Clear(255, 255, 255, 64)
end)

local colVecVec = Vector()
function ZVox.DebugDrawCollisions() -- draws the searcher collisions
	if not ZVox.DebugDraw then
		return
	end

	if not ZVOX_DEBUGDRAW_COLLISIONS then
		return
	end

	local results = ZVox.PHYSICS_GetLastCollisionSearcherResults()
	if not results then
		return
	end

	local resCount = #results
	if resCount <= 0 then
		return
	end

	local mtxBox = Matrix()
	local sclVec = Vector(0, 0, 0)
	local trsVec = Vector(0, 0, 0)

	for i = 1, resCount do
		local delta = i / resCount
		local hsvCol = HSVToColor(delta * 360, 1, 0.8)

		colVecVec:SetUnpacked(hsvCol.r / 255, hsvCol.g / 255, hsvCol.b / 255)
		_redMatTransp:SetVector("$color", colVecVec)


		local result = results[i]
		local x, y, z = result[1], result[2], result[3]

		local minX = result[5]
		local minY = result[6]
		local minZ = result[7]


		local szX = result[ 8] - result[5]
		local szY = result[ 9] - result[6]
		local szZ = result[10] - result[7]

		mtxBox:Identity()

		sclVec:SetUnpacked(szX, szY, szZ)
		mtxBox:SetScale(sclVec)

		trsVec:SetUnpacked(x + minX, y + minY, z + minZ)
		mtxBox:SetTranslation(trsVec)

		cam.PushModelMatrix(mtxBox, true)
			render.SetMaterial(_redMatTransp)
			cubeMesh:Draw()

			render.SetMaterial(_redMat)
			cubeMeshWF:Draw()
		cam.PopModelMatrix()
	end
end


local _whiteRT, _whiteMat = ZVox.NewRTMatPair("white_rt_notex", 4, 4, function()
	render.Clear(255, 255, 255, 255)
end)

local vtxBoundaries = Vector(0, 0, 0)
local mtxBoundaries = Matrix()


local meshChunkBoundaries = ZVox.GetChunkBoundaryMesh()
function ZVox.DebugDrawChunkBorders()
	if not ZVox.DebugDraw then
		return
	end

	local camState = ZVox.GetCameraModeState()
	if camState then
		return
	end

	local plyUniv = ZVox.GetActiveUniverse()
	if not plyUniv then
		return
	end

	local camPos = ZVox.GetCamPos()
	if not camPos then
		return
	end

	local chIdx = ZVox.WorldToChunkIndex(plyUniv, camPos[1], camPos[2], camPos[3])
	local cX, cY, cZ = ZVox.ChunkIndexToWorld(plyUniv, chIdx)

	vtxBoundaries:SetUnpacked(cX, cY, cZ)
	mtxBoundaries:Identity()
	mtxBoundaries:SetTranslation(vtxBoundaries)

	cam.PushModelMatrix(mtxBoundaries)
		render.SetMaterial(_whiteMat)
		meshChunkBoundaries:Draw()
	cam.PopModelMatrix()
end

local vtxLines = Vector(0, 0, 0)
local mtxLines = Matrix()

local meshAxisLines = ZVox.GetAxisLineMesh(.15)
function ZVox.DebugDrawAxisLine()
	if not ZVox.DebugDraw then
		return
	end

	local camState = ZVox.GetCameraModeState()
	if camState then
		return
	end

	local camPos = ZVox.GetCamPos()
	if not camPos then
		return
	end

	local camForward = ZVox.GetCamForward()

	-- offset it forwards a bit 
	vtxLines:Set(camPos)
	--vtxLines:SetUnpacked(0, 0, 0)
	vtxLines:Add(camForward)

	mtxLines:Identity()
	mtxLines:SetTranslation(vtxLines)
	--mtxLines:SetScale(vtxLinesScl)

	render.OverrideDepthEnable(true, false)
	render.DepthRange(0.0, 0.0)

	cam.PushModelMatrix(mtxLines, true)
		render.SetMaterial(_whiteMat)
		meshAxisLines:Draw()
	cam.PopModelMatrix()

	render.DepthRange(0.0, 1.0)
	render.OverrideDepthEnable(false, false)
end