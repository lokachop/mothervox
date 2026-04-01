ZVox = ZVox or {}

local mesh = mesh
local mesh_Begin = mesh.Begin
local mesh_Position = mesh.Position
local mesh_Normal = mesh.Normal
local mesh_TexCoord = mesh.TexCoord
local mesh_Color = mesh.Color
local mesh_AdvanceVertex = mesh.AdvanceVertex
local mesh_End = mesh.End


local STAR_COUNT = 2048

-- i had to look at LK3D code for this
-- oh god
local function pushStar(dir, rot, sz, col)
	local ang = dir:Angle() + Angle(0, 0, rot)

	local rightCalc = ang:Right() * sz
	local upCalc = ang:Up() * sz

	local posOrigin = dir

	local r, g, b, a = col.r, col.g, col.b, col.a


	mesh_Color(r, g, b, a)
	mesh_Position(posOrigin - rightCalc + upCalc)
	mesh_TexCoord(0, 0, 1)
	mesh_AdvanceVertex()

	mesh_Color(r, g, b, a)
	mesh_Position(posOrigin + rightCalc + upCalc)
	mesh_TexCoord(0, 1, 1)
	mesh_AdvanceVertex()

	mesh_Color(r, g, b, a)
	mesh_Position(posOrigin + rightCalc - upCalc)
	mesh_TexCoord(0, 1, 0)
	mesh_AdvanceVertex()

	mesh_Color(r, g, b, a)
	mesh_Position(posOrigin - rightCalc - upCalc)
	mesh_TexCoord(0, 0, 0)
	mesh_AdvanceVertex()
end



local randAccum = 0
local function consistentRandom()
	randAccum = randAccum + 1

	return util.SharedRandom("zvox_sky", 0, 1, randAccum) -- thanks to bonyoze for reminding me this func exists
end



function ZVox.GetStarMesh(dirPow)
	local meshObj = Mesh()

	mesh_Begin(meshObj, MATERIAL_QUADS, STAR_COUNT)
	for i = 1, STAR_COUNT do
		-- former bad grouped dir calc
		--local dir = Vector((math.random() * 2) - 1, (math.random() * 2) - 1, (math.random() * 2) - 1)
		--dir:Normalize()


		local u = consistentRandom() --math.random()
		local v = consistentRandom() --math.random()

		local theta = 2 * math.pi * u
		local z = 2 * v - 1
		local r = math.sqrt(1 - z * z) -- grouping correction

		local x = r * math.cos(theta)
		local y = r * math.sin(theta)

		local dir = Vector(x, y, z)

		dir = dir * dirPow


		local rot = consistentRandom() * 360
		local sz = .05 + (math.abs(math.log(consistentRandom(), 16)) * .06)

		local colSaturation = consistentRandom() * .25

		local colAlpha = 48 + consistentRandom() * 180

		local colOrigin = -170
		local colSpread = 170 + 50
		local colHue = colOrigin + (consistentRandom() * colSpread)

		--colHue = colOrigin


		local col = HSVToColor(colHue % 360, colSaturation, 1)

		col.a = colAlpha

		pushStar(dir, rot, sz, col)
	end
	mesh_End()



	return meshObj
end