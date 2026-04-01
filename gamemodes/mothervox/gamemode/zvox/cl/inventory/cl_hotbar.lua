ZVox = ZVox or {}

local block_name = CreateClientConVar("zvox_block", "tile") -- TODO: change to internal handling...
local voxelInfoRegistry = ZVox.GetVoxelRegistry()

function ZVox.GetSelectedVoxelName()
	local name = block_name:GetString()
	if not ZVox.GetVoxelID(name) then
		return "zvox:stone"
	end

	return name
end

function ZVox.GetSelectedVoxelID()
	local name = block_name:GetString()
	local id = ZVox.GetVoxelID(name)

	if not id then
		id = 1
	end

	return id
end

function ZVox.SetSelectedVoxelID(id)
	local voxInfo = voxelInfoRegistry[id]
	if not voxInfo then
		return
	end

	if voxInfo.name == block_name:GetString() then
		return
	end

	ZVox.SetVMBlockSwitchAnim()
	RunConsoleCommand("zvox_block", voxInfo.name)
end

function ZVox.SetSelectedVoxelName(name)
	if not ZVox.GetVoxelID(name) then
		return
	end

	RunConsoleCommand("zvox_block", name)
end


-- Hotbar
local initialHotbarConfig = {
	"zvox:stone",
	"zvox:cobble",
	"zvox:bricks",
	"zvox:dirt",
	"zvox:oak_planks",
	"zvox:oak_log",
	"zvox:oak_leaves",
	"zvox:glass",
	"zvox:pillar_slab"
}

ZVox.PersistentHotbar = ZVox.PersistentHotbar
if not ZVox.PersistentHotbar then
	ZVox.PersistentHotbar = {1, 2, 3, 4, 5, 6, 7, 8, 9}
	for i = 1, #initialHotbarConfig do
		ZVox.PersistentHotbar[i] = ZVox.GetVoxelID(initialHotbarConfig[i])
	end
end
local selfHotbar = ZVox.PersistentHotbar


ZVox.PersistentHotbarState = ZVox.PersistentHotbarState
if not ZVox.PersistentHotbarState then
	ZVox.PersistentHotbarState = {0, 0, 0, 0, 0, 0, 0, 0, 0}
end
local selfHotbarState = ZVox.PersistentHotbarState


ZVox.PersistentHotbarIndex = ZVox.PersistentHotbarIndex or 1
function ZVox.GetSelectedHotbarIndex()
	return ZVox.PersistentHotbarIndex
end

function ZVox.SetSelectedHotbarIndex(idx)
	ZVox.PersistentHotbarIndex = idx or 1


	local id = selfHotbar[ZVox.PersistentHotbarIndex]
	ZVox.SetSelectedVoxelID(id)
end


function ZVox.SetBlockAtHotbarSlotID(id)
	local voxInfo = voxelInfoRegistry[id]
	if not voxInfo then
		return
	end

	selfHotbar[ZVox.PersistentHotbarIndex] = id
	ZVox.SetSelectedVoxelID(id)
end

-- This for MMB
function ZVox.SwitchToBlockAtHotbarID(id)
	local voxInfo = voxelInfoRegistry[id]
	if not voxInfo then
		return
	end

	-- scan hotbar first
	for i = 1, 9 do
		if selfHotbar[i] == id then
			ZVox.SetSelectedHotbarIndex(i)
			return
		end
	end

	ZVox.SetBlockAtHotbarSlotID(id)
end


-- This for inventory replace
-- This mimics the ClassiCube behaviour, of swapping
function ZVox.SetBlockAtHotbarSlotID(id, state)
	state = state or 0

	local voxInfo = voxelInfoRegistry[id]
	if not voxInfo then
		return
	end

	-- scan hotbar first
	local doSwapIdx = nil
	for i = 1, 9 do
		if selfHotbar[i] ~= id then
			continue
		end

		-- we found the same thing, we must swap the current
		doSwapIdx = i
	end

	-- we swap like in classicube
	if doSwapIdx then
		selfHotbar[doSwapIdx] = selfHotbar[ZVox.PersistentHotbarIndex]
	end

	selfHotbar[ZVox.PersistentHotbarIndex] = id
	ZVox.SetSelectedVoxelID(id)
end


local slotLUT = {
	["slot1"] = 1,
	["slot2"] = 2,
	["slot3"] = 3,
	["slot4"] = 4,
	["slot5"] = 5,
	["slot6"] = 6,
	["slot7"] = 7,
	["slot8"] = 8,
	["slot9"] = 9,
}

local scrollLUT = {
	["invprev"] = -2,
	["invnext"] =  0,
}

function ZVox.HotbarSlotScroll(translatedBind)
	local slotDelta = scrollLUT[translatedBind]
	if not slotDelta then
		return
	end

	ZVox.PersistentHotbarIndex = ((ZVox.PersistentHotbarIndex + slotDelta) % 9) + 1

	local content = selfHotbar[ZVox.PersistentHotbarIndex]
	ZVox.SetSelectedVoxelID(content)
end

for i = 1, 9 do
	ZVox.NewControlListener("inv_switch_" .. i, "hotbar_switch_" .. i, function()
		ZVox.PersistentHotbarIndex = i

		local content = selfHotbar[i]
		ZVox.SetSelectedVoxelID(content)
	end)
end




-- Rendering
local function drawHollowRectangle(x, y, w, h, thick)
	local h_thick = thick * .5

	-- top
	surface.DrawRect(x, y, w, h_thick)
	-- left
	surface.DrawRect(x, y + h_thick, h_thick, h - thick)
	-- right
	surface.DrawRect(x + w - h_thick, y + h_thick, h_thick, h - thick)
	-- bottom
	surface.DrawRect(x, (y + h) - h_thick, w, h_thick)
end


local function drawOutlineFX(x, y, w, h, thick, colHigh, colMed, colDark)
	local h_thick = thick * .5
	local h_h_thick = h_thick * .5

	-- top
	surface.SetDrawColor(colHigh)
	surface.DrawRect(x, y, w, h_h_thick)

	-- left
	surface.SetDrawColor(colMed)
	surface.DrawRect(x, y + h_h_thick, h_h_thick, h - h_h_thick)

	-- bottom
	surface.DrawRect(x + h_h_thick, y + h - h_thick, w - h_thick, h_h_thick)

	-- right
	surface.DrawRect(x + w - h_thick, y + h_thick, h_h_thick, h - h_thick - h_h_thick)


	-- shade

	-- left
	surface.SetDrawColor(colDark)
	surface.DrawRect(x + h_thick, y + h_thick, h_h_thick, h - h_thick - h_thick)
	-- top
	surface.DrawRect(x + h_thick + h_h_thick, y + h_thick, w - h_thick - h_thick - h_h_thick, h_h_thick)
end



local iconSize = 64
local borderSize = 12

local h_iconSize = iconSize * .5
local h_borderSize = borderSize * .5

local finalSize = iconSize + borderSize

local matrixMeshDraw = Matrix()
matrixMeshDraw:SetScale(Vector(h_iconSize, h_iconSize, 1))


local colHigh = Color(196, 196, 196)
local colMed = Color(140, 140, 140)
local colDark = Color(0, 0, 0, 196)


local colHighSelect = Color(196 + 105, 196 + 75, 196 - 32)
local colMedSelect = Color(140 + 105, 140 + 75, 140 - 32)
local colDarkSelect = Color(0, 0, 0, 196)
local function renderHotbarSlot(idx, x, y)
	surface.SetDrawColor(96, 96, 96)
	drawHollowRectangle(x, y, finalSize, finalSize, borderSize)
	drawOutlineFX(x, y, finalSize, finalSize, borderSize, colHigh, colMed, colDark)

	local voxelID = selfHotbar[idx]
	local mat = ZVox.GetVoxelIconMat(voxelID)
	surface.SetMaterial(mat)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(x + h_borderSize, y + h_borderSize, iconSize, iconSize)


	if idx == ZVox.PersistentHotbarIndex then -- draw the extra border
		local this_borderSize = borderSize * 1


		surface.SetDrawColor(96 + 105, 96 + 75, 96 - 32)
		drawHollowRectangle(x, y, finalSize, finalSize, this_borderSize)

		drawOutlineFX(x, y, finalSize, finalSize, this_borderSize, colHighSelect, colMedSelect, colDarkSelect)
	end
end


local function friendly_name(msg)
	local _, name = ZVox.NAMESPACES_NamespaceDeconvert(msg)

	return string.gsub(name, "_", " ")
end


local lastID = 0
local lastChange = CurTime()

local solidTime = 2
local fadeTime = 2

local itemNameColor = Color(255, 255, 255, 0)
local function renderHotbarVoxelName(cX, yc)
	local currID = ZVox.GetSelectedVoxelID()
	if lastID ~= currID then
		lastID = currID
		lastChange = CurTime()
	end

	local time = (CurTime() - lastChange)
	if time >= (solidTime + fadeTime) then
		return
	end

	local alphaDelta = (time - solidTime) / fadeTime
	alphaDelta = 1 - math.max(alphaDelta, 0)
	alphaDelta = math.min(alphaDelta, 1)
	itemNameColor.a = alphaDelta * 255

	local voxInfo = voxelInfoRegistry[currID]

	local strWrite = friendly_name(voxInfo.name)

	if ZVox.GetDebugDraw() then
		strWrite = voxInfo.name
		strWrite = strWrite .. " (#" .. tostring(currID) .. ")"
	end

	ZVox.DrawRetroTextShadowed(nil, strWrite, cX, yc - 12, itemNameColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 4)
end


local subConst = ((8 / 9) * .5)
local hotWidth = finalSize * 9
local h_hotWidth = hotWidth * .5
function ZVox.RenderHotbar()
	if ZVox.GetCameraModeState() then
		return
	end

	if ZVox.GetPlayerMovementType() ~= ZVOX_MOVEMENT_NOCLIP then
		return
	end

	local cX = ScrW() * .5
	local yc = (ScrH() * .95) - finalSize

	ZVox.BlurScreenRect(cX - h_hotWidth, yc, hotWidth, finalSize, 3, 6)

	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(cX - h_hotWidth, yc, hotWidth, finalSize)

	for i = 1, 9 do
		local dx = (i - 1) / 9
		dx = dx - subConst

		local xc = (hotWidth * dx) + cX

		renderHotbarSlot(i, xc - (finalSize * .5), yc)
	end

	renderHotbarVoxelName(cX, yc)
end
