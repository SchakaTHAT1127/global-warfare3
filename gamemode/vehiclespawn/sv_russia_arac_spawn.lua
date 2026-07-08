print("sv_russia_arac_spawn")
--print(sv_ukrainetruckamount:GetInt())
-- peremen 3 ukrayna koordinatlarına göre hazırlandı 
-- render.DrawSphere diye bir şey var. güzel. kullanılabilir.

entAraclarRusya = {
    ["kamyon"] = { class = "sw_ural4320", getMiktar = function() return cv_kamyonMiktarRus:GetInt() end, getCooldown = function() return cv_kamyonCooldownRus:GetInt() end, ticket = 15 },
    ["transport"] = { class = "sw_gaz2330", getMiktar = function() return cv_transportMiktarRus:GetInt() end, getCooldown = function() return cv_transportCooldownRus:GetInt() end, ticket = 12 },
    ["zirhli"] = { class = "sw_btr82", getMiktar = function() return cv_zirhliMiktarRus:GetInt() end, getCooldown = function() return cv_zirhliCooldownRus:GetInt() end, ticket = 30 }
}

local SunucuMapi = game.GetMap()

local MaplerVeKoordinatlar = {
    ["gw_peremen3"] = { pos = Vector(-14322.014648, -2026.330566, -767.968750), ang = Angle(0, 90, 0) },
    ["prm_hrabske"] = { pos = Vector(-14322.014648, -2026.330566, -767.968750), ang = Angle(0, 90, 0) },
    ["prm_molodoy"] = { pos = Vector(-14322.014648, -2026.330566, -767.968750), ang = Angle(0, 90, 0) }
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

local function SpawnVehicleRusyaInitial()
    -- Döngü içinde ne kadar kaydırma yaptığımızı temiz bir şekilde takip etmek için
    local aktifOffset = 0 

    for name, data in pairs(entAraclarRusya) do
        for i = 1, entAraclarRusya[name].getMiktar() do
            local GeciciPosRus = Vector(AracCord.pos.x, AracCord.pos.y, AracCord.pos.z)
            
            GeciciPosRus.y = GeciciPosRus.y + aktifOffset

            while not KordinatBos(GeciciPosRus) do
                GeciciPosRus.y = GeciciPosRus.y + 300
                aktifOffset = aktifOffset + 300
            end

            -- Aracı oluşturma
            local vehicleRus = ents.Create(data.class)
            if IsValid(vehicleRus) then
                vehicleRus:SetPos(GeciciPosRus)
                vehicleRus:SetAngles(AracCord.ang)
                vehicleRus:Spawn()
                vehicleRus:Activate()
                
                print(name .. " başarıyla doğuruldu. Pozisyon: " .. tostring(GeciciPosRus))
            end

            aktifOffset = aktifOffset + 300
        end
    end
end

local function SpawnVehicleRusya(entityClass)
    if not AracCord or not entityClass then return end

    local GeciciPosRus = Vector(AracCord.pos.x, AracCord.pos.y, AracCord.pos.z)

    while not KordinatBos(GeciciPosRus) do
        GeciciPosRus.y = GeciciPosRus.y + 300
        ACseferSayisi = ACseferSayisi + 1
    end

    local vehicleRus = ents.Create(entityClass)
    if IsValid(vehicleRus) then
        vehicleRus:SetPos(GeciciPosRus)
        vehicleRus:SetAngles(AracCord.ang)
        vehicleRus:Spawn()
        vehicleRus:Activate()
    end

    ACseferSayisi = ACseferSayisi * 300
    GeciciPosRus.y = GeciciPosRus.y - ACseferSayisi
    ACseferSayisi = 0
end

hook.Add("AracPatladi", "AracPatladiZamanlayiciCalistir2", function(entityClass, teamID)
    for name, _ in pairs(entAraclarRusya) do
        if entityClass == entAraclarRusya[name].class then
            local entCooldown = entAraclarRusya[name].getCooldown()
            -- HATA DÜZELTMESİ: SpawnVehicleRusya fonksiyonuna hangi sınıfın doğacağını (entityClass) parametre olarak göndermiyordun.
            timer.Simple(entCooldown, function()
                SpawnVehicleRusya(entityClass)
            end)
        end
    end
end)

local function YazdiriciTester()
    for name, _ in pairs(entAraclarRusya) do
        print("\n"..name)
        for k, v in pairs(entAraclarRusya[name]) do
            print(k, v)   
        end
    end
end

hook.Add( "Initialize", "SpawnVehicleRusyaInitialize", function()
    timer.Simple(3, function()
        print("İNİTİALİZE RUSSSİ")
        print("İNİTİALİZE RUSSSİ")
        print("İNİTİALİZE RUSSSİ")
        print("İNİTİALİZE RUSSSİ")
        print("İNİTİALİZE RUSSSİ")
        print("İNİTİALİZE RUSSSİ")
        print("İNİTİALİZE RUSSSİ")
        print("İNİTİALİZE RUSSSİ")
        print("İNİTİALİZE RUSSSİ")
        SpawnVehicleRusyaInitial()
    end)
end )