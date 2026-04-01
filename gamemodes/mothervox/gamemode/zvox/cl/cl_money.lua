ZVox = ZVox or {}

ZVox.CurrentMoney = ZVox.CurrentMoney or 20
function ZVox.Money_SetMoney(money)
	ZVox.CurrentMoney = money
end

function ZVox.Money_GetCurrentMoney()
	return ZVox.CurrentMoney
end

function ZVox.Money_GainMoney(money)
	ZVox.CurrentMoney = ZVox.CurrentMoney + money
end

function ZVox.Money_CanAfford(money)
	return ZVox.CurrentMoney >= money
end

function ZVox.Money_SpendMoney(money)
	money = math.floor(money)
	if money == 0 then
		return
	end

	if not ZVox.Money_CanAfford(money) then
		return false
	end

	ZVox.CurrentMoney = ZVox.CurrentMoney - money
	return true
end