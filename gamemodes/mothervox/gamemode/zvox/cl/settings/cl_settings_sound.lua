ZVox = ZVox or {}

local category = ZVox.NewSettingCategory("sound", {
	["fancyName"] = "Sound",
	["icon"] = "settings-sound",
})

ZVox.DeclareNewSetting("sound_music_volume", {
	["fancyName"] = "Music Volume",
	["description"] = "Controls how loud the music is",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY,

	["default"] = 50,
	["min"] = 0,
	["max"] = 200,

	["onChange"] = function(state)
		ZVOX_MUSIC_VOLUME = state
		ZVox.UpdateSongVolume()
	end
})

ZVox.DeclareNewSetting("sound_vehicle_volume", {
	["fancyName"] = "Vehicle Volume",
	["description"] = "Controls how loud the vehicle is",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY,

	["default"] = 50,
	["min"] = 0,
	["max"] = 200,

	["onChange"] = function(state)
		ZVOX_VEHICLE_VOLUME = state
		ZVox.UpdateVehicleVolume()
	end
})