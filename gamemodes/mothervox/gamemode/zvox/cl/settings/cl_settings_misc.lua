ZVox = ZVox or {}

local category = ZVox.NewSettingCategory("misc", {
	["fancyName"] = "Misc",
	["icon"] = "settings-misc",
})

ZVox.DeclareNewSetting("misc_enable_textures", {
	["fancyName"] = "Enable Texturing",
	["description"] = "Enables / disables texturing, best to keep on",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_TEXTURES = state
	end
})

ZVox.DeclareNewSetting("misc_mc_fov", {
	["fancyName"] = "Minecraft FoV Calculation",
	["description"] = "Calculates the FoV based on your vertical screen height, more similar to minecraft (supposedly)",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_MC_FOV_CALC = state
	end
})

ZVox.DeclareNewSetting("misc_remeshes_per_frame", {
	["fancyName"] = "Remeshes Per Frame",
	["description"] = "How many chunks should we remesh per frame, best to leave at 1",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY,

	["default"] = 1,
	["min"] = 1,
	["max"] = 4,
	["onChange"] = function(state)
		ZVOX_MAX_REMESH_PER_FRAME = state
	end
})

ZVox.DeclareNewSetting("misc_remesher_hurry_treshold", {
	["fancyName"] = "Remesher Hurry Treshold",
	["description"] = "With how many remeshes left should we enable hurry mode, best to leave at 64",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY,

	["default"] = 64,
	["min"] = 32,
	["max"] = 512,
	["onChange"] = function(state)
		ZVOX_REMESH_HURRY_THRESHOLD = state
	end
})

ZVox.DeclareNewSetting("misc_remeshes_per_frame_hurry", {
	["fancyName"] = "Remeshes Per Frame on Hurry",
	["description"] = "How many chunks should we remesh per frame while we are on hurry mode, best to leave at 8",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY,

	["default"] = 8,
	["min"] = 1,
	["max"] = 32,
	["onChange"] = function(state)
		ZVOX_MAX_REMESH_PER_FRAME_HURRY = state
	end
})

ZVox.DeclareNewSetting("misc_larger_primitive_count", {
	["fancyName"] = "Larger mesher primitive count",
	["description"] = "Can improve performance but causes crashes on older GMod versions",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
	end
})


ZVox.DeclareNewSetting("misc_screen_shake", {
	["fancyName"] = "Enable screen shake",
	["description"] = "Toggles whether the screenshake actually applies or not.",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_SCREEN_SHAKE = state
	end
})