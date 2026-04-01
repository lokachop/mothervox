ZVox = ZVox or {}

function ZVox.PHYSICS_NewAABB()
	return {
		0, 0, 0, -- min
		1, 1, 1, -- max
	}
end

function ZVox.PHYSICS_MakeAABB(pos, size)
	return {
			pos[1] - size[1] * 0.5,
			pos[2] - size[2] * 0.5,
			pos[3],

			pos[1] + size[1] * 0.5,
			pos[2] + size[2] * 0.5,
			pos[3] + size[3],
	}
end

function ZVox.PHYSICS_SetAABB(aabb, pos, size)
	aabb[1] = pos[1] - size[1] * 0.5
	aabb[2] = pos[2] - size[2] * 0.5
	aabb[3] = pos[3]

	aabb[4] = pos[1] + size[1] * 0.5
	aabb[5] = pos[2] + size[2] * 0.5
	aabb[6] = pos[3] + size[3]
end

function ZVox.PHYSICS_AABBIntersect(a, b)
	return
		a[4] >= b[1] and a[1] <= b[4] and
		a[5] >= b[2] and a[2] <= b[5] and
		a[6] >= b[3] and a[3] <= b[6]
end