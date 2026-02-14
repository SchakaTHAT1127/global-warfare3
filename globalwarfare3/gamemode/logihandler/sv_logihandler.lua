AddCSLuaFile("cl_logihandler.lua")
AddCSLuaFile("globalwarfare3/gamemode/shared.lua")
AddCSLuaFile("globalwarfare3/gamemode/vgui/cl_logipanel.lua")
util.AddNetworkString("logiRequest")

GW3 = GW3 or {}

function GW3.entCall(wpn, team, ply, sentPos)
    local wpns = {
        -- Takıma göre değişenler
        ["assault"]    = { [1] = "ent_jack_gmod_ezweapon_m16", [2] = "ent_jack_gmod_ezweapon_ak" },
        ["machinegun"] = { [1] = "ent_jack_gmod_ezweapon_m240",  [2] = "ent_jack_gmod_ezweapon_rpk"},
        ["sniper"]     = { [1] = "ent_jack_gmod_ezweapon_sniper1", [2] = "ent_jack_gmod_ezweapon_svd" },
        ["antitank"]   = { [1] = "ent_jack_gmod_ezweapon_at41", [2] = "ent_jack_gmod_ezweapon_rpg7"  },
        ["artillery1"] = { [1] = "lvs_trailer_sa34", [2] = "lvs_trailer_wz36"  },
        ["misc"]       = { [1] = "sw_zgu1", [2] = "lvs_trailer_zis3"  },

        -- Her iki takım için aynı olanlar (Hata almamak için tabloya çevrildi)
        ["ammo"]       = { [1] = "ent_jack_gmod_ezammo", [2] = "ent_jack_gmod_ezammo" },
        ["rocketammo"] = { [1] = "ent_jack_gmod_ezmunitions", [2] = "ent_jack_gmod_ezmunitions" },

        ["bandage"]    = { [1] = "ent_jack_gmod_ezammo", [2] = "ent_jack_gmod_ezammo" },
        ["sprint"]     = { [1] = "ent_jack_gmod_ezammo", [2] = "ent_jack_gmod_ezammo" },
        ["ointment"]   = { [1] = "ent_jack_gmod_ezammo", [2] = "ent_jack_gmod_ezammo" },
        ["surgerykit"] = { [1] = "ent_jack_gmod_ezammo", [2] = "ent_jack_gmod_ezammo" },
        
        ["grenade"]    = { [1] = "ent_jack_gmod_ezfragnade", [2] = "ent_jack_gmod_ezfragnade" },
        ["smoke"]      = { [1] = "ent_jack_gmod_ezflashbang", [2] = "ent_jack_gmod_ezflashbang" },
        ["flash"]      = { [1] = "ent_jack_gmod_ezflashbang", [2] = "ent_jack_gmod_ezflashbang" },
        ["satchel"]    = { [1] = "ent_jack_gmod_ezsatchelcharge", [2] = "ent_jack_gmod_ezsatchelcharge" },
        ["c4"]         = { [1] = "ent_jack_gmod_eztimebomb", [2] = "ent_jack_gmod_eztimebomb" },
        ["tnt"]        = { [1] = "ent_jack_gmod_eztnt", [2] = "ent_jack_gmod_eztnt" }
    }
    
    local weapon = ents.Create(wpns[wpn][team])
    weapon:SetPos(sentPos + Vector(0, 0, 60))
    weapon:Spawn()
    weapon:Activate()
end