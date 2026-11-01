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
    ["wid_peremen"] = { pos = Vector(12156.296875, -13695.033203 ,-47.973808), ang = Angle(0, 90, 0) },
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

function SpawnVehicleUkraynaInitial()

    -- Döngü içinde ne kadar kaydırma yaptığımızı temiz bir şekilde takip etmek için
    local aktifOffset = 0 

    for name, data in pairs(entAraclarUkrayna) do
        for i = 1, entAraclarUkrayna[name].getMiktar() do
            local GeciciPosUkr = Vector(AracCord.pos.x, AracCord.pos.y, AracCord.pos.z)
            
            GeciciPosUkr.y = GeciciPosUkr.y + aktifOffset

            while not KordinatBos(GeciciPosUkr) do
                GeciciPosUkr.y = GeciciPosUkr.y + 300
                aktifOffset = aktifOffset + 300
            end

            -- Aracı oluşturma
            local vehicleUkr = ents.Create(data.class)
            if IsValid(vehicleUkr) then
                vehicleUkr:SetNW2Int("GW3Team", 1)
                vehicleUkr:SetPos(GeciciPosUkr)
                vehicleUkr:SetAngles(AracCord.ang)
                vehicleUkr:Spawn()
                vehicleUkr:Activate()
                
            end

            aktifOffset = aktifOffset + 300
        end
    end
end

local function SpawnVehicleUkrayna(entityClass)
    if not AracCord or not entityClass then 
    return end

    local GeciciPosUkr = Vector(AracCord.pos.x, AracCord.pos.y, AracCord.pos.z)

    while not KordinatBos(GeciciPosUkr) do
        GeciciPosUkr.y = GeciciPosUkr.y + 300
        ACseferSayisi = ACseferSayisi + 1
    end

    local vehicleUkr = ents.Create(entityClass)
    if IsValid(vehicleUkr) then
        vehicleUkr:SetNW2Int("GW3Team", 1)
                vehicleUkr:SetPos(GeciciPosUkr)
        vehicleUkr:SetAngles(AracCord.ang)
        vehicleUkr:Spawn()
        vehicleUkr:Activate()
    end

    ACseferSayisi = ACseferSayisi * 300
    GeciciPosUkr.y = GeciciPosUkr.y - ACseferSayisi
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
        for k, v in pairs(entAraclarUkrayna[name]) do
        end
    end
end
--[[
hook.Add( "Initialize", "SpawnVehicleUkraynaInitialize", function()
    timer.Simple(3, function()
        print("İNİTİALİZE UKRAİN")
        SpawnVehicleUkraynaInitial()
    end)
end )]]