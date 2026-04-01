ZVox = ZVox or {}

local category = ZVox.NewSettingCategory("fun", {
	["fancyName"] = "Fun",
	["icon"] = "settings-fun",
})

ZVox.DeclareNewSetting("fun_roblox_clone_graphics", {
	["fancyName"] = "Roblox Minecraft Clone Mode",
	["description"] = "Makes ZVox look like a cheap roblox minecraft clone",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = false,
	["onChange"] = function(state)
		if state then
			ZVOX_FILTERMODE = TEXFILTER.LINEAR
		else
			ZVOX_FILTERMODE = TEXFILTER.POINT
		end
	end
})

ZVox.DeclareNewSetting("fun_lowres_viewport", {
	["fancyName"] = "Low Resolution Viewport",
	["description"] = "Downscales the viewport, making it look pixelated",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = false,
	["onChange"] = function(state)
		ZVOX_DO_LOWRES_VIEWPORT = state
	end
})

ZVox.DeclareNewSetting("fun_lens_flare", {
	["fancyName"] = "Sun Lens Flare",
	["description"] = "I devved this for fun, it sucks...",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = false,
	["onChange"] = function(state)
		ZVOX_DO_LENS_FLARE = state
	end
})