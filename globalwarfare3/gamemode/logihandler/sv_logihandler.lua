AddCSLuaFile("cl_logihandler.lua")
AddCSLuaFile("globalwarfare3/gamemode/shared.lua")
AddCSLuaFile("globalwarfare3/gamemode/vgui/cl_logipanel.lua")
-- For fucks sake, i realized i had to use networking it kept saying that it couldnt find this file...
-- ill just put these in case something happens
GW3 = GW3 or {}

util.AddNetworkString("logiRequest")

net.Receive("logiRequest", function(len, ply)
    local wpn = net.ReadString()
    local team = ply:Team()

    GW3.entCall(class, team, ply)
end)

function GW3.entCall(called, team, ply)
    local wpns = {
        ["assault"]    = { [1] = "arccw_rs2m16", [2] = "arccw_ur_ak" },
        ["machinegun"] = { [1] = "arccw_eft_pkm",  [2] = "arccw_eft_pkm"},
        ["sniper"]     = { [1] = "new_sniperrifle", [2] = "new_svd" },
        ["antitank"]   = { [1] = "new_launcher", [2] = "arccw_rpg7"  }
    }

    if wpns[called] and wpns[called][team] then
        local wpn = wpns[called][team]
        -- just some debugs
        print("silah: " .. wpn .. " | takım: " .. team .. " | oyuncu: " .. ply:Nick())
    end
end