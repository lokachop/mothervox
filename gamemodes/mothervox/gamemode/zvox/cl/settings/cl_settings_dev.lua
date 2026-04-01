ZVox = ZVox or {}

local category = ZVox.NewSettingCategory("dev", {
	["fancyName"] = "Dev",
	["icon"] = "settings-dev",
	["devOnly"] = true,
})

ZVox.DeclareNewSetting("dev_refresh_state_refresh", {
	["fancyName"] = "State refresh on lua refresh",
	["description"] = "Enables / disables refreshing the state on lua refresh",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_STATE_REFRESH_ON_LUA_REFRESH = state
	end
})

ZVox.DeclareNewSetting("dev_frustrumcull_freeze", {
	["fancyName"] = "Freeze Frustum Culling",
	["description"] = "Freezes frustrum culling on the last state",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = false,
	["onChange"] = function(state)
		ZVOX_DO_FRUSTRUM_CULLING_FREEZE = state
	end
})

ZVox.DeclareNewSetting("dev_clamp_player_pos", {
	["fancyName"] = "Clamp Player Pos",
	["description"] = "Clamps the position of the player to the universe size",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_CLAMP_PLAYER_POS = state
	end
})

ZVox.DeclareNewSetting("dev_draw_collision_searcher_results", {
	["fancyName"] = "Draw Collision Searcher AABBs",
	["description"] = "Whether to draw the collision searcher AABBs (what you collide with) while on debugdraw mode",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = false,
	["onChange"] = function(state)
		ZVOX_DEBUGDRAW_COLLISIONS = state
	end
})