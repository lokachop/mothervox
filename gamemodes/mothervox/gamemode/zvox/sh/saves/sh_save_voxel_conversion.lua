ZVox = ZVox or {}

local _convLUT = {}
function ZVox.GetConversionTable()
	return _convLUT
end


function ZVox.DeclareNewConversion(oldName, newName)
	_convLUT[ZVox.NAMESPACES_NamespaceConvert(oldName)] = ZVox.NAMESPACES_NamespaceConvert(newName)
end


ZVox.DeclareNewConversion("group_test", "xor")
ZVox.DeclareNewConversion("placebo_water", "water")