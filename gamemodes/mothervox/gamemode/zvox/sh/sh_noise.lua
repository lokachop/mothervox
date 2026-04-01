ZVox = ZVox or {}


-- https://github.com/WardBenjamin/SimplexNoise/blob/master/SimplexNoise/Noise.cs
local simplex_permutations = {
	151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36,
	103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0,
	26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56,
	87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
	77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55,
	46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132,
	187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109,
	198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126,
	255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183,
	170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
	172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112,
	104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162,
	241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106,
	157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205,
	93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180,

	151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36,
	103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0,
	26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56,
	87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
	77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55,
	46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132,
	187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109,
	198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126,
	255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183,
	170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
	172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112,
	104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162,
	241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106,
	157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205,
	93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
}

local simplex_f2 = .5 * (math.sqrt(3) - 1)
local simplex_g2 = (3 - math.sqrt(3)) / 6
local function simplex_grad2D(seed, x, y)
	local h = bit.band(seed, 7)      -- Convert low 3 bits of hash code
	local u = h < 4 and x or y  -- into 8 simple gradient directions,
	local v = h < 4 and y or x  -- and compute the dot product with (x,y).
	return (bit.band(h, 1) ~= 0 and -u or u) + (bit.band(h, 2) ~= 0 and -2.0 * v or 2.0 * v)
end
local function simplex_mod(x, m)
	local a = x % m;
	return a < 0 and a + m or a;
end

function ZVox.Simplex2D(x, y, seed)
	local n0, n1, n2 = 0, 0, 0

	local s = (x + y) * simplex_f2
	local xs = x + s
	local ys = y + s

	local i = math.floor(xs)
	local j = math.floor(ys)


	local t = (i + j) * simplex_g2

	local X0 = i - t -- Unskew the cell origin back to (x,y) space
	local Y0 = j - t

	local x0 = x - X0 -- The x,y distances from the cell origin
	local y0 = y - Y0

	-- For the 2D case, the simplex shape is an equilateral triangle.
	-- Determine which simplex we are in.
	local i1, j1 -- Offsets for second (middle) corner of simplex in (i,j) coords
	if x0 > y0 then -- lower triangle, XY order: (0,0)->(1,0)->(1,1)
		i1 = 1
		j1 = 0
	else -- upper triangle, YX order: (0,0)->(0,1)->(1,1)
		i1 = 0
		j1 = 1
	end

	-- A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
	-- a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
	-- c = (3-sqrt(3))/6

	local x1 = x0 - i1 + simplex_g2 -- Offsets for middle corner in (x,y) unskewed coords
	local y1 = y0 - j1 + simplex_g2
	local x2 = x0 - 1.0 + 2.0 * simplex_g2 -- Offsets for last corner in (x,y) unskewed coords
	local y2 = y0 - 1.0 + 2.0 * simplex_g2

	-- Wrap the integer indices at 256, to avoid indexing perm[] out of bounds
	local ii = simplex_mod(i, 255) + 1
	local jj = simplex_mod(j, 255) + 1

	-- Calculate the contribution from the three corners
	local t0 = 0.5 - x0 * x0 - y0 * y0
	if t0 < 0 then
		n0 = 0
	else
		t0 = t0 * t0
		n0 = t0 * t0 * simplex_grad2D(simplex_permutations[ii + simplex_permutations[jj]], x0, y0)
	end

	local t1 = 0.5 - x1 * x1 - y1 * y1
	if t1 < 0 then
		n1 = 0
	else
		t1 = t1 * t1
		n1 = t1 * t1 * simplex_grad2D(simplex_permutations[ii + i1 + simplex_permutations[jj + j1]], x1, y1)
	end

	local t2 = 0.5 - x2 * x2 - y2 * y2
	if t2 < 0 then
		n2 = 0
	else
		t2 = t2 * t2
		n2 = t2 * t2 * simplex_grad2D(simplex_permutations[ii + 1 + simplex_permutations[jj + 1]], x2, y2)
	end

	-- Add contributions from each corner to get the final noise value.
	-- The result is scaled to return values in the interval [-1,1].
	return 40 * (n0 + n1 + n2) -- TODO: The scale factor is preliminary!
end

local perlin_permutations = {
	151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36,
	103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0,
	26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56,
	87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
	77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55,
	46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132,
	187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109,
	198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126,
	255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183,
	170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
	172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112,
	104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162,
	241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106,
	157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205,
	93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
}

local function perlin_randomGradient(x, y, seed)
	local rnd = perlin_permutations[(((x * 5453764) + (y * 56263) + (seed or 0)) % 256) + 1] % 256
	rnd = rnd / 256
	return Vector(math.sin(rnd), math.cos(rnd))
end

local function perlin_dotGridGradient(ix, iy, x, y, seed)
	local grad = perlin_randomGradient(ix, iy, seed)
	return ((x - ix) * grad[1]) + ((y - iy) * grad[2])
end

function ZVox.Perlin2D(x, y, seed)
	local x0, y0 = math.floor(x), math.floor(y)
	local x1, y1 = x0 + 1, y0 + 1

	local sx, sy = x - x0, y - y0


	local n0 = perlin_dotGridGradient(x0, y0, x, y, seed)
	local n1 = perlin_dotGridGradient(x1, y0, x, y, seed)
	local ix0 = Lerp(sx, n0, n1)

	n0 = perlin_dotGridGradient(x0, y1, x, y, seed)
	n1 = perlin_dotGridGradient(x1, y1, x, y, seed)
	local ix1 = Lerp(sx, n0, n1)

	return Lerp(sy, ix0, ix1)
end


-- https://thebookofshaders.com/12/
local function worley_v_f2(v)
	return Vector(math.floor(v[1]), math.floor(v[2]))
end
local function worley_v_fract2(v)
	return Vector(v[1] - math.floor(v[1]), v[2] - math.floor(v[2]))
end

local function worley_v_s2(v)
	return Vector(math.sin(v[1]), math.sin(v[2]))
end

local function worley_random2(p)
	return worley_v_fract2(worley_v_s2(Vector(p:Dot(Vector(127.1,311.7)), p:Dot(Vector(269.5, 183.3)))) * 43758.5453)
end

function ZVox.Worley2D(x, y, seed, distFunc, circleDistMul)
	local m_dist = 1
	local st = Vector(x + (seed or 0), y + (seed or 0))

	local i_st = worley_v_f2(st)
	local f_st = worley_v_fract2(st)
	local ttl = (3 * 3) - 1
	for i = 0, ttl do
		local xc = (i % 3) - 1
		local yc = math.floor(i / 3) - 1
		if not xc or not yc then
			return 100
		end

		local neighbor = Vector(xc, yc)

		local point = worley_random2(i_st + neighbor) * (circleDistMul or 1)

		local diff = neighbor + point - f_st

		if distFunc then
			local fine, dist = pcall(distFunc, neighbor + point, f_st)

			if fine then
				m_dist = math.min(m_dist, dist)
			end
		else
			m_dist = math.min(m_dist, diff:Length())
		end
	end
	return m_dist
end




-- we have 3 of these, I know.
-- I'll fix it eventually, I just don't want to risk differences in noisegen
local permWorley3D = {
	151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36,
	103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0,
	26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56,
	87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
	77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55,
	46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132,
	187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109,
	198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126,
	255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183,
	170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
	172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112,
	104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162,
	241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106,
	157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205,
	93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180,
}

local function wrapWorley3DPerm(x)
	return (x % #permWorley3D) + 1
end

local function sampleWorley3DPerm(idx)
	return permWorley3D[(idx % #permWorley3D) + 1]
end

local function sampleWorley3DPerm3Sample(idxX, idxY, idxZ)
	--idxX = (idxX % #permWorley3D) + 1
	--idxY = (idxY % #permWorley3D) + 1
	--idxZ = (idxZ % #permWorley3D) + 1

	--idxCalc = permWorley3D[idxX]

	return permWorley3D[wrapWorley3DPerm(idxZ + permWorley3D[wrapWorley3DPerm(idxY + permWorley3D[wrapWorley3DPerm(idxX)])])]
end

local function fract(x)
	return x - math.floor(x)
end

local WORLEY3D_OFFSET_F = {-0.5, 0.5, 1.5}
local WORLEY3D_K = 1.0 / 7.0
local WORLEY3D_KO = 3.0 / 7.0

local function distance3Worley3D(p1x, p1y, p1z, p2x, p2y, p2z)
	return (p1x - p2x) * (p1x - p2x) + (p1y - p2y) * (p1y - p2y) + (p1z - p2z) * (p1z - p2z)
end

-- https://github.com/Scrawk/Procedural-Noise/blob/master/Assets/ProceduralNoise/Noise/WorleyNoise.cs
function ZVox.Worley3D(x, y, z, seed, jitter, distFunc)
	seed = seed or 0
	jitter = jitter or 1
	distFunc = distFunc or distance3Worley3D

	local pi0 = math.floor(x)
	local pi1 = math.floor(y)
	local pi2 = math.floor(z)

	local pf0 = fract(x)
	local pf1 = fract(y)
	local pf2 = fract(z)

	local pX = {
		sampleWorley3DPerm(pi0 - 1 + seed),
		sampleWorley3DPerm(pi0 + seed),
		sampleWorley3DPerm(pi0 + 1 + seed),
	}

	local pY = {
		sampleWorley3DPerm(pi1 - 1 + seed),
		sampleWorley3DPerm(pi1 + seed),
		sampleWorley3DPerm(pi1 + 1 + seed),
	}

	local d0, d1, d2
	local F0 = 1e6
	local F1 = 1e6
	local F2 = 1e6

	local px, py, pz
	local oxx, oxy, oxz
	local oyx, oyy, oyz
	local ozx, ozy, ozz

	for i = 1, 3 do
		for j = 1, 3 do
			px = sampleWorley3DPerm3Sample(pX[i], pY[j], pi2 - 1)
			py = sampleWorley3DPerm3Sample(pX[i], pY[j], pi2)
			pz = sampleWorley3DPerm3Sample(pX[i], pY[j], pi2 + 1)

			oxx = fract(px * WORLEY3D_K) - WORLEY3D_KO
			oxy = fract(py * WORLEY3D_K) - WORLEY3D_KO
			oxz = fract(pz * WORLEY3D_K) - WORLEY3D_KO

			oyx = (math.floor(px * WORLEY3D_K) % 7.0) * WORLEY3D_K - WORLEY3D_KO
			oyy = (math.floor(py * WORLEY3D_K) % 7.0) * WORLEY3D_K - WORLEY3D_KO
			oyz = (math.floor(pz * WORLEY3D_K) % 7.0) * WORLEY3D_K - WORLEY3D_KO

			px = sampleWorley3DPerm(px)
			py = sampleWorley3DPerm(py)
			pz = sampleWorley3DPerm(pz)

			ozx = fract(px * WORLEY3D_K) - WORLEY3D_KO
			ozy = fract(py * WORLEY3D_K) - WORLEY3D_KO
			ozz = fract(pz * WORLEY3D_K) - WORLEY3D_KO

			d0 = distFunc(pf0, pf1, pf2, WORLEY3D_OFFSET_F[i] + jitter * oxx, WORLEY3D_OFFSET_F[j] + jitter * oyx, -0.5 + jitter * ozx)
			d1 = distFunc(pf0, pf1, pf2, WORLEY3D_OFFSET_F[i] + jitter * oxy, WORLEY3D_OFFSET_F[j] + jitter * oyy, 0.5 + jitter * ozy)
			d2 = distFunc(pf0, pf1, pf2, WORLEY3D_OFFSET_F[i] + jitter * oxz, WORLEY3D_OFFSET_F[j] + jitter * oyz, 1.5 + jitter * ozz)

			if (d0 < F0) then
				F2 = F1
				F1 = F0
				F0 = d0
			elseif (d0 < F1) then
				F2 = F1
				F1 = d0
			elseif (d0 < F2) then
				F2 = d0
			end

			if (d1 < F0) then
				F2 = F1
				F1 = F0
				F0 = d1
			elseif (d1 < F1) then
				F2 = F1
				F1 = d1
			elseif (d1 < F2) then
				F2 = d1
			end

			if (d2 < F0) then
				F2 = F1
				F1 = F0
				F0 = d2
			elseif (d2 < F1) then
				F2 = F1
				F1 = d2
			elseif (d2 < F2) then
				F2 = d2
			end
		end
	end

	return F0
end


local function value_random2(p)
	return worley_v_fract2(worley_v_s2(Vector(p:Dot(Vector(127.1,311.7)), p:Dot(Vector(269.5, 183.3)))) * 43758.5453)
end

function ZVox.ValueNoise2D(x, y, seed)
	local fx = math.floor(x)
	local fy = math.floor(y)

	local ux = math.ceil(x)
	local uy = math.ceil(y)

	local decx = (x - fx)
	local decy = (y - fy)

	local valDL = value_random2(Vector(fx, fy))
	local valDR = value_random2(Vector(ux, fy))

	local valUL = value_random2(Vector(fx, uy))
	local valUR = value_random2(Vector(ux, uy))


	local rxu = Lerp(decx, valDL[1], valDR[2])
	local rxd = Lerp(decx, valUL[1], valUR[2])


	local final = Lerp(decy, rxu, rxd)

	return final
end


local CONSISTENT_RANDOM_VALUE_COUNT = 32 * 32

local consistentRandomValues = {}
local consistentRandomKey = 0

for i = 1, CONSISTENT_RANDOM_VALUE_COUNT do
	consistentRandomValues[i] = math.random()
end

function ZVox.FlushConsistentRandom()
	consistentRandomKey = 0
end

function ZVox.ConsistentRandom()
	consistentRandomKey = (consistentRandomKey % CONSISTENT_RANDOM_VALUE_COUNT) + 1

	return consistentRandomValues[consistentRandomKey]
end


function ZVox.TileableNoise(func, x, y, w, h)
	local v1 = func(x, y) * (w - x) * (h - y)
	local v2 = func(x - w, y) * (x) * (h - y)
	local v3 = func(x - w, y - h) * (x) * (y)
	local v4 = func(x, y - h) * (w - x) * (y)

	return (v1 + v2 + v3 + v4) / (w * h)
end


-- https://stackoverflow.com/questions/49640250/calculate-normals-from-heightmap
function ZVox.NormalFromNoiseFunc(noiseFunc, x, y, offsetSz, normalize, scale, ease)
	--   T
	-- L O R
	--   B
	scale = scale or 1

	--local noiseO = noiseFunc(x, y)

	local noiseT = noiseFunc(x, y - offsetSz)
	if normalize then noiseT = (noiseT + 1) * .5 end
	if ease then noiseT = ease(noiseT) end
	noiseT = noiseT * scale

	local noiseB = noiseFunc(x, y + offsetSz)
	if normalize then noiseB = (noiseB + 1) * .5 end
	if ease then noiseB = ease(noiseB) end
	noiseB = noiseB * scale

	local noiseL = noiseFunc(x - offsetSz, y)
	if normalize then noiseL = (noiseL + 1) * .5 end
	if ease then noiseL = ease(noiseL) end
	noiseL = noiseL * scale

	local noiseR = noiseFunc(x + offsetSz, y)
	if normalize then noiseR = (noiseR + 1) * .5 end
	if ease then noiseR = ease(noiseR) end
	noiseR = noiseR * scale

	local normalX = 2 * (noiseR - noiseL)
	local normalY = 2 * (noiseB - noiseT)
	local normalZ = 4

	local normal = Vector(normalX, normalY, normalZ)
	normal:Normalize()

	return normal
end

-- https://gist.github.com/kymckay/25758d37f8e3872e1636d90ad41fe2ed

local perlin3d_p = {}

-- Hash lookup table as defined by Ken Perlin
-- This is a randomly arranged array of all numbers from 0-255 inclusive
local permutation = {151,160,137,91,90,15,
	131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
	190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
	88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
	77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
	102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
	135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
	5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
	223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
	129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
	251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
	49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
	138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}
-- p is used to hash unit cube coordinates to [0, 255]
for i = 0, 255 do
	-- Convert to 0 based index table
	perlin3d_p[i] = permutation[i + 1]
	-- Repeat the array to avoid buffer overflow in hash function
	perlin3d_p[i + 256] = permutation[i + 1]
end


-- Gradient function finds dot product between pseudorandom gradient vector
-- and the vector from input coordinate to a unit cube vertex
local perlin3d_dot_product = {
	[0x0] = function(x,y,z) return  x + y end,
	[0x1] = function(x,y,z) return -x + y end,
	[0x2] = function(x,y,z) return  x - y end,
	[0x3] = function(x,y,z) return -x - y end,
	[0x4] = function(x,y,z) return  x + z end,
	[0x5] = function(x,y,z) return -x + z end,
	[0x6] = function(x,y,z) return  x - z end,
	[0x7] = function(x,y,z) return -x - z end,
	[0x8] = function(x,y,z) return  y + z end,
	[0x9] = function(x,y,z) return -y + z end,
	[0xA] = function(x,y,z) return  y - z end,
	[0xB] = function(x,y,z) return -y - z end,
	[0xC] = function(x,y,z) return  y + x end,
	[0xD] = function(x,y,z) return -y + z end,
	[0xE] = function(x,y,z) return  y - x end,
	[0xF] = function(x,y,z) return -y - z end
}
local function perlin3d_grad(hash, x, y, z)
	return perlin3d_dot_product[bit.band(hash,0xF)](x,y,z)
end

-- Fade function is used to smooth final output
local function perlin3d_fade(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

local function perlin3d_lerp(t, a, b)
	return a + t * (b - a)
end

-- Return range: [-1, 1]
function ZVox.Perlin3D(x, y, z)
	y = y or 0
	z = z or 0

	-- Calculate the "unit cube" that the point asked will be located in
	local xi = bit.band(math.floor(x),255)
	local yi = bit.band(math.floor(y),255)
	local zi = bit.band(math.floor(z),255)

	-- Next we calculate the location (from 0 to 1) in that cube
	x = x - math.floor(x)
	y = y - math.floor(y)
	z = z - math.floor(z)

	-- We also fade the location to smooth the result
	local u = perlin3d_fade(x)
	local v = perlin3d_fade(y)
	local w = perlin3d_fade(z)

	-- Hash all 8 unit cube coordinates surrounding input coordinate
	local p = perlin3d_p
	local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
	A   = p[ xi     ] + yi
	AA  = p[ A      ] + zi
	AB  = p[ A + 1  ] + zi
	AAA = p[ AA     ]
	ABA = p[ AB     ]
	AAB = p[ AA + 1 ]
	ABB = p[ AB + 1 ]

	B   = p[ xi + 1 ] + yi
	BA  = p[ B      ] + zi
	BB  = p[ B + 1  ] + zi
	BAA = p[ BA     ]
	BBA = p[ BB     ]
	BAB = p[ BA + 1 ]
	BBB = p[ BB + 1 ]

	-- Take the weighted average between all 8 unit cube coordinates
	return perlin3d_lerp(w,
		perlin3d_lerp(v,
			perlin3d_lerp(u,
				perlin3d_grad(AAA,x,y,z),
				perlin3d_grad(BAA,x-1,y,z)
			),
			perlin3d_lerp(u,
				perlin3d_grad(ABA,x,y-1,z),
				perlin3d_grad(BBA,x-1,y-1,z)
			)
		),
		perlin3d_lerp(v,
			perlin3d_lerp(u,
				perlin3d_grad(AAB,x,y,z-1), perlin3d_grad(BAB,x-1,y,z-1)
			),
			perlin3d_lerp(u,
				perlin3d_grad(ABB,x,y-1,z-1), perlin3d_grad(BBB,x-1,y-1,z-1)
			)
		)
	)
end
