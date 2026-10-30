-- ekliyoruz
AddCSLuaFile("cl_logihandler.lua")
AddCSLuaFile("globalwarfare3/gamemode/shared.lua")
util.AddNetworkString("logisticSendNewAmountUkr")
util.AddNetworkString("logisticSendNewAmountBuild")
util.AddNetworkString("logisticSendNewAmountRus")
util.AddNetworkString("logisticSendNewAmountArmorUKR")
util.AddNetworkString("logisticSendNewAmountArmorRUS")
GW3 = GW3 or {}

--
net.Receive("logisticSendNewAmountRus", function(len, ply)
    --cl_logipanel_ussr'daki butona basılmış, yollanan bilgileri alıyoruz ve atama yapıyoruz
    local wpn = net.ReadString() --silah adı
    local sentPos = net.ReadVector() -- lokasyon
    local targetEnt = net.ReadEntity() --silah veya başka bişey
    local readedLogistic = net.ReadInt(9) --Lojistik kutusunun lojistik miktarı
    
    local team = ply:Team() -- oyuncu takımı

    -- calling the func
    GW3.entCall(wpn, team, ply, sentPos, readedLogistic, targetEnt) 
end)


net.Receive("logisticSendNewAmountUkr", function(len, ply)
    local wpn = net.ReadString()
    local sentPos = net.ReadVector()
    local targetEnt = net.ReadEntity() 
    local readedLogistic = net.ReadInt(9)
    
    local team = ply:Team()

    -- calling the func
    GW3.entCall(wpn, team, ply, sentPos, readedLogistic, targetEnt)
end)
net.Receive("logisticSendNewAmountArmorUKR", function(len, ply)
    local wpn = net.ReadString()
    local sentPos = net.ReadVector()
    local targetEnt = net.ReadEntity() 
    local readedLogistic = net.ReadInt(9)
    
    local team = ply:Team()

    -- calling the func
    GW3.entCall(wpn, team, ply, sentPos, readedLogistic, targetEnt)
end)

net.Receive("logisticSendNewAmountArmorRUS", function(len, ply)
    local wpn = net.ReadString()
    local sentPos = net.ReadVector()
    local targetEnt = net.ReadEntity() 
    local readedLogistic = net.ReadInt(9)
    
    local team = ply:Team()

    -- calling the func
    print("called func")
    GW3.entCall(wpn, team, ply, sentPos, readedLogistic, targetEnt)
end)
net.Receive("logisticSendNewAmountBuild", function(len, ply)
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
        ["machinegun"] = { [1] = { class = "tacrp_io_rpk", price = 20}, [2] = { class = "tacrp_sd_pkm", price = 25 } },
        ["sniper"]     = { [1] = { class = "tacrp_ak_svd", price = 20 }, [2] = { class = "tacrp_ak_svd", price = 20 } },
        ["antitank"]   = { [1] = { class = "tacrp_rpg7", price = 65 }, [2] = { class = "tacrp_rpg7", price = 65 } },
        ["special"]   = { [1] = { class = "tacrp_ex_ak47", price = 20 }, [2] = { class = "tacrp_io_val", price = 30 } },
        ["carbine"]   = { [1] = { class = "tacrp_ak_ak74u", price = 15 }, [2] = { class = "tacrp_ak_ak74u", price = 15 } },
        ["artillery1"] = { [1] = { class = "sw_kord", price = 120 }, [2] = { class = "sw_kord", price = 120 } },
        ["misc"]       = { [1] = { class = "lvs_trailer_zis3", price = 170 }, [2] = { class = "lvs_trailer_zis3", price = 170 } },
        ["radio"]      = { [1] = { class = "ent_radcrate", price = 15 }, [2] = { class = "ent_radcrate", price = 15 } },

        ["zirh1"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_6b5-16ttsko", price = 20 },
            [2] = { class = "ent_jack_gmod_ezarmor_6b13rus", price = 20 }
        },

        ["zirh2"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_lifchik-ukr", price = 10 },
            [2] = { class = "ent_jack_gmod_ezarmor_lifchik-flora", price = 10 }
        },

        ["ssh"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_ssh68cover", price = 10 },
            [2] = { class = "ent_jack_gmod_ezarmor_ssh68coverflora", price = 10 }
        },

        ["3000"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_temp3000coverless", price = 20 },
            [2] = { class = "ent_jack_gmod_ezarmor_ruskask", price = 20 }
        },

        ["helmetozel"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_zhs1-2m", price = 15 },
            [2] = { class = "ent_jack_gmod_ezarmor_zhs1-2m", price = 15 }
        },

        ["sapka"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_kepka-afganka", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_ruscap", price = 5 }
        },

        ["sapka2"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_blueberretrus", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_blueberretrus", price = 5 }
        },

        ["backpack"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_ukrbackpack", price = 10 },
            [2] = { class = "ent_jack_gmod_ezarmor_vkborussianbag", price = 10 }
        },

        ["bant"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_colorarmband", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_colorarmband", price = 5 }
        },

        ["balaclava"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_balaclava", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_balaclava", price = 5 }
        },

        ["halfmask"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_balaclava2", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_balaclava2", price = 5 }
        },

        ["hat"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_capasdsd", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_capasdsd", price = 5 }
        },

        ["glassess"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_glasses1", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_glasses1", price = 5 }
        },

        ["bandana"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_headbandana", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_headbandana", price = 5 }
        },

        ["bandana2"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_headbandana2", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_headbandana2", price = 5 }
        },

        ["tanker"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_tankerhelmet", price = 5 },
            [2] = { class = "ent_jack_gmod_ezarmor_tankerhelmet", price = 5 }
        },

        ["termal"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_thermals", price = 80 },
            [2] = { class = "ent_jack_gmod_ezarmor_thermals", price = 80 }
        },

        ["30002"] = {
            [1] = { class = "ent_jack_gmod_ezarmor_nvgs", price = 80 },
            [2] = { class = "ent_jack_gmod_ezarmor_nvgs", price = 80 }
        },

        ["ammo"]       = { [1] = { class = "ent_jack_gmod_ezammo", price = 60 }, [2] = { class = "ent_jack_gmod_ezammo", price = 60 } },
        ["rocketammo"] = { [1] = { class = "ent_jack_gmod_ezmunitions", price = 48 }, [2] = { class = "ent_jack_gmod_ezmunitions", price = 48 } },

        ["bandage"]    = { [1] = { class = "rapd_inventory_item_bandage", price = 5 }, [2] = { class = "rapd_inventory_item_bandage", price = 5 } },
        ["splint"]     = { [1] = { class = "rapd_inventory_item_splint", price = 5 }, [2] = { class = "rapd_inventory_item_splint", price = 5 } },
        ["ointment"]   = { [1] = { class = "rapd_inventory_item_burn_ointment", price = 5 }, [2] = { class = "rapd_inventory_item_burn_ointment", price = 5 } },
        ["surgerykit"] = { [1] = { class = "rapd_inventory_item_surgery_kit", price = 10 }, [2] = { class = "rapd_inventory_item_surgery_kit", price = 10 } },
        
        ["grenade"]    = { [1] = { class = "ent_jack_gmod_ezfragnade", price = 15 }, [2] = { class = "ent_jack_gmod_ezfragnade", price = 15 } },
        ["smoke"]      = { [1] = { class = "ent_jack_gmod_ezsmokenade", price = 10 }, [2] = { class = "ent_jack_gmod_ezsmokenade", price = 10 } },
        ["flash"]      = { [1] = { class = "ent_jack_gmod_ezflashbang", price = 10 }, [2] = { class = "ent_jack_gmod_ezflashbang", price = 10 } },

        ["satchel"]    = { [1] = { class = "ent_jack_gmod_ezsatchelcharge", price = 90 }, [2] = { class = "ent_jack_gmod_ezsatchelcharge", price = 90 } },
        ["c4"]         = { [1] = { class = "ent_jack_gmod_eztimebomb", price = 80 }, [2] = { class = "ent_jack_gmod_eztimebomb", price = 80 } },
        ["tnt"]        = { [1] = { class = "ent_jack_gmod_eztnt", price = 80 }, [2] = { class = "ent_jack_gmod_eztnt", price = 80 } },

        ["kutumermi"]         = { [1] = { class = "lvs_item_ammocrate", price = 80 }, [2] = { class = "lvs_item_ammocrate", price = 80 } },
        ["kutuarmor"]        = { [1] = { class = "ent_jack_gmod_eztnt", price = 100 }, [2] = { class = "ent_jack_gmod_eztnt", price = 100 } },

        ["dragonsteeth"]    = { [1] = { class = "ent_dragonstone", price = 30 }, [2] = { class = "ent_dragonstone", price = 30 } },
        ["hedgehog"]         = { [1] = { class = "ent_czechmetalthing", price = 30 }, [2] = { class = "ent_czechmetalthing", price = 30 } },
        ["wall"]        = { [1] = { class = "ent_sandbagwid", price = 30 }, [2] = { class = "ent_sandbagwid", price = 30 } },
        ["tallwall"]    = { [1] = { class = "ent_sandbagwidbig", price = 40 }, [2] = { class = "ent_sandbagwidbig", price = 40 } },
        ["corner"]         = { [1] = { class = "ent_sandbagwidcorner", price = 20 }, [2] = { class = "ent_sandbagwidcorner", price = 30 } },
        ["tallcorner"]        = { [1] = { class = "ent_sandbagwidcornerbig", price = 40 }, [2] = { class = "ent_sandbagwidcornerbig", price = 40 } },
       
        ["metalpanel"] = {
            [1] = { class = "prop_physics", model = "models/props_debris/metal_panel01a.mdl", price = 15 },
            [2] = { class = "prop_physics", model = "models/props_debris/metal_panel01a.mdl", price = 15 }
        },
        ["metalpanelkucuk"] = {
            [1] = { class = "prop_physics", model = "models/props_debris/metal_panel02a.mdl", price = 15 },
            [2] = { class = "prop_physics", model = "models/props_debris/metal_panel02a.mdl", price = 15 }
        },
        ["cabinet"] = {
            [1] = { class = "prop_physics", model = "models/props_wasteland/controlroom_filecabinet002a.mdl", price = 15 },
            [2] = { class = "prop_physics", model = "models/props_wasteland/controlroom_filecabinet002a.mdl", price = 15 }
        },
        ["cabinetbig"] = {
            [1] = { class = "prop_physics", model = "models/props_wasteland/controlroom_storagecloset001a.mdl", price = 20 },
            [2] = { class = "prop_physics", model = "models/props_wasteland/controlroom_storagecloset001a.mdl", price = 20 }
        },
        ["palet"] = {
            [1] = { class = "prop_physics", model = "models/props_junk/wood_pallet001a.mdl", price = 20 },
            [2] = { class = "prop_physics", model = "models/props_junk/wood_pallet001a.mdl", price = 20 }
        },
        ["crate"] = {
            [1] = { class = "prop_physics", model = "models/props_junk/wood_crate001a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_junk/wood_crate001a.mdl", price = 25 }
        },
        ["cratebig"] = {
            [1] = { class = "prop_physics", model = "models/props_junk/wood_crate002a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_junk/wood_crate002a.mdl", price = 25 }
        },
        ["metaldesk"] = {
            [1] = { class = "prop_physics", model = "models/props_wasteland/controlroom_desk001a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_wasteland/controlroom_desk001a.mdl", price = 25 }
        },
        ["tirebig"] = {
            [1] = { class = "prop_physics", model = "models/props_vehicles/apc_tire001.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_vehicles/apc_tire001.mdl", price = 25 }
        },
        ["tire"] = {
            [1] = { class = "prop_physics", model = "models/props_vehicles/tire001c_car.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_vehicles/tire001c_car.mdl", price = 25 }
        },
        ["shelf"] = {
            [1] = { class = "prop_physics", model = "models/props_forest/furniture_shelf01a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_forest/furniture_shelf01a.mdl", price = 25 }
        },
        ["table"] = {
            [1] = { class = "prop_physics", model = "models/props_c17/furnituretable003a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_c17/furnituretable003a.mdl", price = 25 }
        },
        ["belediye"] = {
            [1] = { class = "prop_physics", model = "models/props_wasteland/barricade001a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_wasteland/barricade001a.mdl", price = 25 }
        },
        ["radyator"] = {
            [1] = { class = "prop_physics", model = "models/props_interiors/Radiator01a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_interiors/Radiator01a.mdl", price = 25 }
        },
        ["dumpsterkapak"] = {
            [1] = { class = "prop_physics", model = "models/props_junk/TrashDumpster02b.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_junk/TrashDumpster02b.mdl", price = 25 }
        },
        ["breendesk"] = {
            [1] = { class = "prop_physics", model = "models/props_combine/breendesk.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_combine/breendesk.mdl", price = 25 }
        },
        ["tablebig"] = {
            [1] = { class = "prop_physics", model = "models/props_wasteland/cafeteria_table001a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_wasteland/cafeteria_table001a.mdl", price = 25 }
        },
        ["telkucuk"] = {
            [1] = { class = "prop_physics", model = "models/props_wasteland/interior_fence001g.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_wasteland/interior_fence001g.mdl", price = 25 }
        },
        ["telbuyuk"] = {
            [1] = { class = "prop_physics", model = "models/props_c17/fence01b.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_c17/fence01b.mdl", price = 25 }
        },
        ["pushcart"] = {
            [1] = { class = "prop_physics", model = "models/props_junk/PushCart01a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_junk/PushCart01a.mdl", price = 25 }
        },
        ["woodfence"] = {
            [1] = { class = "prop_physics", model = "models/props_wasteland/wood_fence02a.mdl", price = 25 },
            [2] = { class = "prop_physics", model = "models/props_junk/PushCart01a.mdl", price = 25 }
        },

    }

    local itemData = wpns[wpn][team]
    if not itemData then return end -- koruma amaçlı

    local price = itemData.price -- price, gidecek lojistik

    if team == 1 and targetedentity:GetClass() == "ent_logicrate" then 
        if IsValid(targetedentity) then --silah veya başka bişe varsa
            if logistic >= price then  --lojistik yetiyosa
                logistic = logistic - price -- azaltma yapıyoz
                targetedentity:SetLogisticAmountUkr(logistic) --yeni lojistik miktarını atama yapıyoz
                
                print("succesful new logistic: " .. logistic)
                print("team1")

                local weapon = ents.Create(itemData.class) --sonra spawn ediyoz işte
                if IsValid(weapon) then
                    weapon:SetPos(sentPos + Vector(0, 0, 60))
                    weapon:Spawn()
                    weapon:Activate()

                    local class = weapon:GetClass()
                    print("ukr")
                    
                    -- Eşya tipine göre kaynak belirleme
                    if class == "ent_jack_gmod_ezammo" then
                        weapon:SetResource(35) 
                    elseif class == "ent_jack_gmod_ezmunitions" then
                        weapon:SetResource(32)
                    else
                    return end
                end
            else
                -- Lojistik yetersizse burası çalışır
                print("Lojistik yetersiz")
            end
        end
    elseif team == 2 and targetedentity:GetClass() == "ent_logicrate_ussr" then
        if IsValid(targetedentity) then
            if logistic >= price then  --lojistik yetiyosa
                logistic = logistic - price -- azaltma yapıyoz
                targetedentity:SetLogisticAmountRus(logistic) --yeni lojistik miktarını atama yapıyoz
                
                print("succesful new logistic: " .. logistic)
                print("team2")
                local weapon = ents.Create(itemData.class) --sonra spawn ediyoz işte
                if IsValid(weapon) then
                    weapon:SetPos(sentPos + Vector(0,0,60))
                    weapon:Spawn()
                    weapon:Activate()

                    local class = weapon:GetClass()
                    print("rus")
                    
                    -- Eşya tipine göre kaynak belirleme
                    if class == "ent_jack_gmod_ezammo" then
                        weapon:SetResource(35) 
                    elseif class == "ent_jack_gmod_ezmunitions" then
                        weapon:SetResource(32)
                    elseif class == "prop_physics" then
                        weapon:SetModel(itemData.model)
                    else
                    return end
                end
            else
                -- Lojistik yetersizse burası çalışır
                print("Lojistik yetersiz")
            end
        end
    elseif team == 1 and targetedentity:GetClass() == "ent_armorcrate" then 
        if IsValid(targetedentity) then --silah veya başka bişe varsa
            if logistic >= price then  --lojistik yetiyosa
                logistic = logistic - price -- azaltma yapıyoz
                targetedentity:SetarmorUKRLogisticAmount(logistic) --yeni lojistik miktarını atama yapıyoz
                
                print("succesful new logistic: " .. logistic)
                print("team1")

                local weapon = ents.Create(itemData.class) --sonra spawn ediyoz işte
                if IsValid(weapon) then
                    weapon:SetPos(sentPos + Vector(0, 0, 60))
                    weapon:Spawn()
                    weapon:Activate()

                    local class = weapon:GetClass()
                    print("ukr")
                    
                    -- Eşya tipine göre kaynak belirleme
                    if class == "ent_jack_gmod_ezammo" then
                        weapon:SetResource(35) 
                    elseif class == "ent_jack_gmod_ezmunitions" then
                        weapon:SetResource(32)
                    else
                    return end
                end
            else
                -- Lojistik yetersizse burası çalışır
                print("Lojistik yetersiz")
            end
        end
    elseif team == 2 and targetedentity:GetClass() == "ent_armorcrate_ussr" then 
        if IsValid(targetedentity) then --silah veya başka bişe varsa
            if logistic >= price then  --lojistik yetiyosa
                logistic = logistic - price -- azaltma yapıyoz
                targetedentity:SetarmorRUSLogisticAmount(logistic) --yeni lojistik miktarını atama yapıyoz
                
                print("succesful new logistic: " .. logistic)
                print("team1")

                local weapon = ents.Create(itemData.class) --sonra spawn ediyoz işte
                if IsValid(weapon) then
                    weapon:SetPos(sentPos + Vector(0, 0, 60))
                    weapon:Spawn()
                    weapon:Activate()

                    local class = weapon:GetClass()
                    print("rus")
                    
                    -- Eşya tipine göre kaynak belirleme
                    if class == "ent_jack_gmod_ezammo" then
                        weapon:SetResource(35) 
                    elseif class == "ent_jack_gmod_ezmunitions" then
                        weapon:SetResource(32)
                    else
                    return end
                end
            else
                -- Lojistik yetersizse burası çalışır
                print("Lojistik yetersiz")
            end
        end
    else
        if IsValid(targetedentity) then
            if logistic >= price then  --lojistik yetiyosa
                logistic = logistic - price -- azaltma yapıyoz
                targetedentity:SetbuildLogisticAmount(logistic) --yeni lojistik miktarını atama yapıyoz
                
                print("succesful new logistic: " .. logistic)
                print("bos")

                local weapon = ents.Create(itemData.class) --sonra spawn ediyoz işte
                if IsValid(weapon) then
                    local class = weapon:GetClass()
                    print("none")
                    -- Eşya tipine göre kaynak belirleme
                    if class == "ent_jack_gmod_ezammo" then
                        weapon:SetResource(35) 
                    elseif class == "ent_jack_gmod_ezmunitions" then
                        weapon:SetResource(32)
                    elseif class == "prop_physics" then
                        print(itemData.model)
                        weapon:SetModel(itemData.model)
                    end
                    weapon:SetPos(sentPos + Vector(0,0,60))
                    weapon:Spawn()
                    weapon:Activate()
                end
            else
                -- Lojistik yetersizse burası çalışır
                print("Lojistik yetersiz")
            end
        end
    end
end