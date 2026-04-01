ZVox = ZVox or {}
-- Credited users for ZVox
-- Please don't remove/modify these

-- PRing something?
-- Add yourself here too!
-- TODO: actually make the credits nicer, not only contributors
-- we have to credit assets and libraries and other shit bla bla bla
-- crediting is nice...


local CAPE_DEV = "developer"
local CAPE_CONTRIBUTOR = "contributor"
local CAPE_TESTER = "tester"


local sortedCredits = {}
function ZVox.GetSortedCreditsList()
	return sortedCredits
end

function ZVox.GetCreditsCount()
	return #sortedCredits
end

local credits = {}
function ZVox.GetCreditsEntry(sID)
	return credits[sID]
end

function ZVox.NewCredit(sID, data)
	credits[sID] = {
		["name"] = data.name or "UNASSIGNED",
		["role"] = data.role or "Helpful",

		["nameColor"] = data.nameColor or Color(255, 255, 255),
		["allowedCapes"] = data.allowedCapes or {},
		["hidden"] = data.hidden or false,
		["nameForce"] = data.nameForce or false,
	}
	sortedCredits[#sortedCredits + 1] = sID

	if data.hidden then
		return
	end

	if SERVER then
		return
	end

	if data.nameForce then
		return
	end

	steamworks.RequestPlayerInfo(sID, function(steamName)
		if not credits[sID] then
			return
		end

		credits[sID].name = steamName
	end)
end

function ZVox.GetNametagSpecialColor(sID)
	if not credits[sID] then
		return
	end

	return credits[sID].nameColor
end

function ZVox.GetCapeAllowed(sID, cape)
	if not credits[sID] then
		return false
	end

	return credits[sID].allowedCapes[cape] and true or false
end

local function pastelify(color)
	local h, s, v = ColorToHSV(color)
	local cHsv = HSVToColor(h, math.min(s, .6), math.max(v, .6))

	return Color(cHsv.r, cHsv.g, cHsv.b) -- shit needs the metatable
end



ZVox.NewCredit("0", {
	["name"] = "Multirun Client",
	["role"] = "Multirun",

	["nameColor"] = Color(96 , 96 , 128),
	["allowedCapes"] = {
		[CAPE_DEV] = true,
		[CAPE_CONTRIBUTOR] = true,
		[CAPE_TESTER] = true,
	},
	["hidden"] = true,
})

-- Dev
ZVox.NewCredit("76561198274694254", {
	["name"] = "Lokachop",
	["role"] = "Main Developer",

	["nameColor"] = Color(96, 255, 128),
	["allowedCapes"] = {
		[CAPE_DEV] = true,
		[CAPE_CONTRIBUTOR] = true,
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561198205354737", {
	["name"] = "misname",
	["role"] = "Scugbranch Developer, Tester (and friend)",

	["nameColor"] = Color(255, 0, 255),
	["allowedCapes"] = {
		[CAPE_DEV] = true,
		[CAPE_CONTRIBUTOR] = true,
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561198181255502", {
	["name"] = "tuna",
	["role"] = "Moral support (while I was going insane) (and friend)",

	["nameColor"] = Color(140, 88, 43),
	["allowedCapes"] = {
		[CAPE_CONTRIBUTOR] = true,
		[CAPE_TESTER] = true,
	}
})


ZVox.NewCredit("76561199119236534", {
	["name"] = "IrradiatedRayne",
	["role"] = "Contributor, part & consumable icons (and friend)",

	["nameColor"] = Color(255, 0, 75),
	["allowedCapes"] = {
		[CAPE_CONTRIBUTOR] = true,
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561198116304797", {
	["name"] = "zynx",
	["role"] = "Former Developer (and friend)",

	["nameColor"] = Color(255, 103, 50),
	["allowedCapes"] = {
		[CAPE_DEV] = true,
		[CAPE_CONTRIBUTOR] = true,
		[CAPE_TESTER] = true,
	}
})



-- Awesome Friends & Contributors

ZVox.NewCredit("76561198056452663", {
	["name"] = "MISTER BONES",
	["role"] = "Early Tester (and friend), Ideas Guy Supreme",

	["nameColor"] = Color(0, 128, 128),
	["allowedCapes"] = {
		[CAPE_CONTRIBUTOR] = true, -- forgot he also contributed the sheetMetal textures and the steel frame
		[CAPE_TESTER] = true,
	}
})
ZVox.NewCredit("76561198315773241", {
	["name"] = "Lefton",
	["role"] = "Early Tester (and friend)",

	["nameColor"] = Color(96, 0, 0),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})
ZVox.NewCredit("76561198260232820", {
	["name"] = "Swedish Swede",
	["role"] = "Early Tester (and friend)",

	["nameColor"] = Color(0, 82, 147),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})
ZVox.NewCredit("76561198885421847", {
	["name"] = "opiper",
	["role"] = "Early Tester (and friend)",

	["nameColor"] = Color(196, 0, 255), -- color to be said, defaulting to purple for now
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561198118355002", {
	["name"] = "lord_arcness",
	["role"] = "Tester (and friend), Ideas Guy Delta",

	["nameColor"] = Color(255, 105, 180),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561198080012245", {
	["name"] = "Twatted",
	["role"] = "Tester, Friend =)",

	["nameColor"] = Color(255, 255, 0),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

-- Other code contributors
ZVox.NewCredit("76561198800701016", {
	["name"] = "AstalNeker",
	["role"] = "Frustrum culling code",

	["nameColor"] = Color(255, 255, 255), -- unpicked!
	["allowedCapes"] = {
		[CAPE_CONTRIBUTOR] = true,
	}
})

ZVox.NewCredit("76561197972053095", {
	["name"] = "Kaz",
	["role"] = "Faster pixel rendering method (via mesh. lib)", -- SADLY UNUSED =(
	-- shit is broken for some reason

	["nameColor"] = Color(141, 79, 255),
	["allowedCapes"] = {
		[CAPE_CONTRIBUTOR] = true,
	}
})



-- Public Playtest 1
-- Playtesters get pastelified colours
-- If you were in ANY pre-release playtests but are not on this list, let me know!
ZVox.NewCredit("76561198390278939", {
	["name"] = "ttmso",
	["role"] = "ZVox Public Playtest 1 Tester",

	["nameColor"] = pastelify(Color(0, 255, 0)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})
ZVox.NewCredit("76561198956876108", {
	["name"] = "clone124642",
	["role"] = "ZVox Public Playtest 1 Tester",

	["nameColor"] = pastelify(Color(255, 80, 0)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})
ZVox.NewCredit("76561198958726274", {
	["name"] = "bonyoze",
	["role"] = "ZVox Public Playtest 1 Tester",

	["nameColor"] = pastelify(Color(255, 0, 100)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})
ZVox.NewCredit("76561198032805852", {
	["name"] = "Frostwind",
	["role"] = "ZVox Public Playtest 1 Tester",

	["nameColor"] = pastelify(Color(137, 214, 255)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

-- Public Playtest 2
ZVox.NewCredit("76561198285380476", {
	["name"] = "Stargazer",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(252, 109, 255)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	},
	["nameForce"] = true, -- cyrillic causing issues with our font again, sorry! =(
})

ZVox.NewCredit("76561199216053120", {
	["name"] = "FZ8",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(0, 255, 166)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561199080608661", {
	["name"] = "Purple Guy",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(255, 255, 255)), -- unpicked yet
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561198090247166", {
	["name"] = "alexbo",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(255, 0, 0)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	},
	["nameForce"] = true, -- cyrillic characters don't play well with the retrotext font renderer
})

ZVox.NewCredit("76561198219838701", {
	["name"] = "mooN boY",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(255, 0, 225)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561199098250825", {
	["name"] = "xn",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(70, 140, 152)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561199000853154", {
	["name"] = "Cast_e",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(-999999, -999999, 0)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561198367278639", {
	["name"] = "Mikey",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(52, 192, 235)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})

ZVox.NewCredit("76561198390576907", {
	["name"] = "Meetric",
	["role"] = "ZVox Public Playtest 2 Tester",

	["nameColor"] = pastelify(Color(196, 0, 255)),
	["allowedCapes"] = {
		[CAPE_TESTER] = true,
	}
})