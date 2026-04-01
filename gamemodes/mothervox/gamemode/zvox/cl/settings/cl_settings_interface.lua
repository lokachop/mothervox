ZVox = ZVox or {}

local category = ZVox.NewSettingCategory("interface", {
	["fancyName"] = "Interface",
	["icon"] = "settings-interface",
})

ZVox.DeclareNewSetting("interface_blur", {
	["fancyName"] = "Enable Blur",
	["description"] = "Toggles blurring on the UI, can improve performance if off",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_UI_BLUR = state
	end
})

ZVox.DeclareNewSetting("interface_shadows", {
	["fancyName"] = "UI Shadows",
	["description"] = "Toggles drop shadows on the UI",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_UI_SHADOWS = state
	end
})

ZVox.DeclareNewSetting("interface_fast_mode", {
	["fancyName"] = "UI Fast Mode",
	["description"] = "Attempts to improve UI performance by disabling expensive blending, best if left off",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = false,
	["onChange"] = function(state)
		ZVOX_DO_UI_FASTMODE = state
	end
})

ZVox.DeclareNewSetting("interface_esc_close", {
	["fancyName"] = "ESC to close Escape Menu",
	["description"] = "Toggles ESC closing the escape menu, use SHIFT + ESC to go to the gmod one if on!",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_UI_ESC_CLOSE = state
	end
})

ZVox.DeclareNewSetting("interface_pause_blur", {
	["fancyName"] = "Enable Pause Menu Blur",
	["description"] = "Toggles blurring on the pause menu",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_PAUSE_BLUR = state
	end
})