GM.Name = "MotherVox"
GM.Author = "Lokachop, zynx"
GM.Email = "lokachop [at] gmail.com"
GM.Website = "https://github.com/lokachop"

function GM:Initialize()
end

if SERVER then
	AddCSLuaFile("zvox/zvox_init.lua")
end

include("zvox/zvox_init.lua")