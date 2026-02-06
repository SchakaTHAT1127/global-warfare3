AddCSLuaFile("cl_init.lua")
AddCSLuaFile("vgui/cl_menu.lua")
AddCSLuaFile("vgui/cl_teampanel.lua")
AddCSLuaFile("sounds/cl_soundpr.lua")
AddCSLuaFile("logihandler/cl_logihandler.lua")
AddCSLuaFile("shared.lua")

include("logihandler/sv_logihandler.lua")
include("shared.lua") 
include("player/playercustomization.lua")
include("player/playerloadout.lua") 
include("vgui/sv_menu.lua")

DeriveGamemode("sandbox")
USA = 1
SGF = 2

--teams lie here again
team.SetUp(USA, "North Atlantic Treaty Forces", Color(0, 33, 203))
team.SetUp(SGF, "Soviet Ground Forces", Color(223, 8, 8))
--precache for optimization etc. again
util.PrecacheModel("models/olegun/ColdWarInfantry/coldwar_Woodland.mdl")
util.PrecacheModel("models/bratnik/soldier_aghanka.mdl")

-- I dont really know if i just need to put these in shared or here so i just putted them in both