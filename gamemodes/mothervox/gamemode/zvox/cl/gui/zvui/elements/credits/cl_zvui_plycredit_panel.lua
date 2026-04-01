ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

function PANEL:Init()
	self:SetTall(64 + 16)
	self:DockMargin(0, 0, 6, 5)

	self.avatarImg = vgui.Create("AvatarImage", self)
	self.avatarImg:SetSize(64, 64)


	self.nameString = "No Name, =("
	self.nameColour = Color(255, 255, 255)

	self.roleString = "No use? =("

	self.trueParent = self -- hack
end

function PANEL:PerformLayout()
	self.avatarImg:SetPos(8, 8)


	local parent = self
	for i = 1, 16 do -- HACK HACK HACK
		parent = parent:GetParent()

		if parent:GetName() == "ZVUI_DFrame" then
			break
		end
	end

	self.trueParent = parent
end

function PANEL:SetSteamID64(sID)
	self.avatarImg:SetSteamID(sID, 64)
end

function PANEL:SetName(name)
	self.nameString = name
end

function PANEL:SetNameColour(nameColour)
	self.nameColour = nameColour -- not mutating, no point copying, just use a pointer
end

function PANEL:SetRole(role)
	self.roleString = role
end


local function paintSurface(self, w, h)
	-- top fx
	surface.SetDrawColor(0, 0, 0, 48)
	surface.DrawRect(0, 0, w, 1)

	-- main surface
	surface.SetDrawColor(32, 32, 32, 220)
	surface.DrawRect(0, 1, w, h - 1)

	-- top fx 2
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(0, 1, w, 2)

	surface.DrawRect(0, 1, w, 1)


	-- left side fx
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(0, 0, 2, h - 1)

	--surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(0, 1, 1, h - 1)

	-- right side fx
	surface.SetDrawColor(0, 0, 0, 48)
	surface.DrawRect(w - 1, 1, 1, h - 1)


	-- bottom fx
	surface.SetDrawColor(0, 0, 0, 24)
	surface.DrawRect(0, h - 3, w, 3)

	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(0, h - 2, w, 2)


	-- horizontal split pfp
	surface.SetDrawColor(0, 0, 0, 32)
	surface.DrawRect(8 + 64 + 6, 3, 2, h - 6)
end


local colour_role = Color(196, 196, 196)
local function paintNameAndDesc(self, w, h)
	-- hack to scissor properly
	local parent = self.trueParent
	local pX, pY = parent:LocalToScreen(0, 0)
	local pW, pH = parent:GetSize()

	render.SetScissorRect(pX, pY, pX + pW, pY + pH, true)
		local nameStr = self.nameString
		local nameCol = self.nameColour
		ZVox.DrawRetroTextShadowed(self, nameStr, 8 + 64 + 14, 0, nameCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 4)

		local roleStr = self.roleString
		ZVox.DrawRetroTextShadowed(self, roleStr, 8 + 64 + 16, 1 + 32 + 8, colour_role, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 3)
	render.SetScissorRect(0, 0, 0, 0, false)
end

function PANEL:Paint(w, h)
	paintSurface(self, w, h)
	paintNameAndDesc(self, w, h)
end

vgui.Register("ZVUI_PlayerCreditPanel", PANEL, "DPanel")