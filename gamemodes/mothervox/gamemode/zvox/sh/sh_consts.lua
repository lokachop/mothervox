ZVox = ZVox or {}

-- "changelog" here before it is properly added
-- [ v0.6 ]
-- | initial logged ver
-- | early futuremesher, no culling
-- | commit c0f21f8 to 06d0d44
-- |---------
-- | start: c0f21f8ae61e8367de544f76943393566080858c
-- | end:   06d0d44e6d7146910947a5116ff44b5a7fb4786a
-- |---------
-- [ v0.7 ]
-- | futuremesher still indev
-- | a bunch of voxel func name refactors
-- | refactors to internal project structure
-- | commmit 06d0d44 to 6e28175
-- |---------
-- | start: 06d0d44e6d7146910947a5116ff44b5a7fb4786a
-- | end:   6e2817515b02bc025603e66a3909c6a2d5524de9
-- |---------
-- [ v0.8 ]
-- | futuremesher finished, start of addon API
-- | texturepacks
-- | serialization refactored, ids 255 -> 268435455
-- | atlas size increased, ids 256 -> 1024
-- | luals & documentation
-- | ????
-- | commmit 6e28175 to ???
-- |---------
-- | start: 6e2817515b02bc025603e66a3909c6a2d5524de9
-- | end:   ???
-- |---------


ZVOX_VERSION = "MotherVox 1.0.0"
ZVOX_DEVMODE = false -- devmode hides / shows dev settings
ZVOX_DO_LOGGING = true -- logging to file, really slow since it flushes each message
-- we leave it on in hopes of catching the weird crash bugs

ZVOX_CHUNKSIZE_X = 8
ZVOX_CHUNKSIZE_Y = 8
ZVOX_CHUNKSIZE_Z = 8

ZVOX_CHUNKSIZE_XY = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y
ZVOX_CHUNKSIZE_XYZ = ZVOX_CHUNKSIZE_X * ZVOX_CHUNKSIZE_Y * ZVOX_CHUNKSIZE_Z


ZVOX_VOXELGROUP_SOLID = 1
ZVOX_VOXELGROUP_BINARY_TRANSPARENCY = 2
ZVOX_VOXELGROUP_TRANSLUCENT = 3
ZVOX_VOXELGROUP_WATER = 4 -- special group for water


ZVOX_VOXELCATEGORY_NATURE = 1
ZVOX_VOXELCATEGORY_TERRAIN = 2
ZVOX_VOXELCATEGORY_BUILDINGBLOCKS = 3
ZVOX_VOXELCATEGORY_ABSTRACT = 4
ZVOX_VOXELCATEGORY_METALLIC = 5
ZVOX_VOXELCATEGORY_NUMBER = 6
ZVOX_VOXELCATEGORY_UNKNOWN = 7


ZVOX_MAT_CLOTH = 1
ZVOX_MAT_GLASS = 2 -- stone placing sound
ZVOX_MAT_GRASS = 3
ZVOX_MAT_GRAVEL = 4
ZVOX_MAT_SAND = 5
ZVOX_MAT_SNOW = 6
ZVOX_MAT_STONE = 7
ZVOX_MAT_WOOD = 8
ZVOX_MAT_METAL = 9 -- pitched up stone
ZVOX_MAT_WATER = 10
ZVOX_MAT_ETHEREALSTONE = 11

-- TODO: properly handle these
PRINTLEVEL_DEBUG = 0 -- ALL prints even spammy ones
PRINTLEVEL_DEV = 1 -- ALL but spammy prints (ex. mesher, render errors)
PRINTLEVEL_SHIPPING = 2 -- Only minor info general ones, ex. onstart prints about voxel count and limits
ZVox.PrintLevel = PRINTLEVEL_DEV -- Set to PRINTLEVEL_SHIPPING when on a public build!


ZVOX_PLAYERSTATUS_UPDATE_WAIT = .1 -- .1s between player status updates, THIS IS INTERPOLATED
ZVOX_MOVEMENT_TPS = 1 / 30 -- 30tps movement

-- SAVING STUFF
ZVOX_PROGRESSIVE_ENCODE_FINISHED = 2
ZVOX_PROGRESSIVE_ENCODE_CONTINUE = 1



ZVOX_ENCODE_OK = 1
ZVOX_ENCODE_ERR = 0

ZVOX_DECODE_OK = 1
ZVOX_DECODE_ERR = 0

ZVOX_AUTOSAVE_INTERVAL = 60 * 3 -- 3 mins
ZVOX_AUTOSAVE_WORLDNAME = "mothervox"


ZVOX_ENCODER_MAXVERSION = 0 -- this auto gets switched
ZVOX_ENCODER_LIST = {} -- this gets filled automatically, lookup table [encoderVer] = ENCODER table
-- ENCODER table:
-- {
-- 	["name"] = "Src:EncoderName"
-- 	["progressive"] = bool progressive
-- 	["encodeFunc"] = if progressive, function(fPtr, univObj, persistData) else function(fPtr, univObj, fileName)
-- }

ZVOX_ENCODER_VER_OVERRIDE = nil -- set to a version to force an encoder

ZVOX_DECODER_LIST = {} -- this gets filled automatically, lookup table of what file format versions we can decode with their DECODER table
-- DECODER table:
-- {
-- 	["name"] = "Src:DecoderName"
-- 	["decodeFunc"] = function(fPtr, univTargetName)
-- }


-- weather
ZVOX_WEATHER_CLEAR = 0
ZVOX_WEATHER_RAIN = 1
ZVOX_WEATHER_STORM = 2

-- owner
ZVOX_OWNER_SERVER = "-1"


ZVOX_TEX_X_PLUS  = 1
ZVOX_TEX_X_MINUS = 2
ZVOX_TEX_Y_PLUS  = 3
ZVOX_TEX_Y_MINUS = 4
ZVOX_TEX_Z_PLUS  = 5
ZVOX_TEX_Z_MINUS = 6

-- used for raycasts to ignore water
ZVOX_COLLISION_GROUP_SOLID = 1
ZVOX_COLLISION_GROUP_WATER = 2
ZVOX_COLLISION_GROUP_GLASS = 4

ZVOX_COLLISION_GROUP_ALL_BUT_WATER = ZVOX_COLLISION_GROUP_SOLID + ZVOX_COLLISION_GROUP_GLASS


-- action enums
ZVOX_ACTION_FIELD_LONG = 1
ZVOX_ACTION_FIELD_ULONG = 2

ZVOX_ACTION_FIELD_SHORT = 3
ZVOX_ACTION_FIELD_USHORT = 4

ZVOX_ACTION_FIELD_FLOAT = 5
ZVOX_ACTION_FIELD_DOUBLE = 6

ZVOX_ACTION_FIELD_BOOLEAN = 7

ZVOX_ACTION_FIELD_STRING = 8
ZVOX_ACTION_FIELD_DATA = 9
ZVOX_ACTION_FIELD_VECTOR = 10 -- try to not use this

MOTHERVOX_ALLOWED_CAN_BREAK_BLOCKS = {
	["zvox:grass"] = true,
	["zvox:dirt"] = true,
	["zvox:coal_ore"] = true,
	["zvox:copper_ore"] = true,
	["zvox:iron_ore"] = true,
	["zvox:silver_ore"] = true,
	["zvox:gold_ore"] = true,
	["zvox:diamond_ore"] = true,
	["zvox:uranium_ore"] = true,
	["zvox:voidinium_ore"] = true,
	["zvox:temporalium_ore"] = true,
	["zvox:magma"] = true,
	["zvox:unobtainalum"] = true,
}

MOTHERVOX_SCANNABLE_BLOCKS = {
	["zvox:coal_ore"] = true,
	["zvox:copper_ore"] = true,
	["zvox:iron_ore"] = true,
	["zvox:silver_ore"] = true,
	["zvox:gold_ore"] = true,
	["zvox:diamond_ore"] = true,
	["zvox:uranium_ore"] = true,
	["zvox:voidinium_ore"] = true,
	["zvox:temporalium_ore"] = true,
}

MOTHERVOX_SCANNABLE_COLOURS = {
	["zvox:coal_ore"] = Color(12, 12, 12),
	["zvox:copper_ore"] = Color(156, 48, 12),
	["zvox:iron_ore"] = Color(156, 136, 120),
	["zvox:silver_ore"] = Color(156, 156, 188),
	["zvox:gold_ore"] = Color(198, 164, 38),
	["zvox:diamond_ore"] = Color(88, 202, 204),
	["zvox:uranium_ore"] = Color(24, 121, 24),
	["zvox:voidinium_ore"] = Color(255, 0, 68),
	["zvox:temporalium_ore"] = Color(128, 32, 255),
}

MOTHERVOX_ALLOWED_CAN_EXPLODE_BLOCKS = {
	["zvox:grass"] = true,
	["zvox:dirt"] = true,
	["zvox:coal_ore"] = true,
	["zvox:copper_ore"] = true,
	["zvox:iron_ore"] = true,
	["zvox:silver_ore"] = true,
	["zvox:gold_ore"] = true,
	["zvox:diamond_ore"] = true,
	["zvox:uranium_ore"] = true,
	["zvox:voidinium_ore"] = true,
	["zvox:temporalium_ore"] = true,
	["zvox:magma"] = true,
	["zvox:rock_dirt"] = true,
}

MOTHERVOX_ALLOWED_CAN_INTERACT_BLOCKS = {
	["zvox:mothervox_shop_ore"] = true,
	["zvox:mothervox_shop_fuel"] = true,
	["zvox:mothervox_shop_parts"] = true,
	["zvox:mothervox_shop_consumables"] = true,
}