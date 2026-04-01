ZVox = ZVox or {}

local category = ZVox.NewSettingCategory("graphics", {
	["fancyName"] = "Graphics",
	["icon"] = "settings-graphics",
})


-- graphics settings that don't have a place
ZVox.DeclareNewSetting("graphics_ao", {
	["fancyName"] = "Smooth Lighting",
	["description"] = "Enables / disables the smooth lighting, can improve performance by a large amount",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_AO = state and true or false

		local plyUniv = ZVox.GetActiveUniverse()
		if not plyUniv then
			return
		end

		ZVox.RemeshUniv(plyUniv, true)
	end
})

ZVox.DeclareNewSetting("graphics_smooth_clouds", {
	["fancyName"] = "Smooth Clouds",
	["description"] = "Enables / disables linear filtering on the clouds, making them look smoother",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_SMOOTH_CLOUDS = state and true or false
	end
})

ZVox.DeclareNewSetting("graphics_single_pass_glass", {
	["fancyName"] = "Single Pass Glass",
	["description"] = "Whether to fix overdraw issues with glass at a performance cost or not, on is faster but buggier",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_SINGLE_PASS_GLASS = state
	end
})

ZVox.DeclareNewSetting("graphics_frustrum_culling", {
	["fancyName"] = "Frustrum Culling",
	["description"] = "On should improve performance but can lower performance on CPU-bound systems",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_FRUSTRUM_CULLING = state and true or false
	end
})

ZVox.DeclareNewSetting("graphics_particles", {
	["fancyName"] = "Render Particles",
	["description"] = "Enables / disables particle rendering / updates",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_PARTICLES = state and true or false

		ZVox.ClearAllParticles()
	end
})


ZVox.DeclareNewSetting("graphics_particle_type", {
	["fancyName"] = "Particle Collision Type",
	["description"] = "Defines if an how particles should collide with the terrain",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_COMBO,

	["options"] = {
		"off",
		"fast",
		"expensive",
	},

	["default"] = "expensive",
	["onChange"] = function(state)
		if state == "expensive" then
			ZVOX_DO_PARTICLE_COLLISIONS = true
			ZVOX_DO_PARTICLE_EXPENSIVE_COLLISIONS = true
		elseif state == "fast" then
			ZVOX_DO_PARTICLE_COLLISIONS = true
			ZVOX_DO_PARTICLE_EXPENSIVE_COLLISIONS = false
		elseif state == "off" then
			ZVOX_DO_PARTICLE_COLLISIONS = false
			ZVOX_DO_PARTICLE_EXPENSIVE_COLLISIONS = false
		end
	end
})

ZVox.DeclareNewSetting("graphics_particle_max", {
	["fancyName"] = "Max Particle Count",
	["description"] = "The maximum number of active particles, more lagspikes the higher it is",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY,

	["default"] = 384,
	["min"] = 0,
	["max"] = 512,

	["onChange"] = function(state)
		ZVOX_MAX_PARTICLE_COUNT = state
	end
})

ZVox.DeclareNewSetting("graphics_do_animated_textures", {
	["fancyName"] = "Enable Animated Textures",
	["description"] = "Toggles animated textures actually being animated, probably doesn't improve framerate TOO much",

	["category"] = category,
	["selector"] = ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX,

	["default"] = true,
	["onChange"] = function(state)
		ZVOX_DO_ANIMATED_TEXTURES = state
	end
})