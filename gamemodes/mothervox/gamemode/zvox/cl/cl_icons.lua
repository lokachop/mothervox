ZVox = ZVox or {}
local voxelInfoRegistry = ZVox.GetVoxelRegistry()

local iconSize = 64


-- This file handles generating Transparent 64x64 icons for ALL of the voxels
local voxelIcons = {}
function ZVox.GetIconRegistry()
	return voxelIcons
end

function ZVox.GetVoxelIcon(ID)
	return voxelIcons[ID]
end

function ZVox.GetVoxelIconMat(ID)
	if not voxelIcons[ID] then
		return voxelIcons[1].mat
	end

	return voxelIcons[ID].mat
end


local function populateIDMaterial(ID)
	if voxelIcons[ID] ~= nil then
		return
	end

	local iconRT = GetRenderTargetEx("zvox_icon_rt_" .. ID, iconSize, iconSize, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, 1, 4, IMAGE_FORMAT_RGBA8888)
	local iconMat = CreateMaterial("zvox_icon_mat_" .. ID, "UnlitGeneric", {
		["$basetexture"] = iconRT:GetName(),
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
		["$nocull"] = 1,
		["$ignorez"] = 1,
	})

	voxelIcons[ID] = {
		["rt"] = iconRT,
		["mat"] = iconMat,
	}
end



local matrixRot = Matrix()
matrixRot:SetAngles(Angle(0, 180, 0))
local vec_white = Vector(1, 1, 1)
function ZVox.RecomputeVoxelIcon(ID)
	if not voxelIcons[ID] then
		populateIDMaterial(ID)
	end

	local voxelIcon = voxelIcons[ID]

	-- now we render
	-- first we need the icon mesh so
	local cubeMesh = ZVox.GetVoxelMesh(ID, Vector(0, 0, 0), Vector(1, 1, 1))
	if not cubeMesh then
		return
	end

	local atlasMat = ZVox.GetTextureAtlasMat()
	ZVox.SetTextureAtlasTint(vec_white)


	ZVox.RenderOnRT(voxelIcon.rt, function()
		render.ClearDepth()
		render.ClearStencil()
		render.Clear(0, 0, 0, 0)


		render.SetWriteDepthToDestAlpha(false)
		local _sz = 1.75
		cam.Start({
			type = "3D",
			x = 0,
			y = 0,
			w = iconSize,
			h = iconSize,
			aspect = 1,

			origin = Vector(-1.999, -2, 1.75), -- You Must Learn To Love The Floating Point Arithmetic IEEE 754 Numbers ! ! !
			angles = Angle(22.5 + 11.25 - 2.8125, 45, 0),
			fov = 90,
			zfar = 10,
			znear = .1,

			ortho = {
				left   = -_sz,
				right  =  _sz,
				bottom =  _sz,
				top    = -_sz,
			},
		})

			-- Why all of this shit and not just
			-- render.SetMaterial(atlasMat)
			-- cubeMesh:Draw() ?
			-- Because, if you do it that way, it refuses to work on a transparent rendertarget on first run so...
			-- You first have to enable stencil writes...
			-- Then you need to render it with blend
			-- Then you use the stencil buffer to clear the undrawn to alpha 0...
			-- DONE!
			-- Yay, GMod rendering for the win!

			-- As THE stencil tutorial once said, Reset everything to known good
			render.SetStencilEnable(false)
			render.SetStencilTestMask(255)
			render.SetStencilWriteMask(255)
			render.SetStencilReferenceValue(0)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

			render.SetStencilEnable(true)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			render.SetStencilReferenceValue(1)

			render.OverrideBlend(true, BLEND_ONE, BLEND_ZERO, BLENDFUNC_MAX, BLEND_ONE, BLEND_ONE, BLENDFUNC_MAX)
				render.OverrideDepthEnable(true, true)
				cam.PushModelMatrix(matrixRot, true)
					render.SetMaterial(atlasMat)
					cubeMesh:Draw()
				cam.PopModelMatrix()
				render.OverrideDepthEnable(false, false)
			render.OverrideBlend(false)

			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
			render.SetStencilReferenceValue(0)
			render.ClearBuffersObeyStencil(0, 0, 0, 0, true)
			render.SetStencilEnable(false)

		cam.End3D()
	end)


	cubeMesh:Destroy()
	cubeMesh = nil
end


function ZVox.RecomputeIcons()
	for i = 0, #voxelInfoRegistry do
		ZVox.RecomputeVoxelIcon(i)
	end
end

ZVox.RecomputeIcons()