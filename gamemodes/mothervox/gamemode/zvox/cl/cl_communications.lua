ZVox = ZVox or {}


ZVox.CommunicationFlags = ZVox.CommunicationFlags or 0x0

local function flagComm(tier)
	ZVox.CommunicationFlags = bit.bor(ZVox.CommunicationFlags, tier)
end

local function isCommFlagged(tier)
	return bit.band(ZVox.CommunicationFlags, tier) ~= 0
end


function ZVox.CommunicationsThink()
	if ZVox.GetState() ~= ZVOX_STATE_INGAME then
		return
	end

	if not isCommFlagged(MV_COMMUNICATION_WELCOME) and ZVox.GetPlayerGrounded() and not ZVox.IsPlayerDigging() then
		flagComm(MV_COMMUNICATION_WELCOME)

		ZVox.OpenCommunication("Mr. Nahtanoj", {
			"We forgot to refuel you on the",
			"way over! Drive over to the",
			"fuel station (marked with a sign)",
			"and fill 'er up!",
			"",
			"It's been almost impossible to",
			"hire decent miners on mars",
			"since all the strange activity",
			"started happening around here.",
			"That's why we're willing to pay",
			"you at a premium for your services!",
			"I've given you a basic mining",
			"machine to get started with.",
			"Unfortunately, you'll be on",
			"your own from this point onward",
			"as the settlers who were lucky",
			"to escape with their lives",
			"have fled to safety. However,",
			"all of the shops here have been",
			"computerized, so you'll still be",
			"able to sell your minerals,",
			"fuel up, upgrade your pod, and",
			"buy special items.",
			"Remember - your job is to collect",
			"minerals and bring them back to",
			"the surface for processing.",
			"The deeper you dig, the more",
			"valuable minerals you'll encounter.",
			"",
			"Don't forget to refuel.",
			"Good luck!"
		})
	end

	local plyZ = ZVox.GetPlayerPos()[3]


	if (plyZ < 900) and not isCommFlagged(MV_COMMUNICATION_900M) and ZVox.GetPlayerGrounded() and not ZVox.IsPlayerDigging() then
		flagComm(MV_COMMUNICATION_900M)

		ZVox.Money_GainMoney(1000)
		ZVox.OpenCommunication("Mr. Nahtanoj", {
			"Good going so far.",
			"I'll be sending you a bonus of",
			"$ 1000 for your hard work.",
			"",
			"Remember to upgrade your mining",
			"machine at the vendors, as it'll",
			"only get more dangerous the",
			"lower you start getting."
		})
	end

	if (plyZ < 800) and not isCommFlagged(MV_COMMUNICATION_800M) and ZVox.GetPlayerGrounded() and not ZVox.IsPlayerDigging() then
		flagComm(MV_COMMUNICATION_800M)

		ZVox.Money_GainMoney(2000)
		ZVox.OpenCommunication("Mr. Nahtanoj", {
			"Here's another bonus for your",
			"hard work, $ 2000 this time.",
			"",
			"Oh yeah, remember to be careful",
			"when landing with the mining",
			"machine, as it is not rated",
			"for any fall faster than 9m/s!",
		})
	end

	if (plyZ < 600) and not isCommFlagged(MV_COMMUNICATION_600M) and ZVox.GetPlayerGrounded() and not ZVox.IsPlayerDigging() then
		flagComm(MV_COMMUNICATION_600M)

		ZVox.Money_GainMoney(10000)
		ZVox.OpenCommunication("Mr. Nahtanoj", {
			"Another bonus has been sent to",
			"your account for your hard work.",
			"",
			"Should you get hurt and or die,",
			"the insurance you signed when",
			"signing up means that we'll send",
			"a team to dispose of your corpse",
			"with whatever option you have",
			"marked us to do.",
			"",
			"Oh yeah, if you come across",
			"any rocks, you should check out",
			"the consumable vendor to get",
			"dynamite that can blow them up.",
		})
	end

	if (plyZ < 400) and not isCommFlagged(MV_COMMUNICATION_400M) and ZVox.GetPlayerGrounded() and not ZVox.IsPlayerDigging() then
		flagComm(MV_COMMUNICATION_400M)

		ZVox.Money_GainMoney(20000)
		ZVox.OpenCommunication("Mr. Nahtanoj", {
			"You've been at this for longer",
			"than we expected!",
			"I've sent you another bonus of",
			"$ 20000 as a sign of gratitude.",
			"",
			"Oh yeah, you should be careful",
			"of the magma deposits that build",
			"up at these altitudes, you should",
			"probably upgrade your radiator."
		})
	end

	if (plyZ < 200) and not isCommFlagged(MV_COMMUNICATION_200M) and ZVox.GetPlayerGrounded() and not ZVox.IsPlayerDigging() then
		flagComm(MV_COMMUNICATION_200M)

		ZVox.Money_GainMoney(100000)
		ZVox.OpenCommunication("Mr. Nahtanoj", {
			"Oh, yeah.",
			"I shoulda brought this up earlier.",
			"",
			"We would REALLY appreciate it if",
			"you could dispose of a certain",
			"unobtainalum deposit situated",
			"on an old facility of ours near",
			"the bedrock layer.",
			"",
			"Worry not, it poses no harm to you",
			"so long as you follow our instructions",
			"for now, I've sent you a bonus of $ 100000",
			"to incentivize you to keep going down."
		})
	end

	if (plyZ < 50) and not isCommFlagged(MV_COMMUNICATION_50M) and ZVox.GetPlayerGrounded() and not ZVox.IsPlayerDigging() then
		flagComm(MV_COMMUNICATION_50M)

		ZVox.Money_GainMoney(200000)
		ZVox.OpenCommunication("Mr. Nahtanoj", {
			"Right, you're approaching the",
			"facility.",
			"",
			"If our previous scans are correct",
			"it should be located directly below",
			"the fuel vendor.",
			"",
			"Here's a bonus of $ 200000.",
			"",
			"We believe in you."
		})
	end
end