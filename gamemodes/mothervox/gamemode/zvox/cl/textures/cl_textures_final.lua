ZVox = ZVox or {}

function ZVox.ComputeAllTextures()
	ZVox.NAMESPACES_SetActiveNamespace("zvox")
	ZVox.ComputeAbstractTextures()
	ZVox.ComputeBrickTextures()
	ZVox.ComputeCrystalTextures()
	ZVox.ComputeDebugTextures()
	ZVox.ComputeMetalTextures()
	ZVox.ComputeNatureTextures()
	ZVox.ComputeNumberTextures()
	ZVox.ComputePumpkinTextures()
	ZVox.ComputeStoneTextures()
	ZVox.ComputeWoodTextures()
	ZVox.ComputeWoolTextures()
end

ZVox.ComputeAllTextures()
ZVox.RecomputeTextureAtlas()