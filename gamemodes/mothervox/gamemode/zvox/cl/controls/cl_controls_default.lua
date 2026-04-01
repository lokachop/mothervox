ZVox = ZVox or {}

-- Camera
ZVox.DeclareNewControl("cam_hide", {
	["key"] = KEY_F1,
	["cat"] = "Camera",
	["fancyName"] = "Toggle Interface",
})

-- Interaction
ZVox.DeclareNewControl("int_break", {
	["key"] = MOUSE_LEFT,
	["cat"] = "Interaction",
	["fancyName"] = "Dig Block",
})

-- Interface / Inventory
ZVox.DeclareNewControl("inv_show", {
	["key"] = KEY_E,
	["cat"] = "Inventory",
	["fancyName"] = "Toggle Inventory",
	["withCursor"] = true,
})

-- Movement
ZVox.DeclareNewControl("move_forward", {
	["key"] = KEY_W,
	["cat"] = "Movement",
	["fancyName"] = "Walk Forward",
})

ZVox.DeclareNewControl("move_backward", {
	["key"] = KEY_S,
	["cat"] = "Movement",
	["fancyName"] = "Walk Backwards",
})

ZVox.DeclareNewControl("move_left", {
	["key"] = KEY_A,
	["cat"] = "Movement",
	["fancyName"] = "Walk Left",
})

ZVox.DeclareNewControl("move_right", {
	["key"] = KEY_D,
	["cat"] = "Movement",
	["fancyName"] = "Walk Right",
})

ZVox.DeclareNewControl("move_up", {
	["key"] = KEY_SPACE,
	["cat"] = "Movement",
	["fancyName"] = "Jump / Fly Up",
})

ZVox.DeclareNewControl("move_down", {
	["key"] = KEY_LSHIFT,
	["cat"] = "Movement",
	["fancyName"] = "Fly Down",
})

ZVox.DeclareNewControl("move_sprint", {
	["key"] = KEY_LCONTROL,
	["cat"] = "Movement",
	["fancyName"] = "Fly Fast Mode",
})

-- mothervox items
ZVox.DeclareNewControl("item_fuel_tank", {
	["key"] = KEY_F,
	["cat"] = "Items",
	["fancyName"] = "Reserve Fuel Tank",
})

ZVox.DeclareNewControl("item_nanobots", {
	["key"] = KEY_R,
	["cat"] = "Items",
	["fancyName"] = "Hull Repair Nanobots",
})

ZVox.DeclareNewControl("item_dynamite", {
	["key"] = KEY_X,
	["cat"] = "Items",
	["fancyName"] = "Dynamite",
})

ZVox.DeclareNewControl("item_c4", {
	["key"] = KEY_C,
	["cat"] = "Items",
	["fancyName"] = "Plastic Explosive",
})

ZVox.DeclareNewControl("item_quantum_tele", {
	["key"] = KEY_Q,
	["cat"] = "Items",
	["fancyName"] = "Quantum Teleporter",
})

ZVox.DeclareNewControl("item_matter_transmitter", {
	["key"] = KEY_M,
	["cat"] = "Items",
	["fancyName"] = "Matter Transmitter",
})


-- debug
ZVox.DeclareNewControl("dbg_toggle_remeshing", {
	["key"] = KEY_PAD_9,
	["cat"] = "Debug",
	["fancyName"] = "Toggle Remeshing",
})

ZVox.DeclareNewControl("dbg_noclip", {
	["key"] = KEY_V,
	["cat"] = "Debug",
	["fancyName"] = "Toggle Noclip",
})

ZVox.DeclareNewControl("cam_debug", {
	["key"] = KEY_F3,
	["cat"] = "Debug",
	["fancyName"] = "Toggle Debug UI",
})


ZVox.DeclareNewControl("int_place", {
	["key"] = MOUSE_RIGHT,
	["cat"] = "DebugInteraction",
	["fancyName"] = "Place Block",
})

ZVox.DeclareNewControl("int_copy", {
	["key"] = MOUSE_MIDDLE,
	["cat"] = "DebugInteraction",
	["fancyName"] = "Copy Block",
})

for i = 1, 9 do
	local keyIdx = KEY_1 + (i - 1)

	ZVox.DeclareNewControl("inv_switch_" .. i, {
		["key"] = keyIdx,
		["cat"] = "DebugInteraction",
		["fancyName"] = "Switch to voxel " .. i,
	})
end
