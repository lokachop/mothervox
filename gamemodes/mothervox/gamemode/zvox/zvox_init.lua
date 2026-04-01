ZVox = ZVox or {}
local colText = Color(220, 220, 220)
local colRealm = CLIENT and Color(255, 128, 0) or Color(0, 128, 255)
MsgC(colRealm, "[ZVox] ", colText, "Initializing on " .. (SERVER and "server..." or "client..."), "\n")

-- this codebase documents my descent into insanity for the past ~1.5 years
-- I (Lokachop) apologize to anyone who is reading this
-- MotherVox is the april fools branch of ZVox, for 2026
-- as of writing, it is the first time anything ZVox-based will see the light of day
-- MotherVox is built onto a HEAVILY trimmed down build of ZVox 0.8
-- I advice anyone who wants to work with ZVox to wait for upstream ZVox to eventually release
-- or to ask me for a copy of it, although it should release somewhat soon
-- upstream ZVox is still in development, but will be available somewhat soon
-- the current ZVox changelog is available in sh/sh_consts.lua as a comment
-- also if anyone that I know is reading this, let me know! (i would like to know how many people actually read these)


local _prefix = ""
function ZVox.LoadFile(path)
	local prefix = string.match(path, "^([^/]*)/.*")

	local f_sh = prefix == "sh"
	local f_sv = prefix == "sv"
	local f_cl = prefix == "cl"

	if SERVER and not f_sv then
		AddCSLuaFile(_prefix .. path)
	end

	if f_sh then
		include(_prefix .. path)
	elseif f_sv and SERVER then
		include(_prefix .. path)
	elseif f_cl and CLIENT then
		include(_prefix .. path)
	end
end

-- shared init
ZVox.LoadFile("sh/sh_consts.lua")

ZVox.LoadFile("sh/sh_logging.lua")
ZVox.LoadFile("sh/sh_filebuffer.lua")
ZVox.LoadFile("sh/sh_printing.lua")
ZVox.LoadFile("sh/sh_namespaces.lua")


ZVox.LoadFile("sh/sh_noise.lua")
ZVox.LoadFile("sh/sh_util.lua")
ZVox.LoadFile("sh/sh_png_parse.lua")
ZVox.LoadFile("sh/sh_markup.lua")
ZVox.LoadFile("sh/voxels/sh_voxelstates.lua")


-- voxelmodels
-- the model format from blockbench
-- we don't use blockstate files, blockstates are declared on voxel declaration!!
ZVox.NAMESPACES_SetActiveNamespace("zvox")
ZVox.LoadFile("sh/voxelmodels/sh_voxelmodels.lua")
ZVox.LoadFile("sh/voxelmodels/sh_vmdl_cube_all.lua")
ZVox.LoadFile("sh/voxelmodels/sh_vmdl_cube_dir.lua")

-- random rot
ZVox.LoadFile("sh/voxelmodels/randomrot/sh_vmdl_randomrot_all.lua")
ZVox.LoadFile("sh/voxelmodels/randomrot/sh_vmdl_randomrot_zplus.lua")

-- stair
ZVox.LoadFile("sh/voxelmodels/stairs/sh_vmdl_stair_x_plus.lua")
ZVox.LoadFile("sh/voxelmodels/stairs/sh_vmdl_stair_x_minus.lua")
ZVox.LoadFile("sh/voxelmodels/stairs/sh_vmdl_stair_y_plus.lua")
ZVox.LoadFile("sh/voxelmodels/stairs/sh_vmdl_stair_y_minus.lua")

-- slab
ZVox.LoadFile("sh/voxelmodels/slabs/sh_vmdl_slab_lower.lua")
ZVox.LoadFile("sh/voxelmodels/slabs/sh_vmdl_slab_upper.lua")

-- zrot
ZVox.LoadFile("sh/voxelmodels/zrot/sh_vmdl_zrot_x_plus.lua")
ZVox.LoadFile("sh/voxelmodels/zrot/sh_vmdl_zrot_x_minus.lua")
ZVox.LoadFile("sh/voxelmodels/zrot/sh_vmdl_zrot_y_plus.lua")
ZVox.LoadFile("sh/voxelmodels/zrot/sh_vmdl_zrot_y_minus.lua")

-- logrot
ZVox.LoadFile("sh/voxelmodels/logrot/sh_vmdl_logrot_x.lua")
ZVox.LoadFile("sh/voxelmodels/logrot/sh_vmdl_logrot_y.lua")
ZVox.LoadFile("sh/voxelmodels/logrot/sh_vmdl_logrot_z.lua")

-- voxels
ZVox.LoadFile("sh/voxels/sh_voxels_express_voxelinfo.lua")
ZVox.LoadFile("sh/voxels/sh_voxels.lua")
ZVox.LoadFile("sh/voxels/types/sh_voxels_nature.lua")
ZVox.LoadFile("sh/voxels/types/sh_voxels_pumpkin.lua")
ZVox.LoadFile("sh/voxels/types/sh_voxels_stone.lua")
ZVox.LoadFile("sh/voxels/types/sh_voxels_wood.lua")
ZVox.LoadFile("sh/voxels/types/sh_voxels_wool.lua")
ZVox.LoadFile("sh/voxels/types/sh_voxels_metallic.lua")
ZVox.LoadFile("sh/voxels/types/sh_voxels_crystal.lua")
ZVox.LoadFile("sh/voxels/types/sh_voxels_abstract.lua")

ZVox.VoxelDonePrint()

ZVox.LoadFile("sh/universes/sh_chunk.lua")
ZVox.LoadFile("sh/universes/sh_plusdata.lua")
ZVox.LoadFile("sh/universes/plusdata/sh_plusdata_default.lua")


ZVox.LoadFile("sh/universes/sh_universes.lua")

-- worldgen
ZVox.LoadFile("sh/worldgenerators/sh_worldgenerators.lua")
ZVox.LoadFile("sh/worldgenerators/sh_worldgenerator_mothervox.lua")

-- physics
-- these are the ClassiCube ones ported from C to lua!
ZVox.LoadFile("sh/physics/sh_raycast.lua")
ZVox.LoadFile("sh/physics/sh_physics_object.lua")
ZVox.LoadFile("sh/physics/sh_physics_aabb.lua")
ZVox.LoadFile("sh/physics/sh_physics_searcher.lua")
ZVox.LoadFile("sh/physics/sh_physics_collide.lua")


ZVox.LoadFile("sh/universes/sh_serialize.lua")
ZVox.LoadFile("sh/sh_skintags.lua")
ZVox.LoadFile("sh/sh_credits.lua")


ZVox.LoadFile("sh/actions/sh_actions.lua")
ZVox.LoadFile("sh/actions/sh_actions_default.lua")
ZVox.LoadFile("sh/actions/sh_actions_bigedit.lua")

ZVox.LoadFile("sh/sh_netutils.lua")

ZVox.LoadFile("sh/saves/sh_save_voxel_conversion.lua")

ZVox.LoadFile("sh/saves/decoders/sh_decoder_v1.lua")
ZVox.LoadFile("sh/saves/decoders/sh_decoder_v2.lua")
ZVox.LoadFile("sh/saves/decoders/sh_decoder_v3.lua")

ZVox.LoadFile("sh/saves/encoders/sh_encoder_v1.lua")
ZVox.LoadFile("sh/saves/encoders/sh_encoder_v2.lua")
ZVox.LoadFile("sh/saves/encoders/sh_encoder_v3.lua")

ZVox.LoadFile("sh/saves/sh_univsaving.lua")
ZVox.LoadFile("sh/saves/sh_univloading.lua")

ZVox.LoadFile("sh/buildtemplates/sh_buildtemplates.lua")
-- thse for mothervox
ZVox.LoadFile("sh/buildtemplates/buildings/sh_bt_buildings.lua")


ZVox.LoadFile("sh/sh_hooks.lua")

ZVox.LoadFile("sh/final/sh_final_id_shift_check.lua")

-- sv init
--if SERVER then
	ZVox.LoadFile("sv/sv_addfile.lua")
	ZVox.LoadFile("sv/sv_consts.lua")
	ZVox.LoadFile("sv/sv_util.lua")

	ZVox.LoadFile("sv/sv_chunk_transmit.lua")
	ZVox.LoadFile("sv/sv_universe_transmit.lua")

	ZVox.LoadFile("sv/player/sv_player_registry.lua")
	ZVox.LoadFile("sv/sv_player_transmit.lua")

	ZVox.LoadFile("sv/sv_save_queries.lua")

	ZVox.LoadFile("sv/sv_net.lua")
	ZVox.LoadFile("sv/sv_hooks.lua")
	ZVox.LoadFile("sv/final/sv_final_load_mainuniv.lua")
--end

-- cl init
--if CLIENT then
	-- settings first to make sure listeners are applied
	ZVox.LoadFile("cl/settings/cl_settings.lua")

	-- controls then, since everything else needs them
	ZVox.LoadFile("cl/controls/cl_controls.lua")
	ZVox.LoadFile("cl/controls/cl_controls_default.lua")

	ZVox.LoadFile("cl/cl_consts.lua")
	ZVox.LoadFile("cl/cl_rt.lua")

	ZVox.LoadFile("cl/cl_colorutils.lua")
	ZVox.LoadFile("cl/cl_renderutils.lua")

	ZVox.LoadFile("cl/font/cl_font_render.lua")

	-- camera mode F1
	ZVox.LoadFile("cl/cl_cameramode.lua")

	ZVox.LoadFile("cl/cl_music.lua")


	ZVox.LoadFile("cl/textures/cl_textures.lua")
	ZVox.LoadFile("cl/textures/cl_animated_textures.lua")
	ZVox.LoadFile("cl/textures/texutils/cl_texutils_line.lua")

	ZVox.LoadFile("cl/textures/cl_textures_number.lua")
	ZVox.LoadFile("cl/textures/cl_textures_debug.lua")
	ZVox.LoadFile("cl/textures/cl_textures_nature.lua")
	ZVox.LoadFile("cl/textures/cl_textures_stone.lua")
	ZVox.LoadFile("cl/textures/cl_textures_brick.lua")
	ZVox.LoadFile("cl/textures/cl_textures_wool.lua")
	ZVox.LoadFile("cl/textures/cl_textures_wood.lua")
	ZVox.LoadFile("cl/textures/cl_textures_metal.lua")
	ZVox.LoadFile("cl/textures/cl_textures_abstract.lua")
	ZVox.LoadFile("cl/textures/cl_textures_pumpkin.lua")
	ZVox.LoadFile("cl/textures/cl_textures_crystal.lua")

	ZVox.LoadFile("cl/textures/cl_textures_final.lua")


	ZVox.LoadFile("cl/cl_voxelgroups.lua")

	ZVox.LoadFile("cl/voxelstates/cl_voxelstate_handler.lua")
	ZVox.LoadFile("cl/voxelstates/cl_voxelstate_type_zrot.lua")
	ZVox.LoadFile("cl/voxelstates/cl_voxelstate_type_logrot.lua")
	ZVox.LoadFile("cl/voxelstates/cl_voxelstate_type_slab.lua")

	-- MeshUtils
	ZVox.LoadFile("cl/meshutils/cl_meshutils_plane.lua")
	ZVox.LoadFile("cl/meshutils/cl_meshutils_cube.lua")
	ZVox.LoadFile("cl/meshutils/cl_meshutils_sphere.lua")
	ZVox.LoadFile("cl/meshutils/cl_meshutils_line.lua")
	ZVox.LoadFile("cl/meshutils/cl_meshutils_stars.lua")
	ZVox.LoadFile("cl/meshutils/cl_meshutils_voxelmodel.lua")

	-- Frustrum Culling
	ZVox.LoadFile("cl/cl_frustrum_culling.lua")

	-- mesher
	ZVox.LoadFile("cl/mesher/cl_mesher_fastqueries.lua")
	ZVox.LoadFile("cl/mesher/cl_mesher_culling.lua")
	ZVox.LoadFile("cl/mesher/cl_mesher_lighting_v2.lua")
	ZVox.LoadFile("cl/mesher/cl_mesher_v2.lua")

	ZVox.LoadFile("cl/cl_icons.lua")

	ZVox.LoadFile("cl/upgrades/cl_upgrades.lua")
	ZVox.LoadFile("cl/upgrades/parts/cl_upgrades_drill.lua")
	ZVox.LoadFile("cl/upgrades/parts/cl_upgrades_hull.lua")
	ZVox.LoadFile("cl/upgrades/parts/cl_upgrades_engine.lua")
	ZVox.LoadFile("cl/upgrades/parts/cl_upgrades_fuel_tank.lua")
	ZVox.LoadFile("cl/upgrades/parts/cl_upgrades_radiator.lua")
	ZVox.LoadFile("cl/upgrades/parts/cl_upgrades_storage_bay.lua")
	ZVox.LoadFile("cl/upgrades/parts/cl_upgrades_sensor.lua")

	ZVox.LoadFile("cl/consumables/cl_consumables.lua")
	ZVox.LoadFile("cl/consumables/types/cl_consumables_c4.lua")
	ZVox.LoadFile("cl/consumables/types/cl_consumables_dynamite.lua")
	ZVox.LoadFile("cl/consumables/types/cl_consumables_fuel_tank.lua")
	ZVox.LoadFile("cl/consumables/types/cl_consumables_matter_transmitter.lua")
	ZVox.LoadFile("cl/consumables/types/cl_consumables_nanodrones.lua")
	ZVox.LoadFile("cl/consumables/types/cl_consumables_quantum_tele.lua")


	ZVox.LoadFile("cl/cl_health.lua")
	ZVox.LoadFile("cl/cl_fuel.lua")
	ZVox.LoadFile("cl/cl_storage.lua")
	ZVox.LoadFile("cl/cl_money.lua")
	ZVox.LoadFile("cl/cl_scanner.lua")

	ZVox.LoadFile("cl/inventory/cl_hotbar.lua")
	ZVox.LoadFile("cl/inventory/cl_inventory_v1.lua")
	ZVox.LoadFile("cl/inventory/cl_inventory_v2.lua")
	ZVox.LoadFile("cl/inventory/cl_inventory_mothervox.lua")
	ZVox.LoadFile("cl/inventory/cl_inventory.lua")


	ZVox.LoadFile("cl/ending/cl_sound_unobtainalum.lua")
	ZVox.LoadFile("cl/ending/cl_render_unobtainalum.lua")

	ZVox.LoadFile("cl/cl_camera.lua")
	ZVox.LoadFile("cl/cl_debugdraw.lua")

	ZVox.LoadFile("cl/cl_viewmodel.lua")

	ZVox.LoadFile("cl/cl_crosshair.lua")
	ZVox.LoadFile("cl/cl_voxelhighlight.lua")
	ZVox.LoadFile("cl/cl_screenshake.lua")

	ZVox.LoadFile("cl/cl_saving.lua")


	ZVox.LoadFile("cl/render/cl_fog.lua")
	ZVox.LoadFile("cl/render/cl_day_and_night.lua")
	ZVox.LoadFile("cl/render/cl_particles.lua")
	ZVox.LoadFile("cl/render/cl_sky.lua")
	ZVox.LoadFile("cl/render/cl_lens_flare.lua")
	ZVox.LoadFile("cl/render/cl_render.lua")

	-- helper concommands

	ZVox.LoadFile("cl/cl_sound.lua")

	ZVox.LoadFile("cl/cl_connection.lua")

	ZVox.LoadFile("cl/cl_actions.lua")
	ZVox.LoadFile("cl/cl_actionbuffer.lua")

	ZVox.LoadFile("cl/cl_ui.lua")
	ZVox.LoadFile("cl/cl_pause.lua")

	ZVox.LoadFile("cl/voxels/hooks/cl_voxel_interact.lua")
	ZVox.LoadFile("cl/voxels/hooks/default/cl_interactions_vendors.lua")

	ZVox.LoadFile("cl/voxels/hooks/cl_voxel_dig.lua")
	ZVox.LoadFile("cl/voxels/hooks/default/cl_dig_voxels.lua")

	-- Player
	ZVox.LoadFile("cl/player/cl_player_struct.lua")
	ZVox.LoadFile("cl/player/cl_player_eyetrace.lua")
	ZVox.LoadFile("cl/player/cl_player_movement_walk.lua")
	ZVox.LoadFile("cl/player/cl_player_movement_noclip.lua")

	ZVox.LoadFile("cl/player/cl_player_interaction.lua")
	ZVox.LoadFile("cl/player/cl_player_hooks.lua")

	-- States
	ZVox.LoadFile("cl/states/cl_states.lua")
	ZVox.LoadFile("cl/states/cl_state_mainmenu.lua")
	ZVox.LoadFile("cl/states/cl_state_loading.lua")
	ZVox.LoadFile("cl/states/cl_state_ingame.lua")
	ZVox.LoadFile("cl/states/cl_state_ending.lua")

	ZVox.LoadFile("cl/cl_hooks.lua")
	ZVox.LoadFile("cl/cl_net.lua")


	ZVox.LoadFile("cl/cl_concommands.lua")
	ZVox.LoadFile("cl/cl_communications.lua")


	-- setting types, we load settings early for setting listeners
	ZVox.LoadFile("cl/settings/cl_settings_graphics.lua")
	ZVox.LoadFile("cl/settings/cl_settings_sound.lua")
	ZVox.LoadFile("cl/settings/cl_settings_interface.lua")
	ZVox.LoadFile("cl/settings/cl_settings_fun.lua")
	ZVox.LoadFile("cl/settings/cl_settings_misc.lua")
	ZVox.LoadFile("cl/settings/cl_settings_dev.lua")


	-- GUI LAST, declare ZVUI
	-- since i like how tgui looks on ss13, i'm going to try to make zvui look similar
	ZVUI = ZVUI or {}
	ZVox.LoadFile("cl/gui/zvui/cl_zvui_fonts.lua")
	ZVox.LoadFile("cl/gui/zvui/cl_zvui_icongen.lua")
	ZVox.LoadFile("cl/gui/zvui/cl_zvui_util.lua")

	-- custom panels
	-- basic ones
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dframe.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dbutton.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dswitchbutton.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dcheckbox.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dscrollpanel.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_fancy_dpanel.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dtab.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dpropertysheet.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dnumberwang.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dmenu.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/primitive/cl_zvui_dcombobox.lua")


	-- credits
	ZVox.LoadFile("cl/gui/zvui/elements/credits/cl_zvui_plycredit_panel.lua")

	-- settings
	ZVox.LoadFile("cl/gui/zvui/elements/settings/cl_zvui_control_header_panel.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/settings/cl_zvui_control_panel.lua")
	ZVox.LoadFile("cl/gui/zvui/elements/settings/cl_zvui_setting_panel.lua")

	-- mothervox shit
	ZVox.LoadFile("cl/gui/zvui/elements_mothervox/cl_mainmenu_button.lua")
	ZVox.LoadFile("cl/gui/mothervox/cl_gui_ore_vendor.lua")
	ZVox.LoadFile("cl/gui/mothervox/cl_gui_fuel_vendor.lua")
	ZVox.LoadFile("cl/gui/mothervox/cl_gui_part_vendor.lua")
	ZVox.LoadFile("cl/gui/mothervox/cl_gui_consumable_vendor.lua")
	ZVox.LoadFile("cl/gui/mothervox/cl_gui_communication.lua")

	ZVox.LoadFile("cl/gui/cl_gui_load_screen.lua")
	ZVox.LoadFile("cl/gui/cl_gui_credits.lua")
	ZVox.LoadFile("cl/gui/cl_gui_settings.lua")
	ZVox.LoadFile("cl/gui/cl_gui_alert.lua")
	ZVox.LoadFile("cl/gui/cl_gui_death.lua")
	ZVox.LoadFile("cl/gui/cl_gui_confirm_prompt.lua")

	-- warnings for stupid players to tell them to not be stupid
	ZVox.LoadFile("cl/gui/cl_gui_wrong_branch_warn.lua")


	ZVox.LoadFile("cl/gui/cl_gui_escape_menu.lua")


	-- and finally, cl final init
	ZVox.LoadFile("cl/cl_final_init.lua")
--end