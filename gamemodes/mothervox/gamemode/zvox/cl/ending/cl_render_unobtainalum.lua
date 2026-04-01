ZVox = ZVox or {}


local UNOBTAINALUM_POS = UNOBTAINALUM_POS + Vector(.5, .5, .5)

local meshCube2 = ZVox.GetCubeMesh(Vector(0, 0, 0), Vector(.55, .55, .55), true)
local mtxCube2 = Matrix()

local meshCube1 = ZVox.GetCubeMesh(Vector(0, 0, 0), Vector(.5, .5, .5), false)
local mtxBase = Matrix()

local emptyMatrix = Matrix()
function ZVox.RenderUnobtainalum()
	render.SetColorMaterial()

	-- As THE stencil tutorial once said, Reset everything to known good
	render.ClearStencil()
	render.SetStencilEnable(false)
	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)
	render.SetStencilReferenceValue(0)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)

	--render.OverrideColorWriteEnable(true, false)
	--	renderCubePlanes()
	--render.OverrideColorWriteEnable(false, false)
	mtxBase:Identity()
	mtxBase:SetTranslation(UNOBTAINALUM_POS)
	render.OverrideDepthEnable(true, false)
	render.OverrideColorWriteEnable(true, false)
	cam.PushModelMatrix(mtxBase)
		meshCube1:Draw()
	cam.PopModelMatrix()
	render.OverrideColorWriteEnable(false, false)
	render.OverrideDepthEnable(false, false)


	render.SetStencilReferenceValue(1)

	render.SetStencilZFailOperation(STENCILOPERATION_INCR)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)


	mtxCube2:Identity()
	mtxCube2:SetTranslation(UNOBTAINALUM_POS)
	mtxCube2:Rotate(Angle(CurTime() * 64, CurTime() * 48, CurTime() * 21))
	render.OverrideDepthEnable(true, false)
	render.OverrideColorWriteEnable(true, false)
	cam.PushModelMatrix(mtxCube2)
		meshCube2:Draw()
	cam.PopModelMatrix()
	render.OverrideColorWriteEnable(false, false)
	render.OverrideDepthEnable(false, false)

	render.SetStencilReferenceValue(2)
	render.ClearBuffersObeyStencil(0, 0, 0, 0, true)

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(2)
	local unobtTex = ZVox.GetTextureByName("zvox:unobtainalum")
	mtxBase:Identity()
	mtxBase:SetTranslation(UNOBTAINALUM_POS)
	--render.DepthRange(0, 0)
	render.CullMode(MATERIAL_CULLMODE_CW)
	render.SetMaterial(unobtTex.mat_z)
	cam.PushModelMatrix(mtxBase)
		meshCube1:Draw()
	cam.PopModelMatrix()
	render.CullMode(MATERIAL_CULLMODE_CCW)
	--render.DepthRange(0, 1)


	render.SetStencilReferenceValue(2)
	cam.Start2D()
	cam.PushModelMatrix(emptyMatrix)
		ZVox.BlurScreen(1, 512)

		--ZVox.BlurScreen(1, 512)
		--ZVox.BlurScreen(1, 256)
	cam.PopModelMatrix()
	cam.End2D()

	render.SetStencilEnable(false)
	render.ClearStencil()
end