ZVox = ZVox or {}

local dst = Vector(4.2, 9.5, 993.5)


local isTeleFlag = false
local lastDid = 0
local teleLen = 1.5
local colBlue = Color(64, 196, 255)
local nextCan = 0
ZVox.NewControlListener("item_matter_transmitter", "mtrans_use", function()
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	if ZVox.GetGamePaused() then
		return
	end

	local currCount = ZVox.Consumable_GetCurrentCount(MV_CONSUMABLE_MATTER_TRANSMITTER)
	if currCount <= 0 then
		return
	end

	if nextCan > CurTime() then
		return
	end
	nextCan = CurTime() + 3


	surface.PlaySound("mothervox/sfx/consumables/mattertrans.wav")
	ZVox.AddMinedPopup("Used Matter Transmitter", colBlue)
	ZVox.SetTempPause(true)
	lastDid = CurTime()
	isTeleFlag = true


	timer.Simple(teleLen, function()
		isTeleFlag = false

		ZVox.IncrementPauseStack()
		ZVox.DecrementPauseStack()


		ZVox.SetPlayerPos(dst)
		ZVox.SetPlayerVel(Vector(0, 0, 0))
		ZVox.SetTempPause(false)
	end)
	ZVox.Consumable_SpendConsumable(MV_CONSUMABLE_MATTER_TRANSMITTER)
end)

-- im gonna kill myself this is fucking stupid!
local mtxOut = Matrix()
function ZVox.TransformViewportMTrans()
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

	local sclDelta2 = math.ease.OutExpo(invDelta)

	mtxOut:Identity()
	mtxOut:Translate(Vector((ScrW() * .5) * (1 - sclDelta2), (ScrH() * .5) * (1 - sclDelta), 0))
	mtxOut:SetScale(Vector(sclDelta2, sclDelta, 1))

	return mtxOut
end

function ZVox.TintViewPortMTrans()
	local delta = ((lastDid + teleLen) - CurTime()) / teleLen
	delta = 1 - delta
	if delta >= 1 then
		return
	end
	delta = delta * 1.25
	delta = math.min(delta, 1)

	local alphaDelta = math.ease.InExpo(delta)

	surface.SetDrawColor(96, 16, 128, alphaDelta * 255)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end