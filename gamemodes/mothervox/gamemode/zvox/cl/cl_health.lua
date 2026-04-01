ZVox = ZVox or {}

-- t0 = 10
-- t1 = 17
-- t2 = 30
-- t3 = 50
-- t4 = 80
-- t5 = 120
-- t6 = 180
local currHealth = ZVox.Upgrades_GetMaxHullHealth()

function ZVox.Health_GetMaxHealthCanBuy()
	return ZVox.Upgrades_GetMaxHullHealth() - currHealth
end

function ZVox.Health_GetHealth()
	return currHealth
end

function ZVox.Health_GetHealthDelta()
	return (currHealth / ZVox.Upgrades_GetMaxHullHealth())
end

local function onPlayerDie()
	if ZVox.GetGamePaused() then
		return
	end

	ZVox.IncrementPauseStack()
	ZVox.SetActiveSong("sound/mothervox/music/core.ogg")
	surface.PlaySound("mothervox/sfx/vehicle/death.wav")
	ZVox.OpenDeathGUI()
end

local lastTookDamage = 0
local damageLen = 0.5
function ZVox.Health_RenderTakeDamage()
	if CurTime() > (lastTookDamage + damageLen) then
		return
	end

	local dmgDelta = (CurTime() - lastTookDamage) / damageLen
	dmgDelta = 1 - math.min(dmgDelta, 1)

	local whiteDelta = math.ease.InQuad(dmgDelta)

	surface.SetDrawColor(255, whiteDelta * 255, whiteDelta * 255, dmgDelta * 128)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function ZVox.Health_TakeDamage(dmg)
	currHealth = currHealth - dmg
	currHealth = math.max(currHealth, 0)

	if currHealth <= 0 then
		onPlayerDie()
	end

	lastTookDamage = CurTime()
	ZVox.DoScreenShake(dmg * 3, 0.5)
end


function ZVox.Health_SetHealth(newHealth)
	currHealth = math.min(newHealth, ZVox.Upgrades_GetMaxHullHealth())
end

function ZVox.Health_GainHealth(gain)
	currHealth = math.min(currHealth + gain, ZVox.Upgrades_GetMaxHullHealth())
end