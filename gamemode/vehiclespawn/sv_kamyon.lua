print("sv_kamyon ready")

local nato_truck_amount = 1 
local ussr_truck_amount = 2

local function spawnKamyonUkrayna(amount)
    local amount = math.Clamp(math.Round(amount), 1, 2)
    if game.GetMap() == "gw_peremen3" then
        koordinatlar = {
            { pos = Vector(9332.324219, -11245.651367, -47.968750), ang = Angle(0, 180, 0) },
            { pos = Vector(9632.324219, -11245.651367, -47.968750), ang = Angle(0, 180, 0) },
            { pos = Vector(9932.324219, -11245.651367, -47.968750), ang = Angle(0, 180, 0) }
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
        
        local car = ents.Create("sw_gaz66")
        if not IsValid(car) then continue end 

        car:SetPos(nokta.pos)
        car:SetAngles(nokta.ang)
        car:Spawn()
        car:Activate()
    end
end

--

local function spawnKamyonRusya(amount)
    local amount = math.Clamp(math.Round(amount), 1, 3)
    local koordinatlar = {}

    if game.GetMap() == "gw_peremen3" then
        koordinatlar = {
            { pos = Vector(9332.324219, -11245.651367, -47.968750), ang = Angle(0, 180, 0) },
            { pos = Vector(9632.324219, -11245.651367, -47.968750), ang = Angle(0, 180, 0) }
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
        
        local car = ents.Create("sw_ural4320")
        if not IsValid(car) then continue end 

        car:SetPos(nokta.pos)
        car:SetAngles(nokta.ang)
        car:Spawn()
        car:Activate()
    end
end

concommand.Add("nato_truck_amount", function(ply, cmd, args)
    nato_truck_amount = tonumber(args[1]) or 1
    if nato_truck_amount > 3 then
        print("The NATO truck number cant be higher than 3")
    return end
    print("[HQ] " .. nato_truck_amount .. " trucks have been sended to your forward operating base.")
end)
concommand.Add("nato_truck_spawn", function()
    spawnKamyonUkrayna(nato_truck_amount)
end)

--

concommand.Add("ussr_truck_amount", function(ply, cmd, args)
    ussr_truck_amount = tonumber(args[1]) or 1
    if ussr_truck_amount > 2 then
        print("The USSR truck number cant be higher than 2")
    return end
    print("[HQ] " .. ussr_truck_amount .. " trucks have been sended to your forward operating base.")
end)
concommand.Add("ussr_truck_spawn", function()
    spawnKamyonRusya(ussr_truck_amount) 
end)