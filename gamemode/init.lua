-- bütün cl ve sv dosyalarını ekliyoruz
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("vgui/cl_menu.lua")
AddCSLuaFile("vgui/cl_briefingmap.lua")
AddCSLuaFile("vgui/cl_winnermenu.lua")
AddCSLuaFile("vgui/cl_teampanel.lua")
AddCSLuaFile("vgui/cl_tabmenu.lua")
AddCSLuaFile("sounds/cl_soundpr.lua")
AddCSLuaFile("logihandler/cl_logihandler.lua")
AddCSLuaFile("cratehints/cl_cratehints.lua")
AddCSLuaFile("capturesys/cl_capturesys.lua")
AddCSLuaFile("player/cl_playercustomization.lua")
AddCSLuaFile("shared.lua")

include("logispawner/sv_logispawner_ussr.lua")
include("logispawner/sv_logispawner.lua")
include("logihandler/sv_logihandler.lua")
include("shared.lua") 
include("map/sv_mapbriefing.lua")
include("player/sv_playercustomization.lua")
include("vgui/sv_menu.lua")
include("cvars.lua")
include("capturesys/sv_capturesys.lua")
include("jmodcompat/sv_jmodcompat.lua")

include("vehiclespawn/sv_ukraine_arac_spawn.lua")
include("vehiclespawn/sv_russia_arac_spawn.lua")

include("ticketsys/sv_ticketsystem.lua")

--Ana oyunmodunu seçiyoz
DeriveGamemode("sandbox")

--Bunu yazaraktan basit bir şekilde tüm takımları tek bir rakama sığdırıyorum
-- bu sayede bazı durumlardaw işim daha kolaylaşıyor
UKR = 1
RUS = 2
GW3 = GW3 or {}
cv_kamyonMiktarUkr = GetConVar("sv_ukrainetruckamount")
cv_kamyonCooldownUkr = GetConVar("sv_ukrainetruckcooldown")
cv_transportMiktarUkr = GetConVar("sv_ukrainecaramount")
cv_transportCooldownUkr = GetConVar("sv_ukrainecarcooldown")
cv_zirhliMiktarUkr = GetConVar("sv_ukraineapcamount")
cv_zirhliCooldownUkr = GetConVar("sv_ukraineapccooldown")


entAraclarUkrayna = {
    ["kamyon"] = { class = "sw_gaz66", getMiktar = function() return cv_kamyonMiktarUkr:GetInt() end, getCooldown = function() return cv_kamyonCooldownUkr:GetInt() end, ticket = 10 },
    ["transport"] = { class = "sw_uaz469", getMiktar = function() return cv_transportMiktarUkr:GetInt() end, getCooldown = function() return cv_transportCooldownUkr:GetInt() end, ticket = 10 },
    ["zirhli"] = { class = "sw_btr60", getMiktar = function() return cv_zirhliMiktarUkr:GetInt() end, getCooldown = function() return cv_zirhliCooldownUkr:GetInt() end, ticket = 20 }
}

cv_kamyonMiktarRus = GetConVar("sv_russiatruckamount")
cv_kamyonCooldownRus = GetConVar("sv_russiatruckcooldown")
cv_transportMiktarRus = GetConVar("sv_russiacaramount")
cv_transportCooldownRus = GetConVar("sv_russiacarcooldown")
cv_zirhliMiktarRus = GetConVar("sv_russiaapcamount")
cv_zirhliCooldownRus = GetConVar("sv_russiaapccooldown")

entAraclarRusya = {
    ["kamyon"] = { class = "sw_ural4320", getMiktar = function() return cv_kamyonMiktarRus:GetInt() end, getCooldown = function() return cv_kamyonCooldownRus:GetInt() end, ticket = 15 },
    ["transport"] = { class = "sw_gaz2330", getMiktar = function() return cv_transportMiktarRus:GetInt() end, getCooldown = function() return cv_transportCooldownRus:GetInt() end, ticket = 12 },
    ["zirhli"] = { class = "sw_btr82", getMiktar = function() return cv_zirhliMiktarRus:GetInt() end, getCooldown = function() return cv_zirhliCooldownRus:GetInt() end, ticket = 30 }
}
local tablokordinat = {
    [1] = Vector(13709.390625, -12585.013672, -25.968750),
    [2] = Vector(13660, -12585.013672, -25.968750),
    [3] = Vector(-12995.333984, -2457.724365, -719.372742),
    [4] = Vector(-12976.097656, -2393.263184, -719.372742)
}
cv_ticketUkr = GetConVar("sv_ukraineticket")
cv_ticketRus = GetConVar("sv_russiaticket")

cv_giveLogistic = GetConVar("sv_givelogistic")
cv_giveArmorFirstSpawn = GetConVar("sv_armoratfirst")

UKRticket = cv_ticketUkr:GetInt()
RUSticket = cv_ticketRus:GetInt()

-- Takımlar:
team.SetUp(UKR, "Ukrainian Ground Forces", Color(0, 33, 203))
team.SetUp(RUS, "Russian Ground Forces", Color(223, 8, 8))

-- Oyuncunun kendisini öldürmesini yasaklayıp yasaklamamak
hook.Add("CanPlayerSuicide", "stopSuicide", function(ply)
    return true
end)

hook.Add( "InitPostEntity", "SunucuHazirKodu", function() --Her şey yüklendikten sonra ticketleri tekrar setliyoruz, ve her takıma score olarak ticketleri koyuyoruz. 
    UKRticket = cv_ticketUkr:GetInt()
    RUSticket = cv_ticketRus:GetInt()
    team.SetScore(1, UKRticket)
    team.SetScore(2, RUSticket)
end)

local function spawnetarmorlari()
    if cv_giveArmorFirstSpawn:GetInt() == 1 then
        for i=1, 4 do
            if i<3 then
                local crate = ents.Create("ent_armorcrate")
                crate:SetPos(tablokordinat[i])
                crate:SetAngles(Angle(0, 90, 0))
                crate:SetNW2Int("GW3Team", UKR)
                crate:Spawn()
                crate:Activate()
            elseif i>=3 then
                local crate = ents.Create("ent_armorcrate_ussr")
                crate:SetPos(tablokordinat[i])
                crate:SetAngles(Angle(0, 180, 0))
                crate:SetNW2Int("GW3Team", RUS)
                crate:Spawn()
                crate:Activate()
            end
        end
    end
end

hook.Add( "Initialize", "iniilazir", function()
    timer.Simple(3, function()
        SpawnVehicleUkraynaInitial()
        SpawnVehicleRusyaInitial()
        SpawnVehicleLogiInitial()
        SpawnVehicleLogiInitialRUS()
        spawnetarmorlari()
    end)
end)

-- =========================================
-- GW3 OYUNCU SPAWN SİSTEMİ
-- gamemode/init.lua
-- =========================================

-- =========================================
-- GW3 TAKIM BAZLI OYUNCU SPAWN SİSTEMİ
-- gamemode/init.lua
-- =========================================

local GW3PlayerSpawnPositions = {
    -- UKRAYNA (UKR = 1)
    [UKR] = {
        -- Önceki koordinatlar
        Vector(13479.923828, -12289.035156, -70.968750),
        Vector(13496.849609, -12224.889648, -70.968750),
        Vector(13466.183594, -12174.408203, -70.968750),
        Vector(13396.664062, -12196.688477, -70.968750),
        Vector(13380.248047, -12291.968750, -70.968750),

        -- Yeni koordinatlar
        Vector(13698.410156, -12220.516602, -70.968750),
        Vector(13708.281250, -12122.929688, -70.968750),
        Vector(13624.053711, -12020.031250, -70.968750),
        Vector(13555.523438, -12072.706055, -70.968750),
        Vector(13390.413086, -12075.718750, -70.968750),
        Vector(13267.445312, -12100.127930, -70.968750),
        Vector(13293.829102, -12233.363281, -70.968750),
        Vector(13574.718750, -12417.421875, -70.968750),
    },

    -- RUSYA (RUS = 2)
    [RUS] = {
        -- Önceki koordinatlar
        Vector(-13074.855469, -2502.037840, -780.372742),
        Vector(-13092.125000, -2415.299072, -780.372742),
        Vector(-13248.437500, -2418.790527, -780.372742),
        Vector(-13248.638672, -2503.244629, -780.372742),
        Vector(-13178.009766, -2331.981934, -780.372742),

        -- Yeni koordinatlar
        Vector(-13411.613281, -2517.020752, -780.372742),
        Vector(-13412.750977, -2439.180420, -780.372742),
        Vector(-13411.722656, -2357.049072, -780.372742),
        Vector(-13274.312500, -2341.548584, -755.853699),
        Vector(-12936.000977, -2568.040771, -762.387573),
        Vector(-12936.006836, -2735.968750, -780.372742),
        Vector(-13066.042969, -2689.815674, -780.372742),
        Vector(-13110.281250, -2579.921143, -780.372742),
        Vector(-13032.168945, -2573.670166, -780.372742),
        Vector(-13267.947266, -2712.726562, -780.372742),
        Vector(-13271.968750, -2587.049072, -780.372742),
    }
}

-- Bir noktanın dolu sayılacağı mesafe
local GW3SpawnCheckDistance = 48

-- Her takım için geçici spawn rezervasyonları
local GW3SpawnReservations = {
    [UKR] = {},
    [RUS] = {}
}

-- Koordinatın dünya sınırları içinde olup olmadığını
-- kontrol et ve mümkünse zemin yüksekliğini bul.
local function GW3GetSafeSpawnPosition(pos)

    local tr = util.TraceLine({
        start = pos + Vector(0, 0, 128),
        endpos = pos - Vector(0, 0, 256),
        mask = MASK_SOLID_BRUSHONLY
    })

    if tr.Hit and not tr.StartSolid then
        local groundPos = tr.HitPos + Vector(0, 0, 2)
    end

    -- Zemin izi bulunamazsa koordinatın kendisini kullan.
    return pos
end

local function GW3CountPlayersNear(pos, spawningPlayer)
    local count = 0
    local distanceSqr = GW3SpawnCheckDistance ^ 2

    -- Yakındaki yaşayan oyuncuları kontrol et
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply)
        and ply:IsPlayer()
        and ply ~= spawningPlayer
        and ply:Alive() then

            if ply:GetPos():DistToSqr(pos) <= distanceSqr then
                count = count + 1
            end
        end
    end

    -- Yakındaki prop nesnelerini kontrol et
    for _, ent in ipairs(ents.FindInSphere(pos, GW3SpawnCheckDistance)) do
        if IsValid(ent) and ent ~= spawningPlayer then
            local class = ent:GetClass()

            if string.sub(class, 1, 5) == "prop_" then
                count = count + 1
            end
        end
    end

    return count
end

-- Takım için en uygun spawn noktasını bul.
local function GW3FindSpawnPosition(ply, teamID)
    local positions = GW3PlayerSpawnPositions[teamID]
    local reservations = GW3SpawnReservations[teamID]

    if not positions or not reservations then
        return nil, nil
    end

    local leastCrowdedPos
    local leastCrowdedIndex
    local leastCrowdedCount = math.huge

    local fallbackPos
    local fallbackIndex
    local fallbackCount = math.huge

    for index, originalPos in ipairs(positions) do
        local pos = GW3GetSafeSpawnPosition(originalPos)

        if pos then
            local reservedBy = reservations[index]
            local isReserved = IsValid(reservedBy) and reservedBy ~= ply
            local nearbyPlayers = GW3CountPlayersNear(pos, ply)

            -- Acil durumda kullanılacak en az kalabalık nokta.
            if nearbyPlayers < fallbackCount then
                fallbackPos = pos
                fallbackIndex = index
                fallbackCount = nearbyPlayers
            end

            -- Rezerve edilmiş noktaları normal seçimde atla.
            if not isReserved then
                -- İlk boş noktayı hemen seç.
                if nearbyPlayers == 0 then
                    return pos, index
                end

                -- Boş nokta yoksa en az kalabalık olanı sakla.
                if nearbyPlayers < leastCrowdedCount then
                    leastCrowdedPos = pos
                    leastCrowdedIndex = index
                    leastCrowdedCount = nearbyPlayers
                end
            end
        else
        end
    end

    -- Bütün noktalar doluysa rezerve edilmemiş
    -- en az kalabalık noktayı kullan.
    if leastCrowdedPos then
        return leastCrowdedPos, leastCrowdedIndex
    end

    -- Son çare: tüm noktalar rezerve edilmişse
    -- en az kalabalık geçerli koordinatı kullan.
    return fallbackPos, fallbackIndex
end

-- Oyuncu doğduğunda takımına göre konumunu ayarla.
hook.Add("PlayerSpawn", "GW3_TeamBasedPlayerSpawn", function(ply)
    if not IsValid(ply) then return end

    local teamID = ply:Team()

    if teamID ~= UKR and teamID ~= RUS then
        return
    end
    local spawnPos, spawnIndex = GW3FindSpawnPosition(ply, teamID)

    if not spawnPos then
        ErrorNoHalt(
            "[GW3 Spawn] Takım "
            .. teamID
            .. " için geçerli spawn koordinatı bulunamadı!\n"
        )
        return
    end

    -- Aynı anda doğan başka oyuncular bu noktayı seçmesin.
    GW3SpawnReservations[teamID][spawnIndex] = ply

    timer.Simple(0, function()
        if not IsValid(ply) then
            if GW3SpawnReservations[teamID][spawnIndex] == ply then
                GW3SpawnReservations[teamID][spawnIndex] = nil
            end

            return
        end

        -- Oyuncuyu seçilen konuma yerleştir.
        ply:SetPos(spawnPos)
        ply:SetEyeAngles(Angle(0, 0, 0))

        -- Rezervasyonu kaldır.
        if GW3SpawnReservations[teamID][spawnIndex] == ply then
            GW3SpawnReservations[teamID][spawnIndex] = nil
        end
    end)
end)


UKRticket = cv_ticketUkr:GetInt()
RUSticket = cv_ticketRus:GetInt()
team.SetScore(1, UKRticket)
team.SetScore(2, RUSticket)

util.AddNetworkString("GW3_TeamBarrierSync")

-- KÜRE AYARLARI
local TeamBarriers = {
    -- Team 1 is UKRAINE (blue): eastern / positive-X base.
    [UKR] = {
        -- Center of the actual Ukrainian player-spawn cluster in GW3PlayerSpawnPositions.
        pos = Vector(13487.118765, -12187.677358, -70.968750),
        radius = 5000
    },

    -- Team 2 is RUSSIA (red): western / negative-X base.
    [RUS] = {
        pos = Vector(-13667.385742, -1544.606445, -762.212280),
        radius = 5000
    }
}

-- Aynı başlangıç daireleri takım değiştirme kontrolünde de kullanılır.
-- Böylece bariyer çizimi / hareket kilidi ve takım değiştirme alanı aynı koordinatları kullanır.
GW3.TeamBarrierZones = TeamBarriers

local barrierEnd = {
    [1] = 0,
    [2] = 0
}

local participants = {
    [1] = {},
    [2] = {}
}

local function SyncBarriers(target)
    net.Start("GW3_TeamBarrierSync")

    for _, teamID in ipairs({ UKR, RUS }) do
        local data = TeamBarriers[teamID]

        net.WriteBool(CurTime() < barrierEnd[teamID])
        net.WriteVector(data.pos)
        net.WriteFloat(data.radius)
        net.WriteFloat(barrierEnd[teamID])
    end

    if IsValid(target) then
        net.Send(target)
    else
        net.Broadcast()
    end
end

-- Oyuncunun aktif bariyer içindeki kendi takım spawnında olup olmadığını
-- kontrol eder. Takım değiştirip yeniden doğan oyuncuları da kapsar.
local function RegisterBarrierParticipant(ply, position)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local teamID = ply:Team()
    local data = TeamBarriers[teamID]

    if not data or CurTime() >= barrierEnd[teamID] then return false end

    local origin = position or ply:GetPos()
    if origin:DistToSqr(data.pos) > data.radius ^ 2 then return false end

    participants[teamID][ply] = true
    return true
end

-- BARİYER SİSTEMİNİ BAŞLAT
function GW3.StartTeamBarriers()
    participants[1] = {}
    participants[2] = {}

    -- The starting barrier lasts 10 seconds, as requested.
    barrierEnd[UKR] = CurTime() + 10
    barrierEnd[RUS] = CurTime() + 10

    for _, ply in ipairs(player.GetAll()) do
        RegisterBarrierParticipant(ply)
    end

    SyncBarriers()
end

-- Bariyer açıkken doğan veya takım değiştirerek yeniden doğan oyuncuyu
-- yeni takımının spawn küresine kaydet. Spawn konumu diğer hook tarafından
-- bir sonraki tick'te ayarlandığı için kısa bir gecikme kullanıyoruz.
hook.Add("PlayerSpawn", "GW3_TeamBarrierRegisterSpawn", function(ply)
    timer.Simple(0.1, function()
        if IsValid(ply) then
            RegisterBarrierParticipant(ply)
        end
    end)
end)

-- KÜREDEN ÇIKMAYI ENGELLE
hook.Add("SetupMove", "GW3_TeamBarrierBlock", function(ply, mv)
    local teamID = ply:Team()
    local data = TeamBarriers[teamID]

    if not data or CurTime() >= barrierEnd[teamID] then return end

    -- SetTeam() sonrası oyuncu yeni takımın listesinde bulunmayabilir.
    -- Yeni takım spawnının içindeyse burada kaydedilir; böylece bariyer
    -- takım değiştirerek veya spawn sonrası hareket ederek aşılamaz.
    if not participants[teamID][ply] then
        if not RegisterBarrierParticipant(ply, mv:GetOrigin())
        and not RegisterBarrierParticipant(ply, ply:GetPos()) then
            return
        end
    end

    local center = data.pos
    local maxRadius = math.max(data.radius - 16, 0)
    local offset = mv:GetOrigin() - center

    if offset:LengthSqr() > maxRadius * maxRadius then
        local direction = offset:GetNormalized()
        mv:SetOrigin(center + direction * maxRadius)

        local velocity = mv:GetVelocity()
        local outwardSpeed = velocity:Dot(direction)

        -- Duvara doğru olan hızı kes, duvara paralel hareketi koru.
        if outwardSpeed > 0 then
            mv:SetVelocity(velocity - direction * outwardSpeed)
        end
    end
end)

-- Oyuncu ayrıldığında tablo referanslarını temizle.
hook.Add("PlayerDisconnected", "GW3_TeamBarrierCleanup", function(ply)
    participants[1][ply] = nil
    participants[2][ply] = nil
end)

-- SONRADAN GİREN OYUNCULARA BARİYER DURUMUNU GÖNDER
hook.Add("PlayerInitialSpawn", "GW3_TeamBarrierSync", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            SyncBarriers(ply)
        end
    end)
end)

local teamVehicleList = {
    [1] = {
        ["sw_gaz66"] = true,
        ["sw_uaz469"] = true,
        ["sw_btr60"] = true,
        ["lvs_trailer_zis3"] = true,
        ["lvs_trailer_dshk_12mm"] = true,
        ["sw_kord"] = true,
    },

    [2] = {
        ["sw_ural4320"] = true,
        ["sw_gaz2330"] = true,
        ["sw_btr82"] = true,
        ["lvs_trailer_zis3"] = true,
        ["lvs_trailer_dshk_12mm"] = true,
        ["sw_kord"] = true,
    }
}

local function IsTeamVehicle(vehicle, teamID)
    if not IsValid(vehicle) then return false end

    local allowedVehicles = teamVehicleList[teamID]
    if not allowedVehicles then return false end

    local current = vehicle

    -- LVS koltuklarının parent zincirini kontrol et.
    for i = 1, 8 do
        if not IsValid(current) then break end

        if allowedVehicles[current:GetClass()] then
            return true
        end

        local parent = current:GetParent()

        if not IsValid(parent) or parent == game.GetWorld() or parent == current then
            break
        end

        current = parent
    end

    return false
end

hook.Add("CanPlayerEnterVehicle", "GW3_TeamBarrierNoVehicle", function(ply, vehicle)
    if not IsValid(ply) or not IsValid(vehicle) then return false end

    local teamID = ply:Team()

    -- Her zaman kendi takımının araçlarına izin ver.
    if not IsTeamVehicle(vehicle, teamID) then
        return false
    end

    -- Bariyer hâlâ aktif mi?
    local endTime = barrierEnd and barrierEnd[teamID]

    local barrierActive =
        TeamBarriers and
        TeamBarriers[teamID] and
        type(endTime) == "number" and
        CurTime() < endTime

    if barrierActive then
        -- Kayıt yoksa oluştur.
        RegisterBarrierParticipant(ply)

        -- Bariyer katılımcıları araç kullanamaz.
        if participants and participants[teamID] and participants[teamID][ply] then
            return false
        end
    end

    -- İzin verilen araçlarda diğer hook'ların da çalışmasına izin ver.
    return nil
end)

GW3.StartTeamBarriers()

-- HER SPAWNDA CROWBAR VER, SANDBOX ARAÇLARINI ENVANTERDEN KALDIR
-- PlayerLoadout hook'u sandbox'ın varsayılan yüklemesini engellemez;
-- timer.Simple(0), varsayılan yükleme tamamlandıktan sonra çalışır.
local GW3_RemoveOnSpawn = {
    "weapon_physgun",
    "gmod_tool",
    "gmod_camera"
}

hook.Add("PlayerLoadout", "GW3_CustomSpawnLoadout", function(ply)
    timer.Simple(0, function()
        if not IsValid(ply) then return end

        for _, weaponClass in ipairs(GW3_RemoveOnSpawn) do
            if ply:HasWeapon(weaponClass) then
                ply:StripWeapon(weaponClass)
            end
        end

        -- Her doğuşta crowbar envanterinde bulunsun.
        if not ply:HasWeapon("wep_gmod_tilifon") then
            ply:Give("wep_gmod_tilifon")
        end
    end)
end)


if SERVER then
    hook.Add("PlayerShouldTakeDamage", "GW3_NoTeamKill", function(victim, attacker)

        if not IsValid(attacker) or not attacker:IsPlayer() then
            return
        end

        -- Kendine verdiği hasarı engelleme
        if victim == attacker then return end

        -- Aynı takım hasarını engelle
        if victim:Team() == attacker:Team() then
            return false
        end

    end)
end