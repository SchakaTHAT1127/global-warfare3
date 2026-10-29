-- Global Warfare 3 - logistics/build crate spawner
-- Reads ConVars at runtime so this file can be included before cvars.lua finishes loading.

GW3 = GW3 or {}

local LOGI_CLASS_UKR = "ent_logicrate"
local BUILD_CLASS = "ent_buildcrate"
local SPAWN_STEP = 60
local MAX_SEARCH_ATTEMPTS = 100

local MaplerVeKoordinatlar = {
    ["wid_peremen"] = {
        pos = Vector(13082.137695, -13277.175781, -25.96875),
        ang = Angle(0, 180, 0)
    }
}

local Kordinat = MaplerVeKoordinatlar[game.GetMap()]

local tabla = {
    [1] = { logiSayisi = 2, buildSayisi = 1 },
    [2] = { logiSayisi = 3, buildSayisi = 2 },
    [3] = { logiSayisi = 4, buildSayisi = 2 }
}

local allowedCrateClasses = {
    [LOGI_CLASS_UKR] = true,
    [BUILD_CLASS] = true
}

local function GetSpawnSettings()
    local convar = GetConVar("sv_givelogistic")
    local level = convar and convar:GetInt() or 1
    local settings = tabla[level]

    if not settings then
        print("[GW3] sv_givelogistic gecersiz; varsayilan seviye 1 kullaniliyor.")
        settings = tabla[1]
    end

    return settings
end

-- A crate or vehicle already near this position makes the position unavailable.
local function KordinatBos(pos)
    if not pos then return false end

    for _, ent in ipairs(ents.FindInSphere(pos, 20)) do
        if IsValid(ent) then
            local class = ent:GetClass()
            if ent:IsVehicle() or allowedCrateClasses[class] then
                return false
            end
        end
    end

    return true
end

local function FindFreePosition(startPos, axis)
    if not startPos then return nil end

    for attempt = 0, MAX_SEARCH_ATTEMPTS do
        local offset = attempt * SPAWN_STEP
        local pos = Vector(startPos.x, startPos.y, startPos.z)

        if axis == "y" then
            pos.y = pos.y + offset
        else
            pos.x = pos.x + offset
        end

        if KordinatBos(pos) then
            return pos
        end
    end

    print("[GW3] Lojistik kutusu icin bos spawn noktasi bulunamadi.")
    return nil
end

local function SpawnCrate(class, pos)
    if not allowedCrateClasses[class] or not pos then return false end

    local crate = ents.Create(class)
    if not IsValid(crate) then
        print("[GW3] Kutu olusturulamadi: " .. tostring(class))
        return false
    end

    crate:SetPos(pos)
    crate:SetAngles(Kordinat and Kordinat.ang or Angle(0, 0, 0))
    crate:Spawn()
    crate:Activate()
    return true
end

local function SpawnInitialGroup(class, count, activeOffset)
    activeOffset = activeOffset or 0

    for _ = 1, count do
        local startPos = Vector(
            Kordinat.pos.x + activeOffset,
            Kordinat.pos.y,
            Kordinat.pos.z
        )
        local spawnPos = FindFreePosition(startPos, "x")
        if not spawnPos then break end
        if not SpawnCrate(class, spawnPos) then break end

        activeOffset = spawnPos.x - Kordinat.pos.x + SPAWN_STEP
    end

    return activeOffset
end

-- Called by gamemode/init.lua after the map entities have initialized.
function SpawnVehicleLogiInitial()
    if not Kordinat then
        print("[GW3] Bu harita icin lojistik spawn koordinati yok: " .. game.GetMap())
        return
    end

    local settings = GetSpawnSettings()
    local activeOffset = SpawnInitialGroup(LOGI_CLASS_UKR, settings.logiSayisi, 0)

    -- buildSayisi was previously calculated but never used; spawn those crates too.
    SpawnInitialGroup(BUILD_CLASS, settings.buildSayisi, activeOffset)
end

local function SpawnVehicleLogi(entityClass)
    if not Kordinat then return end

    local class = entityClass or LOGI_CLASS_UKR
    if not allowedCrateClasses[class] then
        print("[GW3] Bilinmeyen lojistik kutusu sinifi, respawn atlandi: " .. tostring(class))
        return
    end

    local spawnPos = FindFreePosition(Kordinat.pos, "x")
    if not spawnPos then return end
    SpawnCrate(class, spawnPos)
end

-- Depleted logistics/build crates announce their class so the correct crate respawns.
hook.Add("logistikcrateBitti", "GW3_RespawnLogiCrate", function(entityClass)
    timer.Simple(300, function()
        SpawnVehicleLogi(entityClass)
    end)
end)
