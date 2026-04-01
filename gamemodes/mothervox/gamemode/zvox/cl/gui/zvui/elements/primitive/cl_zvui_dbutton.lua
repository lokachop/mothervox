ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

-- colour skin system for diff colours lemme add that!
local colourSkinList = {
	["standard"] = {
		["neutral"] = Color(64, 98, 138),
		["highlight"] = Color(92, 131, 176),
		["press"] = Color(92 + 28, 131 + 33, 176 + 38),

		["disabled"] = Color(64, 64, 64),

		["text_disabled"] = Color(128, 128, 128),
		["text_enabled"] = Color(255, 255, 255),
	},
	["semiscary"] = {
		["neutral"] = Color(138, 114, 64),
		["highlight"] = Color(176, 142, 92),
		["press"] = Color(176 + 28, 142 + 33, 82 + 38),

		["disabled"] = Color(64, 64, 64),

		["text_disabled"] = Color(128, 128, 128),
		["text_enabled"] = Color(255, 255, 255),
	},
	["scary"] = {
		["neutral"] = Color(138, 64, 64),
		["highlight"] = Color(176, 92, 92),
		["press"] = Color(176 + 28, 92 + 33, 82 + 38),

		["disabled"] = Color(64, 64, 64),

		["text_disabled"] = Color(128, 128, 128),
		["text_enabled"] = Color(255, 255, 255),
	},
}

function PANEL:Init()
	-- this first to avoid headaches
	self._colSkinTable = colourSkinList["standard"]

	self:SetContentAlignment(5)

	self:SetPaintBackground(true)

	self:SetWide(48)
	self:SetTall(20)
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self:SetCursor("hand")


	self:SetFont("DermaDefault")
	self:SetTextStyleColor(Color(255, 255, 255))

	self._buttonColour = self._colSkinTable.neutral

	self._imgName = nil
	self._imgScale = 1
	self._imgFilter = TEXFILTER.ANISOTROPIC


	self.m_colText = ""

	self._text = "ZVUI_Btn"
	self._textColour = self._colSkinTable.text_enabled
	self._textFont = "DermaDefault"
end

function PANEL:SetText(msg)
	self._text = msg
end

function PANEL:SetTextStyleColor(msg)
	self._textColour = msg
end

function PANEL:SetTextFont(fontName)
	self._textFont = fontName
end


function PANEL:SetImage(imgName)
	self._imgName = imgName
end
PANEL.SetIcon = PANEL.SetImage

function PANEL:SetImageScale(scl)
	self._imgScale = scl
end
PANEL.SetIconScale = PANEL.SetImageScale

function PANEL:SetImageFilter(texFilter)
	self._imgFilter = texFilter
end
PANEL.SetIconFilter = PANEL.SetImageFilter


function PANEL:SetColourSkinName(colSkinName)
	if not colourSkinList[colSkinName] then
		self._colSkinTable = colourSkinList["standard"]
		return
	end

	self._colSkinTable = colourSkinList[colSkinName]
	self:UpdateColours()
end

-- expandable so devs can add their own custom skins without needing to declare it here
function PANEL:SetColourSkinTable(colSkinTable)
	self._colSkinTable = colSkinTable
	self:UpdateColours()
end

function PANEL:UpdateColours(skin)
	local colSkin = self._colSkinTable
	if not colSkin then
		print("[ZVUI] We are missing colSkin for some reason!!!!!")
		print("BIG DEBUG;")
		print("colSkin", colSkin)
		print("self", self)
		print("self._colSkinTable", self._colSkinTable)

		colSkin = colourSkinList["standard"]
	end

	if not self:IsEnabled() then
		self._buttonColour = colSkin.disabled
		self:SetTextStyleColor(colSkin.text_disabled)
		self:SetCursor("no")
		return
	end
	self:SetTextStyleColor(colSkin.text_enabled)
	self:SetCursor("hand")


	if self:IsDown() then
		self._buttonColour = colSkin.press
		return
	end

	if self:IsHovered() then
		self._buttonColour = colSkin.highlight
		return
	end

	self._buttonColour = colSkin.neutral
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(39, 39, 39)
	surface.DrawRect(0, 0, w, h)


	surface.SetDrawColor(self._buttonColour)
	surface.DrawRect(1, 1, w - 2, h - 2)


	local noText = self._text == ""

	local imgShift = 0
	local imgName = self._imgName
	if imgName ~= nil then
		imgShift = 6
		surface.SetDrawColor(self._textColour)

		local realScl = self._imgScale
		local scl = 16 * realScl

		local sclSubX = scl * .5
		local sclSubY = (scl * .5) - (.5 * realScl)

		local filter = self._imgFilter

		render.PushFilterMag(filter)
		render.PushFilterMin(filter)
			if noText then
				ZVUI.RenderIcon(imgName, (w * .5) - sclSubX, (h * .5) - sclSubY + 1, scl, scl) -- center icon when no text
			else
				ZVUI.RenderIcon(imgName, 2, (h * .5) - sclSubY, scl, scl)
			end
		render.PopFilterMag()
		render.PopFilterMin()
	end

	if not noText then
		draw.SimpleText(self._text, self._textFont, w * .5 + imgShift, (h * .5) - 1, self._textColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

vgui.Register("ZVUI_DButton", PANEL, "DButton")