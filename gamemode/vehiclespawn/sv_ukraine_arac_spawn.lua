print("sv_ukraine_arac_spawn")
--print(sv_ukrainetruckamount:GetInt())
-- peremen 3 ukrayna koordinatlarına göre hazırlandı 
-- render.DrawSphere diye bir şey var. güzel. kullanılabilir.

entAraclarUkrayna = {
    ["kamyon"] = { class = "sw_gaz66", getMiktar = function() return cv_kamyonMiktarUkr:GetInt() end, getCooldown = function() return cv_kamyonCooldownUkr:GetInt() end, ticket = 10 },
    ["transport"] = { class = "sw_uaz469", getMiktar = function() return cv_transportMiktarUkr:GetInt() end, getCooldown = function() return cv_transportCooldownUkr:GetInt() end, ticket = 10 },
    ["zirhli"] = { class = "sw_btr60", getMiktar = function() return cv_zirhliMiktarUkr:GetInt() end, getCooldown = function() return cv_zirhliCooldownUkr:GetInt() end, ticket = 20 }
}

local SunucuMapi = game.GetMap()

local MaplerVeKoordinatlar = {
    ["wid_peremen"] = { pos = Vector(9332, -11245, -47), ang = Angle(0, 180, 0) },
    ["prm_hrabske"] = { pos = Vector(9332, -11245, -47), ang = Angle(0, 180, 0) },
    ["prm_molodoy"] = { pos = Vector(9332, -11245, -47), ang = Angle(0, 180, 0) }
}

local AracCord = MaplerVeKoordinatlar[SunucuMapi] 
local ACseferSayisi = 0

-- HATA DÜZELTMESİ: Fonksiyonun çalışabilmesi için pos parametresi eklenmeliydi.
local function KordinatBos(pos)
    if not pos then return false end -- Çökme koruması
    local finderSphere = ents.FindInSphere(pos, 120)
    for id, ent in pairs(finderSphere) do
        if ent:IsVehicle() then
            return false
        end
    end
    return true
end

local function SpawnVehicleUkraynaInitial()

    -- Döngü içinde ne kadar kaydırma yaptığımızı temiz bir şekilde takip etmek için
    local aktifOffset = 0 

    for name, data in pairs(entAraclarUkrayna) do
        for i = 1, entAraclarUkrayna[name].getMiktar() do
            local GeciciPosUkr = Vector(AracCord.pos.x, AracCord.pos.y, AracCord.pos.z)
            
            GeciciPosUkr.x = GeciciPosUkr.x + aktifOffset

            while not KordinatBos(GeciciPosUkr) do
                GeciciPosUkr.x = GeciciPosUkr.x + 300
                aktifOffset = aktifOffset + 300
            end

            -- Aracı oluşturma
            local vehicleUkr = ents.Create(data.class)
            if IsValid(vehicleUkr) then
                vehicleUkr:SetPos(GeciciPosUkr)
                vehicleUkr:SetAngles(AracCord.ang)
                vehicleUkr:Spawn()
                vehicleUkr:Activate()
                
                print(name .. " başarıyla doğuruldu. Pozisyon: " .. tostring(GeciciPosUkr))
            end

            aktifOffset = aktifOffset + 300
        end
    end
end

local function SpawnVehicleUkrayna(entityClass)
    if not AracCord or not entityClass then 
        print("HATA VAR")
    return end

    local GeciciPosUkr = Vector(AracCord.pos.x, AracCord.pos.y, AracCord.pos.z)

    while not KordinatBos(GeciciPosUkr) do
        GeciciPosUkr.x = GeciciPosUkr.x + 300
        ACseferSayisi = ACseferSayisi + 1
    end

    local vehicleUkr = ents.Create(entityClass)
    if IsValid(vehicleUkr) then
        vehicleUkr:SetPos(GeciciPosUkr)
        vehicleUkr:SetAngles(AracCord.ang)
        vehicleUkr:Spawn()
        vehicleUkr:Activate()
    end

    ACseferSayisi = ACseferSayisi * 300
    GeciciPosUkr.x = GeciciPosUkr.x - ACseferSayisi
    ACseferSayisi = 0
end

hook.Add("AracPatladi", "AracPatladiZamanlayiciCalistir", function(entityClass, teamID)
    for name, _ in pairs(entAraclarUkrayna) do
        if entityClass == entAraclarUkrayna[name].class then
            local entCooldown = entAraclarUkrayna[name].getCooldown()
            -- HATA DÜZELTMESİ: SpawnVehicleUkrayna fonksiyonuna hangi sınıfın doğacağını (entityClass) parametre olarak göndermiyordun.
            timer.Simple(entCooldown, function()
                SpawnVehicleUkrayna(entityClass)
            end)
        end
    end
end)

local function YazdiriciTester()
    for name, _ in pairs(entAraclarUkrayna) do
        print("\n"..name)
        for k, v in pairs(entAraclarUkrayna[name]) do
            print(k, v)   
        end
    end
end

hook.Add( "Initialize", "SpawnVehicleUkraynaInitialize", function()
    timer.Simple(3, function()
        print("İNİTİALİZE UKRAİN")
        print("İNİTİALİZE UKRAİN")
        print("İNİTİALİZE UKRAİN")
        print("İNİTİALİZE UKRAİN")
        print("İNİTİALİZE UKRAİN")
        print("İNİTİALİZE UKRAİN")
        print("İNİTİALİZE UKRAİN")
        print("İNİTİALİZE UKRAİN")
        print("İNİTİALİZE UKRAİN")
        SpawnVehicleUkraynaInitial()
    end)
end )