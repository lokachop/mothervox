ZVox = ZVox or {}


local _rtStack = {}
local _currRT = GetRenderTarget("zvox_fallback", 800, 600)

function ZVox.PushRenderTarget(rt)
	_rtStack[#_rtStack + 1] = _currRT
	_currRT = rt
end

function ZVox.PopRenderTarget()
	_currRT = _rtStack[#_rtStack]
	_rtStack[#_rtStack] = nil

	return _currRT
end

function ZVox.GetCurrRT()
	return _currRT
end

function ZVox.ClearRT(r, g, b)
	render.PushRenderTarget(_currRT)
		render.Clear(r, g, b, 255, true, true)
	render.PopRenderTarget()
end

function ZVox.ClearRTDepth()
	render.PushRenderTarget(_currRT)
		render.ClearDepth()
		render.ClearStencil()
	render.PopRenderTarget()
end

function ZVox.RenderRTToScreen(rt)
	rt = rt or _currRT

	render.DrawTextureToScreenRect(rt, 0, 0, ScrW(), ScrH())
end

function ZVox.GetViewPortRT()
	local w = ScrW()
	local h = ScrH()

	if ZVOX_DO_LOWRES_VIEWPORT then
		w = w * .15
		h = h * .15
	end

	return GetRenderTarget("zvox_viewport_" .. w .. "x" .. h, w, h)
end