AddCSLuaFile("cl_logihandler.lua")
AddCSLuaFile("globalwarfare3/gamemode/shared.lua")
AddCSLuaFile("globalwarfare3/gamemode/vgui/cl_logipanel.lua")
-- For fucks sake, i thought i dont need to use any network shit in this 
-- ill just put these in case something happens
GW3 = GW3 or {}

util.AddNetworkString("logiRequest")

net.Receive("logiRequest", function(len, ply)
    local wpn = net.ReadString()
    local sentPos = net.ReadVector()
    local team = ply:Team()
    print(sentPos)

    GW3.entCall(wpn, team, ply, sentPos)
end)

function GW3.entCall(called, team, ply, sentPos)
    local wpns = {
        ["assault"]    = { [1] = "sent_ball", [2] = "ent_jack_gmod_ezweapon_ak" },
        ["machinegun"] = { [1] = "ent_jack_gmod_ezweapon_m240",  [2] = "ent_jack_gmod_ezweapon_rpk"},
        ["sniper"]     = { [1] = "ent_jack_gmod_ezweapon_sniper1", [2] = "ent_jack_gmod_ezweapon_svd" },
        ["antitank"]   = { [1] = "ent_jack_gmod_ezweapon_at41", [2] = "ent_jack_gmod_ezweapon_rpg7"  },

        ["artillery1"]   = { [1] = "lvs_trailer_sa34", [2] = "lvs_trailer_wz36"  },
        ["misc"]   = { [1] = "sw_zgu1", [2] = "lvs_trailer_zis3"  },

        ["ammo"]   = "ent_jack_gmod_ezammo",
        ["rocketammo"] = "ent_jack_gmod_ezmunitions",

        ["bandage"]   = "ent_jack_gmod_ezammo",
        ["sprint"]   = "ent_jack_gmod_ezammo",
        ["ointment"]   = "ent_jack_gmod_ezammo",
        ["surgerykit"]   = "ent_jack_gmod_ezammo",
 
        ["grenade"]   = "ent_jack_gmod_ezammo",
        ["smoke"]   = "ent_jack_gmod_ezammo",
        ["flash"]   = "ent_jack_gmod_ezammo",

        ["satchel"]   = "ent_jack_gmod_ezammo",
        ["c4"]   = "ent_jack_gmod_ezammo",
        ["tnt"]   = "ent_jack_gmod_ezammo"
    }
 
    if wpns[called] and wpns[called][team] then
        local wpn = wpns[called][team]
        
        local weapon = ents.Create(wpn)
        weapon:SetPos(sentPos + Vector(0, 0, 60))
        weapon:Spawn()
        weapon:Activate()

        print(called)

        if team ~= 1 and team ~= 2 then
            print("takım seç amk")
        end
    end
end