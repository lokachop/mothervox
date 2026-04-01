ZVox = ZVox or {}

local math = math
local math_floor = math.floor

function ZVox.RenderOnRT(rt, func)
	local ow, oh = ScrW(), ScrH()
	render.SetViewPort(0, 0, rt:Width(), rt:Height())
	render.PushRenderTarget(rt)
	cam.Start2D()
	render.PushFilterMag(ZVOX_FILTERMODE)
	render.PushFilterMin(ZVOX_FILTERMODE)
	render.OverrideAlphaWriteEnable(true, true) -- This for transparent RenderTargets
		local fine, ret = pcall(func)
		if not fine then
			ZVox.PrintError("ZVox.RenderOnRT fail!: " .. tostring(ret))
		end
	render.OverrideAlphaWriteEnable(false)
	render.PopFilterMag()
	render.PopFilterMin()
	cam.End2D()
	render.PopRenderTarget()
	render.SetViewPort(0, 0, ow, oh)
end


function ZVox.RenderOnRT_SubRect(rt, x, y, w, h, func)
	local ow, oh = ScrW(), ScrH()
	render.PushRenderTarget(rt)
	render.SetViewPort(x, y, w, h)
	cam.Start2D()
	render.PushFilterMag(ZVOX_FILTERMODE)
	render.PushFilterMin(ZVOX_FILTERMODE)
	render.OverrideAlphaWriteEnable(true, true) -- This for transparent RenderTargets
		local fine, ret = pcall(func)
		if not fine then
			ZVox.PrintError("ZVox.RenderOnRT fail!: " .. tostring(ret))
		end
	render.OverrideAlphaWriteEnable(false)
	render.PopFilterMag()
	render.PopFilterMin()
	cam.End2D()
	render.PopRenderTarget()
	render.SetViewPort(0, 0, ow, oh)
end



local matrixAnim = Matrix()
local vectorAnim = Vector()
function ZVox.RenderOnRT_TextureSpecialized(rt, func)
	local frameOffset = 0
	if ZVOX_RENDERING_ANIMATED_TEXTURE then
		rt = ZVOX_RENDERING_ANIMATED_TEXTURE_RT
		frameOffset = ZVOX_RENDERING_ANIMATED_TEXTURE_FRAME * 16 -- TODO: unhardcode when hires texture pack support
	end


	local ow, oh = ScrW(), ScrH()

	if ZVOX_RENDERING_ANIMATED_TEXTURE then
		matrixAnim:Identity()

		vectorAnim[1] = frameOffset
		matrixAnim:SetTranslation(vectorAnim)

		render.SetViewPort(frameOffset, 0, rt:Height(), rt:Height())
	else
		matrixAnim:Identity()

		render.SetViewPort(0, 0, rt:Width(), rt:Height())
	end
	render.PushRenderTarget(rt)
	cam.Start2D()
	render.PushFilterMag(ZVOX_FILTERMODE)
	render.PushFilterMin(ZVOX_FILTERMODE)
	if system.IsLinux() then
		render.OverrideAlphaWriteEnable(false, false) -- This for transparent RenderTargets
	else
		render.OverrideAlphaWriteEnable(true, true)
	end
		cam.PushModelMatrix(matrixAnim, true)
		local fine, ret = pcall(func)
		if not fine then
			ZVox.PrintError("ZVox.RenderOnRT fail!: " .. tostring(ret))
		end
		cam.PopModelMatrix()
	render.OverrideAlphaWriteEnable(false)
	render.PopFilterMag()
	render.PopFilterMin()
	cam.End2D()
	render.PopRenderTarget()
	render.SetViewPort(0, 0, ow, oh)
end


-- expensive
function ZVox.PixelFuncOnRT(rt, func)
	ZVox.RenderOnRT(rt, function()
		local oW, oH = ScrW(), ScrH()
		for i = 0, (oW * oH) -1 do
			local xc = i % oW
			local yc = math_floor(i / oW)

			local fine, r, g, b, a = pcall(func, xc, yc) -- if this errors, we're cooked, catch errors
			if not fine then
				continue
			end

			render.SetViewPort(xc, yc, 1, 1)
			render.Clear(r, g, b, a or 255)
		end
		render.SetViewPort(0, 0, oW, oH)
	end)
end

function ZVox.DrawHexWriteRect(rt, params, hex)
	local col = params.col or {255, 0, 0}
	local pos = params.pos or {0, 0}
	local size = params.size or {8, 8}
	local hexOrigin = params.hexOrigin or {0, 0}


	local r = col[1] or 0
	local g = col[2] or 0
	local b = col[3] or 0

	local x, y = pos[1], pos[2]
	local w, h = size[1], size[2]

	local hX, hY = hexOrigin[1], hexOrigin[2]

	local itrCount = w * h


	ZVox.RenderOnRT(rt, function()
		local oW, oH = ScrW(), ScrH()
		for i = 0, itrCount - 1 do
			local xcLocal = (i % w)
			local ycLocal = math.floor(i / w)

			local row = hex[ycLocal + 1 + hY]
			if not row then
				continue
			end


			local xcBand = 15 - (xcLocal + hX)

			local bitGet = bit.band(row, 2^xcBand)

			if bitGet == 0 then
				continue
			end

			render.SetViewPort(xcLocal + x, ycLocal + y, 1, 1)
			render.Clear(r, g, b, 255)
		end
		render.SetViewPort(0, 0, oW, oH)
	end)
end

function ZVox.SampleHexWrite(x, y, hexWrite)
	if x > 16 then
		return false
	end
	if x < 0 then
		return false
	end
	if y > 16 then
		return false
	end
	if y < 0 then
		return false
	end


	local row = hexWrite[y + 1]
	if not row then
		return false
	end

	local xBand = 15 - x

	local bitGet = bit.band(row, 2^xBand)

	if bitGet == 0 then
		return false
	end

	return true
end



local blur = Material("pp/blurscreen")
function ZVox.BlurScreen(itr, amount)
	if not ZVOX_DO_UI_BLUR then
		surface.SetDrawColor(0, 0, 0, amount * itr * 4)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		return
	end

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, itr do
		blur:SetFloat("$blur", (i / itr) * amount)
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end
	draw.NoTexture()
end

function ZVox.BlurScreenRect(x, y, w, h, itr, amount)
	if not ZVOX_DO_UI_BLUR then
		surface.SetDrawColor(0, 0, 0, amount * itr * 4)
		surface.DrawRect(x, y, w, h)
		return
	end


	local sW, sH = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, itr do
		blur:SetFloat("$blur", (i / itr) * amount)
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRectUV(x, y, w, h, x / sW, y / sH, (x + w) / sW, (y + h) / sH)
	end
	draw.NoTexture()
end

function ZVox.BlurScreenRectPanel(panel, x, y, w, h, itr, amount)
	if not IsValid(panel) then
		return
	end

	if not ZVOX_DO_UI_BLUR then
		surface.SetDrawColor(0, 0, 0, amount * itr * 4)
		surface.DrawRect(x, y, w, h)
		return
	end


	local ox, oy = panel:LocalToScreen(0, 0)
	local sW, sH = ScrW(), ScrH()

	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, itr do
		blur:SetFloat("$blur", (i / itr) * amount)
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRectUV(x, y, w, h, (x + ox) / sW, (y + oy) / sH, (x + ox + w) / sW, (y + oy + h) / sH)
	end
	draw.NoTexture()
end


function ZVox.RenderGradientOKLab(x, y, w, h, steps, cS, cE)
	steps = math.floor(steps)

	local stepSize = (h / steps)
	local stepFloor = math.floor(stepSize)

	local yAccum = y
	local errAccum = 0
	for i = 0, steps - 1 do
		local delta = i / (steps - 1)

		-- error algorithm so it doesn't overflow ever
		errAccum = errAccum + (stepSize - stepFloor)

		local errFloor = math.floor(errAccum)
		errAccum = errAccum - errFloor

		local colDrawThis = ZVox.NiceLerpColor(delta, cS, cE)
		surface.SetDrawColor(colDrawThis)
		surface.DrawRect(x, yAccum, w, stepFloor + errFloor)

		yAccum = yAccum + stepFloor + errFloor
	end
end

function ZVox.RenderGradientSRGB(x, y, w, h, steps, cS, cE)
	steps = math.floor(steps)

	local stepSize = (h / steps)
	local stepFloor = math.floor(stepSize)

	local yAccum = y
	local errAccum = 0
	for i = 0, steps - 1 do
		local delta = i / (steps - 1)

		-- error algorithm so it doesn't overflow ever
		errAccum = errAccum + (stepSize - stepFloor)

		local errFloor = math.floor(errAccum)
		errAccum = errAccum - errFloor


		local colDrawThis =  ZVox.LerpColor(delta, cS, cE)


		surface.SetDrawColor(colDrawThis)
		surface.DrawRect(x, yAccum, w, stepFloor + errFloor)

		yAccum = yAccum + stepFloor + errFloor
	end
end


function ZVox.RenderGradientSRGBHorizontal(x, y, w, h, steps, cS, cE)
	steps = math.floor(steps)

	local stepSize = (w / steps)
	local stepFloor = math.floor(stepSize)

	local xAccum = x
	local errAccum = 0
	for i = 0, steps - 1 do
		local delta = i / (steps - 1)

		-- error algorithm so it doesn't overflow ever
		errAccum = errAccum + (stepSize - stepFloor)

		local errFloor = math.floor(errAccum)
		errAccum = errAccum - errFloor


		local colDrawThis =  ZVox.LerpColor(delta, cS, cE)


		surface.SetDrawColor(colDrawThis)
		surface.DrawRect(xAccum, y, stepFloor + errFloor, h)

		xAccum = xAccum + stepFloor + errFloor
	end
end

-- TODO: rewrite to allow mat fixing when recomputing
function ZVox.NewRTMatPair(name, w, h, funcRender)
	local rt = GetRenderTarget("zvox_" .. name .. "_rt", w, h)
	if funcRender then
		ZVox.RenderOnRT(rt, funcRender)
	end

	local mat = CreateMaterial("zvox_" .. name .. "_mat", "UnlitGeneric", {
		["$basetexture"] = rt:GetName(),
		["$vertexcolor"] = 1,
	})

	return rt, mat
end


function ZVox.NewRTMatPairAlpha(name, w, h, funcRender)
	local rt = GetRenderTarget("zvox_t_" .. name .. "_rt", w, h)
	if funcRender then
		ZVox.RenderOnRT(rt, funcRender)
	end

	local mat = CreateMaterial("zvox_t_" .. name .. "_mat", "UnlitGeneric", {
		["$basetexture"] = rt:GetName(),
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
	})

	return rt, mat
end


function ZVox.NewRTMatPairPixelFunc(name, w, h, pixelFunc)
	local rt = GetRenderTarget("zvox_" .. name .. "_rt", w, h)
	if pixelFunc then
		ZVox.PixelFuncOnRT(rt, pixelFunc)
	end

	local mat = CreateMaterial("zvox_" .. name .. "_mat", "UnlitGeneric", {
		["$basetexture"] = rt:GetName(),
		["$vertexcolor"] = 1,
	})

	return rt, mat
end

function ZVox.NewRTMatPairPixelFuncAlpha(name, w, h, pixelFunc)
	local rt = GetRenderTarget("zvox_" .. name .. "_al_rt", w, h)
	if pixelFunc then
		ZVox.PixelFuncOnRT(rt, pixelFunc)
	end

	local mat = CreateMaterial("zvox_" .. name .. "_al_mat", "UnlitGeneric", {
		["$basetexture"] = rt:GetName(),
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1,
	})

	return rt, mat
end

function ZVox.NewMatFromRT(rt, name)
	local mat = CreateMaterial("zv_rtm_" .. name .. "_mat", "UnlitGeneric", {
		["$basetexture"] = rt:GetName(),
		["$vertexcolor"] = 1,
	})

	return mat
end