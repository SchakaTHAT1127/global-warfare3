AddCSLuaFile("cl_logihandler.lua")
AddCSLuaFile("globalwarfare3/gamemode/shared.lua")
AddCSLuaFile("globalwarfare3/gamemode/vgui/cl_logipanel.lua")
util.AddNetworkString("logisticSendNewAmountNato")
util.AddNetworkString("logisticSendNewAmountUssr")

GW3 = GW3 or {}

net.Receive("logisticSendNewAmountUssr", function(len, ply)
    local wpn = net.ReadString()
    local sentPos = net.ReadVector()
    local targetEnt = net.ReadEntity() 
    local readedLogistic = net.ReadInt(9)
    
    local team = ply:Team()

    -- calling the func
    GW3.entCall(wpn, team, ply, sentPos, readedLogistic, targetEnt)
end)


net.Receive("logisticSendNewAmountNato", function(len, ply)
    local wpn = net.ReadString()
    local sentPos = net.ReadVector()
    local targetEnt = net.ReadEntity() 
    local readedLogistic = net.ReadInt(9)
    
    local team = ply:Team()

    -- calling the func
    GW3.entCall(wpn, team, ply, sentPos, readedLogistic, targetEnt)
end)

function GW3.entCall(wpn, team, ply, sentPos, logistic, targetedentity)
    local wpns = {
        ["assault"]    = { [1] = { class = "tacrp_ak_ak74", price = 20 }, [2] = { class = "tacrp_ak_ak74", price = 20 } },
        ["machinegun"] = { [1] = { class = "tacrp_sd_pkm", price = 25}, [2] = { class = "tacrp_sd_pkm", price = 25 } },
        ["sniper"]     = { [1] = { class = "tacrp_ak_svd", price = 20 }, [2] = { class = "tacrp_ak_svd", price = 20 } },
        ["antitank"]   = { [1] = { class = "tacrp_rpg7", price = 65 }, [2] = { class = "tacrp_rpg7", price = 65 } },
        ["artillery1"] = { [1] = { class = "lvs_trailer_sa34", price = 50 }, [2] = { class = "lvs_trailer_wz36", price = 80 } },
        ["misc"]       = { [1] = { class = "sw_zgu1", price = 80 }, [2] = { class = "lvs_trailer_zis3", price = 170 } },
        ["radio"]      = { [1] = { class = "ent_radcrate", price = 15 }, [2] = { class = "ent_radcrate", price = 15 } },

        ["ammo"]       = { [1] = { class = "ent_jack_gmod_ezammo", price = 60 }, [2] = { class = "ent_jack_gmod_ezammo", price = 60 } },
        ["rocketammo"] = { [1] = { class = "ent_jack_gmod_ezmunitions", price = 48 }, [2] = { class = "ent_jack_gmod_ezmunitions", price = 48 } },

        ["bandage"]    = { [1] = { class = "rapd_inventory_item_bandage", price = 5 }, [2] = { class = "rapd_inventory_item_bandage", price = 5 } },
        ["splint"]     = { [1] = { class = "rapd_inventory_item_splint", price = 5 }, [2] = { class = "rapd_inventory_item_splint", price = 5 } },
        ["ointment"]   = { [1] = { class = "rapd_inventory_item_burn_ointment", price = 5 }, [2] = { class = "rapd_inventory_item_burn_ointment", price = 5 } },
        ["surgerykit"] = { [1] = { class = "rapd_inventory_item_surgery_kit", price = 10 }, [2] = { class = "rapd_inventory_item_surgery_kit", price = 10 } },
        
        ["grenade"]    = { [1] = { class = "ent_jack_gmod_ezfragnade", price = 15 }, [2] = { class = "ent_jack_gmod_ezfragnade", price = 12 } },
        ["smoke"]      = { [1] = { class = "ent_jack_gmod_ezsmokenade", price = 10 }, [2] = { class = "ent_jack_gmod_ezsmokenade", price = 10 } },
        ["flash"]      = { [1] = { class = "ent_jack_gmod_ezflashbang", price = 10 }, [2] = { class = "ent_jack_gmod_ezflashbang", price = 10 } },

        ["satchel"]    = { [1] = { class = "ent_jack_gmod_ezsatchelcharge", price = 90 }, [2] = { class = "ent_jack_gmod_ezsatchelcharge", price = 90 } },
        ["c4"]         = { [1] = { class = "ent_jack_gmod_eztimebomb", price = 80 }, [2] = { class = "ent_jack_gmod_eztimebomb", price = 80 } },
        ["tnt"]        = { [1] = { class = "ent_jack_gmod_eztnt", price = 80 }, [2] = { class = "ent_jack_gmod_eztnt", price = 80 } }
    }

    local itemData = wpns[wpn][team]
    if not itemData then return end

    local price = itemData.price
    print("the price " .. price .. " | the logistic " .. logistic)

    if team == 1 then
        if IsValid(targetedentity) then
            if logistic >= price then 
                -- Satın alma işlemi başarılı
                logistic = logistic - price
                targetedentity:SetLogisticAmountNato(logistic)
                
                print("succesful new logistic: " .. logistic)

                local weapon = ents.Create(itemData.class)
                if IsValid(weapon) then
                    weapon:SetPos(sentPos + Vector(0, 0, 60))
                    weapon:Spawn()
                    weapon:Activate()

                    local class = weapon:GetClass()
                    
                    -- Eşya tipine göre kaynak belirleme
                    if class == "ent_jack_gmod_ezammo" then
                        weapon:SetResource(35) 
                    elseif class == "ent_jack_gmod_ezmunitions" then
                        weapon:SetResource(48)
                    else
                    return end
                end
            else
                -- Bakiye yetersizse burası çalışır
                print("no money")
            end
        end
    elseif team == 2 then
        if IsValid(targetedentity) then
            if logistic >= price then 
                -- Satın alma işlemi başarılı
                logistic = logistic - price
                targetedentity:SetLogisticAmountUssr(logistic)
                
                print("succesful new logistic: " .. logistic)

                local weapon = ents.Create(itemData.class)
                if IsValid(weapon) then
                    weapon:SetPos(sentPos + Vector(0, 0, 60))
                    weapon:Spawn()
                    weapon:Activate()

                    local class = weapon:GetClass()
                    
                    -- Eşya tipine göre kaynak belirleme
                    if class == "ent_jack_gmod_ezammo" then
                        weapon:SetResource(35) 
                    elseif class == "ent_jack_gmod_ezmunitions" then
                        weapon:SetResource(48)
                    elseif class == "lvs_trailer_zis3" then
                        -- Buraya zis3 için özel bir kod gelecekse ekleyebilirsin
                        print("ZIS-3 spawned")
                    end
                end
            else
                -- Bakiye yetersizse burası çalışır
                print("no money")
            end
        end
    end
end