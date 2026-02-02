AddCSLuaFile("cl_init.lua")      -- Client dosyasını gönder
AddCSLuaFile("menu/cl_menu.lua")    -- Menu dosyası
AddCSLuaFile("shared.lua")       -- Shared dosyayı gönder
include("shared.lua")            -- Server’da çalıştır
include("player/playercustomization.lua")  -- Server dosyasını çalıştır
include("player/playerloadout.lua")  -- Server dosyasını çalıştır
include("menu/sv_menu.lua")   -- Server dosyasını çalıştır

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