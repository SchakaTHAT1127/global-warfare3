
-- ekliyoruz
AddCSLuaFile("cl_logispawner.lua")
AddCSLuaFile("globalwarfare3/gamemode/shared.lua")

GW3 = GW3 or {}

local logicrate = "ent_logicrate"
local buildcrate = "ent_buildcrate"

local logiOran = cv_giveLogistic:GetInt()
local logiSayisi = nil
local buildSayisi = nil

local SunucuMapi = game.GetMap()

local MaplerVeKoordinatlar = {
    ["wid_peremen"] = {
        pos = Vector(13082.137695, -13277.175781, -25.96875),
        ang = Angle(0, 180, 0)
    },
}

local Kordinat = MaplerVeKoordinatlar[SunucuMapi]
local LSseferSayisi = 0

local tabla = {
    [1] = { logiSayisi = 2, buildSayisi = 1 },
    [2] = { logiSayisi = 3, buildSayisi = 2 },
    [3] = { logiSayisi = 4, buildSayisi = 2 }
}

-- Koordinatın araç oluşturmak için boş olup olmadığını kontrol eder
local function KordinatBos(pos)
    if not pos then return false end

    local finderSphere = ents.FindInSphere(pos, 120)

    for _, ent in pairs(finderSphere) do
        if IsValid(ent) and ent:IsVehicle() then
            return false
        end
    end

    return true
end

-- Başlangıç lojistik araçlarını oluşturur
function SpawnVehicleLogiInitial()
    if not Kordinat then
        return
    end

    local ayarlar = tabla[logiOran]

    if not ayarlar then
        return
    end

    logiSayisi = ayarlar.logiSayisi
    buildSayisi = ayarlar.buildSayisi

    local aktifOffset = 0

    for i = 1, logiSayisi do
        local GeciciPosUkr = Vector(
            Kordinat.pos.x + aktifOffset,
            Kordinat.pos.y,
            Kordinat.pos.z
        )

        while not KordinatBos(GeciciPosUkr) do
            GeciciPosUkr.x = GeciciPosUkr.x + 60
        end

        local vehicleUkr = ents.Create(logicrate)

        if IsValid(vehicleUkr) then
            vehicleUkr:SetPos(GeciciPosUkr)
            vehicleUkr:SetAngles(Kordinat.ang)
            vehicleUkr:Spawn()
            vehicleUkr:Activate()
        else
        end

        aktifOffset = aktifOffset + 60
    end
end

local function SpawnVehicleLogi(entityClass)
    if not Kordinat or not entityClass then
        return
    end

    local GeciciPosUkr = Vector(
        Kordinat.pos.x,
        Kordinat.pos.y,
        Kordinat.pos.z
    )

    while not KordinatBos(GeciciPosUkr) do
        GeciciPosUkr.x = GeciciPosUkr.x + 60
        LSseferSayisi = LSseferSayisi + 1
    end

    local vehicleUkr = ents.Create(logicrate)

    if IsValid(vehicleUkr) then
        vehicleUkr:SetPos(GeciciPosUkr)
        vehicleUkr:SetAngles(Kordinat.ang)
        vehicleUkr:Spawn()
        vehicleUkr:Activate()
    else
    end
    LSseferSayisi = 0
end

-- Lojistik kasası bittiğinde yeni araç oluşturur
hook.Add("logistikcrateBitti", "logicrateBitti", function(entityClass)
    local entCooldown = 1

    timer.Simple(entCooldown, function()
        SpawnVehicleLogi(entityClass)
    end)
end)
--[[
hook.Add( "Initialize", "SpawnVehicleLogiInitialize", function()
    timer.Simple(3, function()
        print("İNİTİALİZE kutu")
        SpawnVehicleLogiInitial()
    end)
end )
]]