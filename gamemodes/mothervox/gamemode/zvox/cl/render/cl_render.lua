ZVox = ZVox or {}
local _whiteRT, _whiteMat = ZVox.NewRTMatPair("white_rt_notex", 4, 4, function()
	render.Clear(255, 255, 255, 255)
end)

local vec_white = Vector(1, 1, 1)
local function renderChunk_New(chunk, group)
	local renderMatrix = chunk["renderMatrix"]
	if not renderMatrix then
		return
	end

	if not chunk["renderObjects"] then
		return
	end

	local renderObj = chunk["renderObjects"][group]
	if not renderObj then
		return
	end

	if #renderObj <= 0 then
		return
	end
	cam.PushModelMatrix(renderMatrix)
	for i = 1, #renderObj do
		local meshObj = renderObj[i]
		meshObj:Draw()
	end
	cam.PopModelMatrix()
end


local wfMat = Material("editor/wireframe")
local voxelgroupMatLUT = ZVox.GetVoxelGroupMaterialLUT()
local function renderChunks_New(univ, group)
	local chunks = univ["chunks"]
	local chunkCount = #chunks

	if not ZVOX_DO_TEXTURES then
		render.SetMaterial(_whiteMat)
	else
		render.SetMaterial(voxelgroupMatLUT[group])
	end

	if ZVOX_DO_WIREFRAME then
		render.SetMaterial(wfMat)
	end

	render.OverrideDepthEnable(true, true)
		for j = 0, chunkCount do
			if ZVOX_DO_FRUSTRUM_CULLING and ZVox.IsChunkIndexCulled(j) then
				continue
			end


			renderChunk_New(chunks[j], group)
		end
	render.OverrideDepthEnable(false, false)
end


function ZVox.RenderUniverseChunksOnly(univObj)
	if not univObj then
		return
	end

	ZVox.SetTextureAtlasTint(ZVox.GetUniverseTrueWorldTint(univObj) or vec_white)

	renderChunks_New(univObj, ZVOX_VOXELGROUP_SOLID)
	renderChunks_New(univObj, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)
	if not ZVOX_DO_SINGLE_PASS_GLASS then
		render.OverrideDepthEnable(true, true)
		render.OverrideColorWriteEnable(true, false)
			renderChunks_New(univObj, ZVOX_VOXELGROUP_TRANSLUCENT)
		render.OverrideColorWriteEnable(false, false)
		render.OverrideDepthEnable(false, false)
	end
	renderChunks_New(univObj, ZVOX_VOXELGROUP_TRANSLUCENT)
end



local texturizeW = 16
local texturizeH = 128
local texturizeIndexHash = texturizeW .. ":" .. texturizeH
local texturizeRT = GetRenderTarget("mothervox_texturize_rt_" .. texturizeIndexHash, texturizeW, texturizeH)
local texturizeMat = CreateMaterial("mothervox_texturize_mat" .. texturizeIndexHash, "UnlitGeneric", {
	["$basetexture"] = texturizeRT:GetName(),
	["$nocull"] = 1,
	["$ignorez"] = 1,
	["$vertexcolor"] = 1,
})
ZVox.PixelFuncOnRT(texturizeRT, function(x, y)
	local xD = x / texturizeRT:Width()
	local yD = math.min(y / texturizeRT:Height(), 1)

	return yD * 48 * 4, yD * 32 * 4, yD * 16 * 4
end)

function ZVox.RenderUniverse(univObj)
	if not univObj then
		return
	end

	ZVox.RemeshChunkHandle()

	ZVox.SetTextureAtlasTint(ZVox.GetUniverseTrueWorldTint(univObj) or vec_white)

	local currRT = ZVox.GetCurrRT()
	local rtW, rtH = currRT:Width(), currRT:Height()
	local oW, oH = ScrW(), ScrH()
	render.SetViewPort(0, 0, rtW, rtH)
	cam.Start2D()
		render.PushRenderTarget(currRT)
			render.PushFilterMag(ZVOX_FILTERMODE)
			render.PushFilterMin(ZVOX_FILTERMODE)
				cam.Start({
					type = "3D",
					x = 0,
					y = 0,
					w = rtW,
					h = rtH,
					aspect = rtW / rtH,
					origin = ZVox.CamPos,
					angles = ZVox.CamAng,
					fov = ZVox.CamFOV,
					zfar = ZVox.CamFarZ, -- closer zfar and znear for sky and bounds
					znear = ZVox.CamNearZ * .05,
				})
					render.Clear(48, 32, 16, 255, true, true)

					ZVox.RenderSky(univObj)
				cam.End3D()


				cam.Start({
					type = "3D",
					x = 0,
					y = 0,
					w = rtW,
					h = rtH,
					aspect = rtW / rtH,
					origin = ZVox.CamPos,
					angles = ZVox.CamAng,
					fov = ZVox.CamFOV,
					zfar = ZVox.CamFarZ,
					znear = ZVox.CamNearZ,
				})
					-- Frustrum culling
					if ZVOX_DO_FRUSTRUM_CULLING and not ZVOX_DO_FRUSTRUM_CULLING_FREEZE then
						ZVox.RecomputeFrustrum()
						ZVox.ComputeCulledChunks(univObj)
					end

					ZVox.BeginFog()

					renderChunks_New(univObj, ZVOX_VOXELGROUP_SOLID)
					renderChunks_New(univObj, ZVOX_VOXELGROUP_BINARY_TRANSPARENCY)

					ZVox.RenderVoxelHighlight()


					ZVox.RenderParticles(univObj)

					renderChunks_New(univObj, ZVOX_VOXELGROUP_WATER)

					if not ZVOX_DO_SINGLE_PASS_GLASS then
						render.OverrideDepthEnable(true, true)
						render.OverrideColorWriteEnable(true, false)
							renderChunks_New(univObj, ZVOX_VOXELGROUP_TRANSLUCENT)
							--renderChunks_New(univObj, ZVOX_VOXELGROUP_WATER)
						render.OverrideColorWriteEnable(false, false)
						render.OverrideDepthEnable(false, false)
					end

					renderChunks_New(univObj, ZVOX_VOXELGROUP_TRANSLUCENT)

					ZVox.RenderUnobtainalum()


					ZVox.RenderVoxelHighlight()
					ZVox.RenderPostClouds(univObj)

					ZVox.EndFog()

					ZVox.ComputeLensFlareVisibility(univObj)

					ZVox.DebugDrawCollisions()
					ZVox.DebugDrawChunkBorders()

					ZVox.DebugDrawAxisLine()

					ZVox.Scanner_ComputeScannerVisibility()
				cam.End3D()


				-- VM afterwards so we can clear depth and render there
				-- VM also uses different FoV and origin / angles
				cam.Start({
					type = "3D",
					x = 0,
					y = 0,
					w = rtW,
					h = rtH,
					aspect = rtW / rtH,
					origin = Vector(0, 0, 0),
					angles = Angle(0, 0, 0),
					fov = ZVox.ViewmodelFOV,
					zfar = ZVox.CamFarZ,
					znear = ZVox.CamNearZ,
				})
					ZVox.RenderViewmodel(univObj)
				cam.End3D()
			render.PopFilterMin()
			render.PopFilterMag()
		render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, oW, oH)

	ZVox.SetTextureAtlasTint(vec_white)
end

local rtRender = ZVox.GetViewPortRT()
local matRender = ZVox.NewMatFromRT(ZVox.GetViewPortRT(), "viewport")
ZVox.NewSettingListener("zvox_render_lowres_recompute_rt", "fun_lowres_viewport", function(newState)
	rtRender = ZVox.GetViewPortRT()

	if newState then
		matRender = ZVox.NewMatFromRT(rtRender, "viewport_lq")
	else
		matRender = ZVox.NewMatFromRT(rtRender, "viewport")
	end
end)

function ZVox.RenderFramebuffer()
	local shakeX, shakeY = ZVox.GetScreenShake()

	render.PushFilterMag(ZVOX_FILTERMODE)
	render.PushFilterMin(ZVOX_FILTERMODE)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(matRender)
		surface.DrawTexturedRect(shakeX, shakeY, ScrW(), ScrH())

		--render.DrawTextureToScreenRect(rtRender, shakeX, shakeY, ScrW(), ScrH())
		ZVox.RenderLensFlare()

		--DrawTexturize(32, texturizeMat)
		if not gui.IsGameUIVisible() then
			DrawBloom(0.325, 4, 6, 6, 3, 1, 1, .4, 0)
		end
	render.PopFilterMag()
	render.PopFilterMin()
end