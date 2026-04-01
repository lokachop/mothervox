ZVox = ZVox or {}
ZVUI = ZVUI or {}
local PANEL = {}

function PANEL:Init()
	self:SetTall(64)

	self:DockMargin(0, 0, 8, 5)

	self._title = "no title"
	self._description = "If you can see this, something went VERY wrong!"


	self.buttonReset = vgui.Create("ZVUI_DButton", self)
	self.buttonReset:SetSize(16, 16)

	self.buttonReset:SetText("")
	self.buttonReset:SetImage("refresh")
	self.buttonReset:SetTooltip("Reset to default")


	function self.buttonReset.DoClick()
		self:ResetToDefault() -- reset to default on reset button press
	end

	self._defaultValue = false
	self._currentValue = false
	self._selectorType = -1
	self._onChangeFunc = nil


	self._selectorMin = 0
	self._selectorMax = 100
end

function PANEL:SetName(name)
	self._title = name
end

function PANEL:SetDescription(desc)
	self._description = desc
end

function PANEL:SetOnChangeFunc(func)
	self._onChangeFunc = func
end

function PANEL:CallOnChangeFunc()
	if not self._onChangeFunc then
		return
	end

	self._onChangeFunc(self._currentValue)
end

function PANEL:SetMinMax(min, max)
	self._selectorMin = min
	self._selectorMax = max
end

local selectorSetters = {
	[ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX] = function(self, value)
		self.selectorBox:SetChecked(value)
	end,
	[ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY] = function(self, value)
		self.selectorEntry:SetValue(value)
	end,
	[ZVOX_SETTING_SELECTOR_TYPE_COMBO] = function(self, value)
		self.selectorCombo:SetValue(value)
	end,
}

function PANEL:SetValue(value)
	self._currentValue = value

	local selType = self._selectorType
	if selectorSetters[selType] then
		selectorSetters[selType](self, value)
	end

	self:CallOnChangeFunc()
end

function PANEL:SetValueNoSetter(value)
	self._currentValue = value
	self:CallOnChangeFunc()
end

function PANEL:SetValueNoFuncCall(value)
	self._currentValue = value

	local selType = self._selectorType
	if selectorSetters[selType] then
		selectorSetters[selType](self, value)
	end
end




function PANEL:SetDefault(defaultVal)
	self._defaultValue = defaultVal
end

function PANEL:ResetToDefault()
	local default = self._defaultValue

	self:SetValue(default)
end



function PANEL:SetOptions(optionsTbl)
	self._optionsTbl = optionsTbl
end


local selectorConstructors = {
	[ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX] = function(self)
		self.selectorBox = vgui.Create("ZVUI_DCheckBox", self)
		self.selectorBox:SetSize(48, 16)

		self.selectorBox:SetChangeCallback(function()
			self:SetValue(self.selectorBox:GetChecked())
		end)
	end,

	[ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY] = function(self)
		self.selectorEntry = vgui.Create("ZVUI_DNumberWang", self)

		self.selectorEntry:SetSize(96, 16)

		-- min and max
		self.selectorEntry:SetMin(self._selectorMin)
		self.selectorEntry:SetMax(self._selectorMax)


		function self.selectorEntry.OnValueChanged(self2)
			if not self2._init_THIS_IS_A_HACK then
				self2._init_THIS_IS_A_HACK = true
				return
			end

			local val = self.selectorEntry:GetValue()
			val = math.min(val, self._selectorMax)
			val = math.max(val, self._selectorMin)

			self:SetValueNoSetter(val)
		end
	end,

	[ZVOX_SETTING_SELECTOR_TYPE_COMBO] = function(self, w, h)
		self.selectorCombo = vgui.Create("ZVUI_DComboBox", self)
		self.selectorCombo:SetSize(96, 16)

		if not self._optionsTbl then
			ZVox.PrintError("ZVOX_SETTING_SELECTOR_TYPE_COMBO with no options, bad!")
			return
		end

		for i = 1, #self._optionsTbl do
			local opt = self._optionsTbl[i]
			self.selectorCombo:AddChoice(opt)
		end

		function self.selectorCombo.OnSelect(pnl, idx, value)
			self:SetValueNoSetter(value)
		end
	end,
}

-- make sure you only call this ONCE!
function PANEL:SetSelectorType(selectorType)
	if not selectorConstructors[selectorType] then
		return
	end

	self._selectorType = selectorType
	selectorConstructors[selectorType](self)
end

local selectorLayouts = {
	[ZVOX_SETTING_SELECTOR_TYPE_CHECKBOX] = function(self, w, h)
		self.selectorBox:SetPos(w - 24 - 48 - 8, 8)
	end,

	[ZVOX_SETTING_SELECTOR_TYPE_NUMENTRY] = function(self, w, h)
		self.selectorEntry:SetPos(w - 24 - 96 - 8, 8)
	end,

	[ZVOX_SETTING_SELECTOR_TYPE_COMBO] = function(self, w, h)
		self.selectorCombo:SetPos(w - 24 - 96 - 8, 8)
	end,
}

function PANEL:PerformLayout(w, h)
	self.buttonReset:SetPos(w - 24, 8)

	local selType = self._selectorType
	if selectorLayouts[selType] then
		selectorLayouts[selType](self, w, h)
	end
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
end

local textCol = Color(255, 255, 255)
local descCol = Color(139, 165, 196)
function PANEL:Paint(w, h)
	paintSurface(self, w, h)

	-- title
	local tW = draw.SimpleText(self._title, "ZVUI_UniversePanelTitleFont", 8, 16 + 3, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local hrHeight = 32 + 3
	-- draw the HR
	surface.SetDrawColor(64, 98, 138)
	surface.DrawRect(4, hrHeight, w - (4 * 2), 2)

	-- description
	draw.SimpleText(self._description, "ZVUI_UniversePanelDescriptionFont", 8, hrHeight + 13, descCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("ZVUI_SettingPanel", PANEL, "DPanel")