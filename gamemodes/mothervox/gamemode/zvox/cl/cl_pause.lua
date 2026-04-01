ZVox = ZVox or {}

ZVox.PauseStack = ZVox.PauseStack or 0
local doTempPause = false

function ZVox.SetTempPause(state)
	doTempPause = state
end

function ZVox.GetGamePaused()
	return (ZVox.PauseStack > 0) or doTempPause or ZVox.IsEscapeMenuOpen()
end

function ZVox.GetGameTempPaused()
	return doTempPause
end

function ZVox.IncrementPauseStack()
	if ZVox.PauseStack == 0 then
		ZVox.OnPause()
	end

	ZVox.PauseStack = ZVox.PauseStack + 1
end

function ZVox.DecrementPauseStack()
	if ZVox.PauseStack <= 0 then
		ZVox.PrintError("PauseStack going < 0, bad!")
	end

	if ZVox.PauseStack == 1 then
		ZVox.OnUnpause()
	end

	ZVox.PauseStack = math.max(ZVox.PauseStack - 1, 0)
end

local lastUnpause = 0
function ZVox.OnUnpause()
	lastUnpause = CurTime()
end

function ZVox.OnPause()
	ZVox.Sound_EndVehicleSounds()
end

-- just in case
concommand.Add("mothervox_fix_pause_stuck", function()
	ZVox.OnUnpause()
	ZVox.PauseStack = 0
end)



-- im lazy as fuuuuck
-- https://wiki.facepunch.com/gmod/surface.DrawPoly
local function drawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end


local transitionLen = 1
function ZVox.RenderPauseTransitionFX()
	if ZVox.PauseStack ~= 0 then
		return
	end

	local fxDelta = (CurTime() - lastUnpause) / transitionLen
	fxDelta = math.min(fxDelta, 1)

	if fxDelta >= 1 then
		return
	end

	local largerDim = math.max(ScrW(), ScrH())

	local cX = ScrW() * .5
	local cY = ScrH() * .5

	local circSize = fxDelta * largerDim

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
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilReferenceValue(1)


	render.OverrideColorWriteEnable(true, false)
	surface.SetDrawColor(255, 255, 255)
	draw.NoTexture()
	drawCircle(cX, cY, circSize, 32)
	render.OverrideColorWriteEnable(false, false)

	render.SetStencilReferenceValue(0)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

	render.ClearBuffersObeyStencil(0, 0, 0, 255, true)

	render.SetStencilEnable(false)
end