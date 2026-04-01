ZVox = ZVox or {}

local dst = Vector(6.5, 17.5, 995.5)

local isTeleFlag = false
local lastDid = 0
local teleLen = 1.5
local colBlue = Color(64, 196, 255)
local nextCan = 0
ZVox.NewControlListener("item_quantum_tele", "qtele_use", function()
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	if ZVox.GetGamePaused() then
		return
	end

	local currCount = ZVox.Consumable_GetCurrentCount(MV_CONSUMABLE_QUANTUM_TELE)
	if currCount <= 0 then
		return
	end

	if nextCan > CurTime() then
		return
	end
	nextCan = CurTime() + 3


	surface.PlaySound("mothervox/sfx/consumables/quantum_tele.wav")
	ZVox.AddMinedPopup("Used Quantum Teleporter", colBlue)
	ZVox.SetTempPause(true)
	lastDid = CurTime()
	isTeleFlag = true


	timer.Simple(teleLen, function()
		isTeleFlag = false

		ZVox.IncrementPauseStack()
		ZVox.DecrementPauseStack()


		ZVox.SetPlayerPos(dst)
		ZVox.SetPlayerVel(Vector((math.random() - .5) * 960, (math.random() - .5) * 960, (math.random() - .5) * 960))
		ZVox.SetTempPause(false)
	end)
	ZVox.Consumable_SpendConsumable(MV_CONSUMABLE_QUANTUM_TELE)
end)

-- im gonna kill myself this is fucking stupid!
local mtxOut = Matrix()
function ZVox.TransformViewportQTele()
	local delta = ((lastDid + teleLen) - CurTime()) / teleLen
	delta = 1 - delta
	if delta >= 1 then
		if isTeleFlag then
			mtxOut:Identity()
			mtxOut:SetScale(Vector(0, 0, 0))
			return mtxOut
		end

		return
	end
	delta = delta * 1.25
	delta = math.min(delta, 1)

	local invDelta = 1 - delta
	local sclDelta = math.ease.OutSine(invDelta)

	local deltaRot = math.ease.InSine(delta)

	mtxOut:Identity()
	mtxOut:Translate(Vector(-ScrW() * .5, -ScrH() * .5, 0))
	mtxOut:Rotate(Angle(0, deltaRot * 360 * 2, 0))
	mtxOut:SetTranslation(Vector(ScrW() * .5, ScrH() * .5, 0))
	mtxOut:Translate(Vector(-ScrW() * .5 * sclDelta, -ScrH() * .5 * sclDelta, 0))
	mtxOut:SetScale(Vector(sclDelta, sclDelta, 1))

	return mtxOut
end

function ZVox.TintViewPortQTele()
	local delta = ((lastDid + teleLen) - CurTime()) / teleLen
	delta = 1 - delta
	if delta >= 1 then
		return
	end
	delta = delta * 1.25
	delta = math.min(delta, 1)

	local alphaDelta = math.ease.InExpo(delta)

	surface.SetDrawColor(24, 16, 128, alphaDelta * 255)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end