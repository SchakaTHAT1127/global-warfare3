print("sv_arac ready")

local nato_arac_amount = 2
local ussr_arac_amount = 1

local function spawnAracNato(amount)
    local amount = math.Clamp(math.Round(amount), 1, 4)
    if game.GetMap() == "gm_flatgrass" then
        koordinatlar = {
            { pos = Vector(1339.31, -1573.69, -12746), ang = Angle(0, 90, 0) },
            { pos = Vector(1339.31, -1773.69, -12746), ang = Angle(0, 90, 0) },
            { pos = Vector(1339.31, -1973.69, -12746), ang = Angle(0, 90, 0) },
            { pos = Vector(1339.31, -2273.69, -12746), ang = Angle(0, 90, 0) }
        }
    elseif game.GetMap() == "gm_construct" then
        koordinatlar = {
            { pos = Vector(93.900665, 325.030579, -89), ang = Angle(0, 90, 0) },
            { pos = Vector(93.900665, 825.030579, -89), ang = Angle(0, 90, 0) },
            { pos = Vector(93.900665, 1425.030579, -89), ang = Angle(0, 90, 0) },
            { pos = Vector(93.900665, 1825.030579, -89), ang = Angle(0, 90, 0) }
        }
    end

    print("[Sistem] " .. amount .. " adet araç spawn ediliyor...")
    if #koordinatlar == 0 then 
        print("[Hata] Bu harita için koordinat tanımlanmamış!")
        return 
    end
    print("[Sistem] " .. amount .. " adet araç spawn ediliyor...")

    for i = 1, amount do
        local nokta = koordinatlar[i]
        if not nokta then continue end
        
        local car = ents.Create("lvs_wheeldrive_dodwillyjeep")
        if not IsValid(car) then continue end 

        car:SetPos(nokta.pos)
        car:SetAngles(nokta.ang)
        car:Spawn()
        car:Activate()
    end
end

--

local function spawnAracUssr(amount)
    local amount = math.Clamp(math.Round(amount), 1, 4)
    local koordinatlar = {}

    if game.GetMap() == "gm_flatgrass" then
        koordinatlar = {
            { pos = Vector(1339.31, -1573.69, -12746), ang = Angle(0, 90, 0) },
            { pos = Vector(1339.31, -1773.69, -12746), ang = Angle(0, 90, 0) },
            { pos = Vector(1339.31, -1973.69, -12746), ang = Angle(0, 90, 0) },
            { pos = Vector(1339.31, -2273.69, -12746), ang = Angle(0, 90, 0) }
        }
    elseif game.GetMap() == "gm_construct" then
        koordinatlar = {
            { pos = Vector(93.900665, 325.030579, -89), ang = Angle(0, 90, 0) },
            { pos = Vector(93.900665, 825.030579, -89), ang = Angle(0, 90, 0) },
            { pos = Vector(93.900665, 1425.030579, -89), ang = Angle(0, 90, 0) },
            { pos = Vector(93.900665, 1825.030579, -89), ang = Angle(0, 90, 0) }
        }
    end

    if #koordinatlar == 0 then 
        print("[Hata] Bu harita için koordinat tanımlanmamış!")
        return 
    end

    print("[Sistem] " .. amount .. " adet araç spawn ediliyor...")

    for i = 1, amount do
        local nokta = koordinatlar[i]
        if not nokta then continue end
        
        local car = ents.Create("sw_uaz469")
        if not IsValid(car) then continue end 

        car:SetPos(nokta.pos)
        car:SetAngles(nokta.ang)
        car:Spawn()
        car:Activate()
    end
end

concommand.Add("nato_arac_amount", function(ply, cmd, args)
    nato_arac_amount = tonumber(args[1]) or 1
    if nato_arac_amount > 4 then
        print("The NATO vehicle number cant be higher than 4")
    return end
    print("[HQ] " .. nato_arac_amount .. " vehicles have been sended to your forward operating base.")
end)
concommand.Add("nato_arac_spawn", function()
    spawnAracNato(nato_arac_amount)
end)

--

concommand.Add("ussr_arac_amount", function(ply, cmd, args)
    ussr_arac_amount = tonumber(args[1]) or 1
    if ussr_arac_amount > 4 then
        print("The USSR vehicle number cant be higher than 4")
    return end
    print("[HQ] " .. ussr_arac_amount .. " vehicle have been sended to your forward operating base.")
end)
concommand.Add("ussr_arac_spawn", function()
    spawnAracUssr(ussr_arac_amount) 
end)