AddCSLuaFile("cl_init.lua")
AddCSLuaFile("vgui/cl_menu.lua")
AddCSLuaFile("vgui/cl_teampanel.lua")
AddCSLuaFile("vgui/cl_tabmenu.lua")
AddCSLuaFile("sounds/cl_soundpr.lua")
AddCSLuaFile("logihandler/cl_logihandler.lua")
AddCSLuaFile("shared.lua")

include("logihandler/sv_logihandler.lua")
include("shared.lua") 
include("player/playercustomization.lua")
include("vgui/sv_menu.lua")
include("cvars.lua")

include("vehiclespawn/sv_kamyon.lua")
include("vehiclespawn/sv_arac.lua")
include("vehiclespawn/sv_apc.lua")
--include("vehiclespawn/sv_heli.lua")

include("ticketsys/sv_ticketsystem.lua")

DeriveGamemode("sandbox")
UKR = 1
RUS = 2
UKRticket = 100
RUSticket = 100

--teams lie here again
team.SetUp(UKR, "Ukrainian Ground Forces", Color(0, 33, 203))
team.SetUp(RUS, "Russian Ground Forces", Color(223, 8, 8))
--precache for optimization etc. again
util.PrecacheModel("models/morpeh/ukraine_marine2010.mdl")
util.PrecacheModel("models/4ervo/ml_project/russian_soldier2012.mdl")

-- below, lies the common things.

hook.Add("CanPlayerSuicide", "stopSuicide", function(ply)
    return true
end)


hook.Add( "CanPlayerEnterVehicle", "PrintPlayersInVehicles", function( ply, veh, role )
    local parentVehicle = veh:GetParent()
    local team = ply:Team()

    if not IsValid(parentVehicle) then return false end 

    local ukrVehicleList = {
        ["kamyon"] = {class = "sw_gaz66"},
        ["arac"] = {class = "sw_uaz469"},
        ["apc"] = {class = "sw_btr60"}
    }

    local rusVehicleList = {
        ["kamyon"] = {class = "sw_ural4320"},
        ["arac"] = {class = "sw_gaz2330"},
        ["apc"] = {class = "sw_btr82"},
        ["apc2"] = {class = "sw_mtlb"}
    }

    if team == 1 then
        for name, data in pairs(ukrVehicleList) do
            if parentVehicle:GetClass() == data.class then
                return true
            end
        end
        return false 

    elseif team == 2 then
        for name, data in pairs(rusVehicleList) do
            if parentVehicle:GetClass() == data.class then
                return true
            end
        end
        return false 

    else
        return false
    end
end )

hook.Add( "InitPostEntity", "SunucuHazirKodu", function()
    print("InitPostEntity")
    UKRticket = 100
    RUSticket = 100
end)