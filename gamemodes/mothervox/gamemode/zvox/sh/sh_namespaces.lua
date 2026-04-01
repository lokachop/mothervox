ZVox = ZVox or {}

local convNamespaceStr = "zvox:"
local activeNamespace = "zvox"
function ZVox.NAMESPACES_SetActiveNamespace(namespace)
	activeNamespace = namespace
	convNamespaceStr = namespace .. ":"
end

function ZVox.NAMESPACES_GetActiveNamespace()
	return activeNamespace
end

function ZVox.NAMESPACES_NamespaceConvert(str)
	return convNamespaceStr .. str
end

function ZVox.NAMESPACES_NamespaceDeconvert(str)
	return string.match(str, "([^:]+):([^:]+)")
end


-- legacy conversion for saves
function ZVox.NAMESPACES_IsStringNamespace(str)
	return string.match(str, ":") and true or false
end

function ZVox.NAMESPACES_NamespaceConvertLegacy(str)
	return "zvox:" .. str
end