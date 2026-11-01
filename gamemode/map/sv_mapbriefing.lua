-- Global Warfare 3 - server side tactical overview data.
-- Entity positions and capture-point ownership are sent in world coordinates.

util.AddNetworkString("GW3_BriefingMapRequest")
util.AddNetworkString("GW3_BriefingMapSync")

local VEHICLE_TEAMS = {
    ["sw_gaz66"] = 1,
    ["sw_uaz469"] = 1,
    ["sw_btr60"] = 1,
    ["sw_ural4320"] = 2,
    ["sw_gaz2330"] = 2,
    ["sw_btr82"] = 2
}

-- PNG icon IDs: 1 truck, 2 APC/armored vehicle, 3 jeep, 4 logistics,
-- 5 construction, 6 armor crate. kind is retained for category counts.
local VEHICLE_ICONS = {
    ["sw_gaz66"] = 1,
    ["sw_ural4320"] = 1,
    ["sw_btr60"] = 2,
    ["sw_btr82"] = 2,
    ["sw_gaz2330"] = 2,
    ["sw_uaz469"] = 3
}

local CRATE_INFO = {
    ["ent_logicrate"] = { team = 1, kind = 2, icon = 4 },
    ["ent_logicrate_ussr"] = { team = 2, kind = 2, icon = 4 },
    ["ent_buildcrate"] = { kind = 3, icon = 5 }
}

-- World bounds for the main Global Warfare map.
-- Other maps fall back to their worldspawn bounds.
local MAP_BOUNDS = {
    ["wid_peremen"] = {
        mins = Vector(-16000, -15000, -2048),
        maxs = Vector(15500, 14000, 4096)
    }
}

local UKRAINE_BASE = Vector(13000, -13000, 0)
local RUSSIA_BASE = Vector(-13300, -2100, 0)

local function GetMapBounds()
    local known = MAP_BOUNDS[game.GetMap()]
    if known then return known.mins, known.maxs end

    local world = game.GetWorld()
    if IsValid(world) then
        local mins, maxs = world:WorldSpaceAABB()
        if isvector(mins) and isvector(maxs)
        and maxs.x - mins.x > 1024 and maxs.y - mins.y > 1024
        and math.abs(mins.x) < 100000 and math.abs(maxs.x) < 100000
        and math.abs(mins.y) < 100000 and math.abs(maxs.y) < 100000 then
            return mins, maxs
        end
    end

    return Vector(-16384, -16384, -2048), Vector(16384, 16384, 4096)
end

local function InferBuildCrateTeam(ent)
    local stampedTeam = ent:GetNW2Int("GW3Team", 0)
    if stampedTeam == 1 or stampedTeam == 2 then return stampedTeam end

    local pos = ent:GetPos()
    local flatPos = Vector(pos.x, pos.y, 0)
    local ukrDistance = flatPos:DistToSqr(UKRAINE_BASE)
    local rusDistance = flatPos:DistToSqr(RUSSIA_BASE)
    return ukrDistance <= rusDistance and 1 or 2
end

local function GetMapEntityInfo(ent)
    local class = ent:GetClass()
    local vehicleTeam = VEHICLE_TEAMS[class]
    if vehicleTeam then
        local stampedTeam = ent:GetNW2Int("GW3Team", 0)
        return (stampedTeam == 1 or stampedTeam == 2) and stampedTeam or vehicleTeam, 1, VEHICLE_ICONS[class] or 2
    end

    local crateInfo = CRATE_INFO[class]
    if not crateInfo then return nil end

    local teamID = crateInfo.team or InferBuildCrateTeam(ent)
    local stampedTeam = ent:GetNW2Int("GW3Team", 0)
    if stampedTeam == 1 or stampedTeam == 2 then teamID = stampedTeam end
    return teamID, crateInfo.kind, crateInfo.icon
end

local function GetCapturePoints()
    local result = {}
    if not istable(aktifKureler) then return result end

    for name, point in pairs(aktifKureler) do
        if isstring(name) and istable(point) and isvector(point.pos) then
            result[#result + 1] = {
                name = name,
                pos = point.pos,
                radius = math.max(0, tonumber(point.radius) or 0),
                owner = tonumber(point.controlledByTeam) or 1001,
                ukraineProgress = math.Clamp(math.floor(tonumber(point.ukraineCapPoint) or 0), 0, 200),
                russiaProgress = math.Clamp(math.floor(tonumber(point.rusCapPoint) or 0), 0, 200)
            }
        end
    end

    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

local function GetMapEntities()
    local entries = {}

    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and not ent:IsPlayer() then
            local teamID, kind, icon = GetMapEntityInfo(ent)
            if teamID and kind and icon and #entries < 4095 then
                entries[#entries + 1] = {
                    pos = ent:GetPos(),
                    yaw = ent:GetAngles().y,
                    team = teamID,
                    kind = kind,
                    icon = icon
                }
            end
        end
    end

    return entries
end

local requestCooldown = setmetatable({}, { __mode = "k" })
local cachedEntries = nil
local cachedMins, cachedMaxs
local cachedAt = 0
local ENTITY_CACHE_INTERVAL = 0.75

local function RefreshEntitySnapshot(now)
    if cachedEntries and now - cachedAt < ENTITY_CACHE_INTERVAL then return end

    cachedEntries = GetMapEntities()
    cachedMins, cachedMaxs = GetMapBounds()
    cachedAt = now
end

net.Receive("GW3_BriefingMapRequest", function(_, ply)
    if not IsValid(ply) then return end

    local now = CurTime()
    if (requestCooldown[ply] or 0) > now then return end
    requestCooldown[ply] = now + 0.5

    RefreshEntitySnapshot(now)

    local viewerTeam = ply:Team()
    local entries = {}
    -- Strict server-side filtering: enemy assets are not sent to this client.
    if viewerTeam == 1 or viewerTeam == 2 then
        for _, entry in ipairs(cachedEntries or {}) do
            if entry.team == viewerTeam then
                entries[#entries + 1] = entry
            end
        end
    end

    local teammates = {}
    if viewerTeam == 1 or viewerTeam == 2 then
        for _, teammate in ipairs(player.GetAll()) do
            if IsValid(teammate) and teammate:Team() == viewerTeam and teammate:Alive() then
                teammates[#teammates + 1] = teammate
                if #teammates >= 255 then break end
            end
        end
    end

    local capturePoints = GetCapturePoints()
    local mins = cachedMins or Vector(-16384, -16384, -2048)
    local maxs = cachedMaxs or Vector(16384, 16384, 4096)

    net.Start("GW3_BriefingMapSync")
        net.WriteVector(mins)
        net.WriteVector(maxs)
        net.WriteUInt(math.Clamp(tonumber(viewerTeam) or 0, 0, 3), 2)

        net.WriteUInt(math.min(#entries, 4095), 12)
        for i = 1, math.min(#entries, 4095) do
            local entry = entries[i]
            net.WriteVector(entry.pos)
            net.WriteUInt(entry.team, 2)
            net.WriteUInt(entry.kind, 3)
            net.WriteUInt(entry.icon, 3)
            net.WriteFloat(entry.yaw)
        end

        net.WriteUInt(#teammates, 8)
        for _, teammate in ipairs(teammates) do
            net.WriteVector(teammate:GetPos())
            net.WriteFloat(teammate:EyeAngles().y)
            net.WriteString(string.sub(teammate:Nick() or "Teammate", 1, 64))
            net.WriteBool(teammate == ply)
        end

        net.WriteUInt(math.min(#capturePoints, 31), 5)
        for i = 1, math.min(#capturePoints, 31) do
            local point = capturePoints[i]
            net.WriteString(point.name)
            net.WriteVector(point.pos)
            net.WriteFloat(point.radius)
            net.WriteInt(point.owner, 16)
            net.WriteUInt(point.ukraineProgress, 8)
            net.WriteUInt(point.russiaProgress, 8)
        end
    net.Send(ply)
end)


-- Team-only asset availability for the F3 briefing panel.
util.AddNetworkString("GW3_BriefingAssetsRequest")
util.AddNetworkString("GW3_BriefingAssetsSync")

local assetCooldownEnds = {}
local function AssetCooldownKey(teamID, class)
    return tostring(teamID) .. ":" .. class
end

local VEHICLE_ASSETS = {
    [1] = {
        { class = "sw_gaz66", name = "GAZ-66", amount = "sv_ukrainetruckamount" },
        { class = "sw_uaz469", name = "UAZ-469", amount = "sv_ukrainecaramount" },
        { class = "sw_btr60", name = "BTR-60", amount = "sv_ukraineapcamount" }
    },
    [2] = {
        { class = "sw_ural4320", name = "URAL-4320", amount = "sv_russiatruckamount" },
        { class = "sw_gaz2330", name = "GAZ-2330", amount = "sv_russiacaramount" },
        { class = "sw_btr82", name = "BTR-82", amount = "sv_russiaapcamount" }
    }
}

local VEHICLE_COOLDOWNS = {
    sw_gaz66 = "sv_ukrainetruckcooldown", sw_uaz469 = "sv_ukrainecarcooldown",
    sw_btr60 = "sv_ukraineapccooldown", sw_ural4320 = "sv_russiatruckcooldown",
    sw_gaz2330 = "sv_russiacarcooldown", sw_btr82 = "sv_russiaapccooldown"
}

local function GetAssetTeam(ent)
    local stamped = ent:GetNW2Int("GW3Team", 0)
    if stamped == 1 or stamped == 2 then return stamped end
    local class = ent:GetClass()
    if VEHICLE_TEAMS[class] then return VEHICLE_TEAMS[class] end
    if class == "ent_logicrate" then return 1 end
    if class == "ent_logicrate_ussr" then return 2 end
    if class == "ent_buildcrate" then return InferBuildCrateTeam(ent) end
    return 0
end

hook.Add("AracPatladi", "GW3_BriefingVehicleCooldown", function(class, teamID)
    if teamID ~= 1 and teamID ~= 2 then return end
    local convarName = VEHICLE_COOLDOWNS[class]
    local cv = convarName and GetConVar(convarName)
    local duration = cv and cv:GetFloat() or 0
    assetCooldownEnds[AssetCooldownKey(teamID, class)] = CurTime() + math.max(duration, 0)
end)

local function MarkCrateCooldown(teamID, class)
    assetCooldownEnds[AssetCooldownKey(teamID, class)] = CurTime() + 240
end
hook.Add("logistikcrateBitti", "GW3_BriefingCrateCooldownUKR", function(class)
    MarkCrateCooldown(1, class)
end)
hook.Add("logistikcrateBittiRUS", "GW3_BriefingCrateCooldownRUS", function(class)
    MarkCrateCooldown(2, class)
end)

local function CountTeamClass(class, teamID)
    local count = 0
    for _, ent in ipairs(ents.FindByClass(class)) do
        if IsValid(ent) and GetAssetTeam(ent) == teamID then count = count + 1 end
    end
    return count
end

local function GetCrateCapacity()
    local cv = GetConVar("sv_givelogistic")
    local level = cv and cv:GetInt() or 1
    local settings = {
        [1] = { logi = 3, build = 2 },
        [2] = { logi = 5, build = 3 },
        [3] = { logi = 6, build = 4 }
    }
    return settings[level] or settings[1]
end

net.Receive("GW3_BriefingAssetsRequest", function(_, ply)
    if not IsValid(ply) then return end
    local teamID = ply:Team()
    if teamID ~= 1 and teamID ~= 2 then return end

    local rows = {}
    for _, data in ipairs(VEHICLE_ASSETS[teamID]) do
        local amountCV = GetConVar(data.amount)
        local maxAmount = amountCV and amountCV:GetInt() or 0
        rows[#rows + 1] = {
            class = data.class, name = data.name,
            current = CountTeamClass(data.class, teamID), maximum = maxAmount
        }
    end

    local crateCapacity = GetCrateCapacity()
    local logiClass = teamID == 1 and "ent_logicrate" or "ent_logicrate_ussr"
    rows[#rows + 1] = {
        class = logiClass, name = "Logistics crate",
        current = CountTeamClass(logiClass, teamID), maximum = crateCapacity.logi
    }
    rows[#rows + 1] = {
        class = "ent_buildcrate", name = "Construction crate",
        current = CountTeamClass("ent_buildcrate", teamID), maximum = crateCapacity.build
    }

    net.Start("GW3_BriefingAssetsSync")
        net.WriteUInt(teamID, 2)
        net.WriteUInt(#rows, 4)
        for _, row in ipairs(rows) do
            local remaining = math.max(0, (assetCooldownEnds[AssetCooldownKey(teamID, row.class)] or 0) - CurTime())
            net.WriteString(row.name)
            net.WriteUInt(math.Clamp(row.current, 0, 255), 8)
            net.WriteUInt(math.Clamp(row.maximum, 0, 255), 8)
            net.WriteUInt(math.Clamp(math.ceil(remaining), 0, 65535), 16)
        end
    net.Send(ply)
end)
