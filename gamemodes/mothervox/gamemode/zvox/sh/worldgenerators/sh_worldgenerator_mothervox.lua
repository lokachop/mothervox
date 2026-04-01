ZVox = ZVox or {}
local WORLDGEN = ZVox.DeclareNewWorldGenerator("mothervox", {
	["author"] = "Lokachop",
	["fancyname"] = "MotherVox",
	["description"] = "You shouldn't see this.",
}) --[[@as worldgenerator]]

WORLDGEN:AddStage("generate", {
	["stagetype"] = ZVOX_WORLDGEN_STAGE_TYPE_SETTER,
	["callback"] = function(x, y, z)
		if z == 0 then
			return "zvox:bedrock"
		end

		if z == 992 then
			return "zvox:grass"
		end

		if z < 992 then
			local scl = 0.195
			local scl2 = 0.185
			local worleyVal = ZVox.Worley3D(x * scl, y * scl, z * scl2, 35123)
			if (worleyVal > .65) then
				return "zvox:air"
			end

			return "zvox:dirt"
		end

		return "zvox:air"
	end
})




local function orePopulator(idealZ, tolerance, sz, prob, x, y, z, seed, toleranceHard)
	local toleranceDelta = math.abs(z - idealZ) / tolerance
	toleranceDelta = 1 - math.min(toleranceDelta, 1)

	if toleranceHard then
		if toleranceDelta < 0 then
			return false
		end

		toleranceDelta = 1
	end

	local val = (ZVox.Perlin3D(x * sz + seed * 845, y * sz + seed * 24, z * sz + seed * 74) + 1) / 2

	return val > (1 - (prob * toleranceDelta))
end

WORLDGEN:AddStage("populate_ores", {
	["stagetype"] = ZVOX_WORLDGEN_STAGE_TYPE_EXCHANGER,
	["callback"] = function(x, y, z, voxName)
		if voxName ~= "zvox:dirt" then
			return
		end

		-- Coal
		if orePopulator(992, 200, 0.45, 0.285, x, y, z, 234623) then
			return "zvox:coal_ore"
		end

		-- Copper
		if orePopulator(892, 300, 0.45, 0.235, x, y, z, 53473) then
			return "zvox:copper_ore"
		end

		-- Iron
		if orePopulator(742, 700, 0.55, 0.205, x, y, z, 785689) then
			return "zvox:iron_ore"
		end
		if orePopulator(342, 600, 0.55, 0.185, x, y, z, 867934) then
			return "zvox:iron_ore"
		end

		-- Silver
		if orePopulator(692, 400, 0.55, 0.185, x, y, z, 658965) then
			return "zvox:silver_ore"
		end
		if orePopulator(492, 400, 0.55, 0.185, x, y, z, 658965) then
			return "zvox:silver_ore"
		end


		-- Gold
		if orePopulator(392, 300, 0.52, 0.195, x, y, z, 456858) then
			return "zvox:gold_ore"
		end
		if orePopulator(292, 300, 0.52, 0.195, x, y, z, 456858) then
			return "zvox:gold_ore"
		end
		if orePopulator(192, 300, 0.52, 0.195, x, y, z, 456858) then
			return "zvox:gold_ore"
		end

		-- Diamond
		if orePopulator(292, 400, 0.62, 0.185, x, y, z, 85645645) then
			return "zvox:diamond_ore"
		end
		if orePopulator(192, 400, 0.62, 0.185, x, y, z, 85645645) then
			return "zvox:diamond_ore"
		end

		-- Uranium
		if orePopulator(92, 400, 0.52, 0.185, x, y, z, 47856786) then
			return "zvox:uranium_ore"
		end

		-- Voidinium
		if orePopulator(252, 400, 0.52, 0.155, x, y, z, 85636) then
			return "zvox:voidinium_ore"
		end

		-- Temporalium
		if orePopulator(0, 300, 0.42, 0.185, x, y, z, 2345456) then
			return "zvox:temporalium_ore"
		end

		-- Rocks
		if orePopulator(492, 400, 0.35, 0.235, x, y, z, 75688345) then
			return "zvox:rock_dirt"
		end
		if orePopulator(292, 400, 0.35, 0.235, x, y, z, 75688345) then
			return "zvox:rock_dirt"
		end
		if orePopulator(92, 400, 0.35, 0.235, x, y, z, 75688345) then
			return "zvox:rock_dirt"
		end

		-- Magma
		if orePopulator(150, 300, 0.52, 0.245, x, y, z, 7856745) then
			return "zvox:magma"
		end
		if orePopulator(50, 300, 0.52, 0.245, x, y, z, 7856745) then
			return "zvox:magma"
		end
	end
})