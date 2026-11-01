-- Global Warfare 3 - F3 briefing map.
-- Creates a real top-down PNG from the current BSP at runtime, then draws
-- live tactical markers over that cached image.
GW3 = GW3 or {}

local DATA_REQUEST_INTERVAL = 1
local OVERVIEW_VERSION = "gminimap_v3_no_base_barriers" -- Forces a fresh PNG after the player-visibility fix.

local TEAM_COLORS = {
    [1] = Color(55, 145, 255),
    [2] = Color(238, 75, 75)
}

local CAPTURE_NAMES = {
    TokiKure = "Peremen Apartments",
    YorukKure = "Mehmedovs Home",
    KasabaKure = "Peremen Village",
    ukraynaKoy = "Russian Trenches",
    AmkKoy = "Village"
}

-- Transparent PNG silhouettes tinted with the viewing team's color.
-- 1 truck, 2 APC/armored vehicle, 3 jeep, 4 logistics crate,
-- 5 construction crate, 6 armor crate, 7 friendly infantry.
local MAP_ICON_SCALE = 2 -- Double the size of all PNG tactical markers.

local MAP_ICON_MATERIALS = {
    [1] = Material("gamemodes/globalwarfare3/content/materials/gw3_map_truck.png", "smooth"),
    [2] = Material("gamemodes/globalwarfare3/content/materials/gw3_map_apc.png", "smooth"),
    [3] = Material("gamemodes/globalwarfare3/content/materials/gw3_map_jeep.png", "smooth"),
    [4] = Material("gamemodes/globalwarfare3/content/materials/gw3_map_logistics.png", "smooth"),
    [5] = Material("gamemodes/globalwarfare3/content/materials/gw3_map_construction.png", "smooth"),
    [6] = Material("gamemodes/globalwarfare3/content/materials/gw3_map_armor.png", "smooth"),
    [7] = Material("gamemodes/globalwarfare3/content/materials/gw3_map_teammate.png", "smooth")
}

local mapData = {
    entities = {},
    players = {},
    capturePoints = {},
    viewerTeam = 0,
    mins = Vector(-16000, -15000, -2048),
    maxs = Vector(15500, 14000, 4096),
    receivedAt = 0
}

local nextDataRequest = 0
local pendingForceCapture = false
local briefingAssets = { team = 0, rows = {}, receivedAt = 0 }

local mapOverview = {
    status = "WAITING FOR SERVER MAP DATA",
    material = nil,
    mins = nil,
    maxs = nil,
    width = 0,
    height = 0,
    side = 0,
    active = false,
    outputFile = nil,
    indexFile = nil
}

surface.CreateFont("GW3BriefMapHeader", {
    font = "Roboto", size = 22, weight = 900, antialias = true, extended = true
})
surface.CreateFont("GW3BriefMapText", {
    font = "Roboto", size = 16, weight = 700, antialias = true, extended = true
})
surface.CreateFont("GW3BriefMapSmall", {
    font = "Roboto", size = 13, weight = 600, antialias = true, extended = true
})
surface.CreateFont("GW3BriefMapMarker", {
    font = "Roboto", size = 12, weight = 1000, antialias = true, extended = true
})

local function GetSafeMapName()
    local name = string.lower(game.GetMap() or "unknown")
    name = string.gsub(name, "[^%w_%-]", "_")
    return name
end

local function GetOverviewRoot()
    return "gw3_overviews/" .. GetSafeMapName() .. "_" .. OVERVIEW_VERSION
end

local function IsUsableBounds(mins, maxs)
    if not isvector(mins) or not isvector(maxs) then return false end
    local sx = maxs.x - mins.x
    local sy = maxs.y - mins.y
    return sx > 1024 and sy > 1024 and sx < 100000 and sy < 100000
        and math.abs(mins.x) < 100000 and math.abs(maxs.x) < 100000
        and math.abs(mins.y) < 100000 and math.abs(maxs.y) < 100000
end

local function GetCaptureBounds()
    -- Match GMinimap: prefer world:GetModelBounds() for the actual BSP extents.
    -- Expand for capture zones and tracked entities so no marker is clipped.
    local mins = Vector(mapData.mins.x, mapData.mins.y, mapData.mins.z)
    local maxs = Vector(mapData.maxs.x, mapData.maxs.y, mapData.maxs.z)

    local world = game.GetWorld()
    if IsValid(world) and world.GetModelBounds then
        local ok, worldMins, worldMaxs = pcall(function()
            return world:GetModelBounds()
        end)
        if ok and IsUsableBounds(worldMins, worldMaxs) then
            mins.x = worldMins.x
            mins.y = worldMins.y
            maxs.x = worldMaxs.x
            maxs.y = worldMaxs.y
            mins.z = worldMins.z
            maxs.z = worldMaxs.z
        end
    end

    for _, point in ipairs(mapData.capturePoints) do
        local radius = math.max(tonumber(point.radius) or 0, 0)
        mins.x = math.min(mins.x, point.pos.x - radius)
        mins.y = math.min(mins.y, point.pos.y - radius)
        maxs.x = math.max(maxs.x, point.pos.x + radius)
        maxs.y = math.max(maxs.y, point.pos.y + radius)
        mins.z = math.min(mins.z, point.pos.z)
        maxs.z = math.max(maxs.z, point.pos.z)
    end

    for _, item in ipairs(mapData.entities) do
        if item.pos then
            mins.x = math.min(mins.x, item.pos.x)
            mins.y = math.min(mins.y, item.pos.y)
            maxs.x = math.max(maxs.x, item.pos.x)
            maxs.y = math.max(maxs.y, item.pos.y)
        end
    end

    local spanX = math.max(maxs.x - mins.x, 2048)
    local spanY = math.max(maxs.y - mins.y, 2048)
    local padX = spanX * 0.025
    local padY = spanY * 0.025

    mins.x = mins.x - padX
    mins.y = mins.y - padY
    maxs.x = maxs.x + padX
    maxs.y = maxs.y + padY

    if maxs.z - mins.z < 2048 then
        mins.z = mins.z - 1024
        maxs.z = maxs.z + 1024
    end

    return mins, maxs
end

local function GetOverviewBounds()
    if IsUsableBounds(mapOverview.mins, mapOverview.maxs) then
        return mapOverview.mins, mapOverview.maxs
    end
    return mapData.mins, mapData.maxs
end

local function GetMapRect(w, h)
    local mins, maxs = GetOverviewBounds()
    -- GetRenderTarget only accepts power-of-two dimensions. The overview is
    -- therefore a square image; the actual rectangular map is letterboxed
    -- inside that square without stretching the world geometry.
    local size = math.max(1, math.min(w - 4, h - 4))
    return (w - size) * 0.5, (h - size) * 0.5, size, size, mins, maxs
end

local function WorldToMap(pos, rectX, rectY, rectW, rectH, mins, maxs)
    local centerX = (mins.x + maxs.x) * 0.5
    local centerY = (mins.y + maxs.y) * 0.5
    local side = math.max(maxs.x - mins.x, maxs.y - mins.y, 1)

    -- GMinimap uses Angle(90, 0, 0): world Y maps horizontally and
    -- world X maps vertically. Keep all tactical markers aligned to that view.
    local x = rectX + (0.5 - ((pos.y - centerY) / side)) * rectW
    local y = rectY + (0.5 - ((pos.x - centerX) / side)) * rectH
    return x, y, side
end

local function MakeOverviewMaterial(path)
    if not path or not file.Exists(path, "DATA") then return false end

    local material = Material("../data/" .. path, "smooth")
    if not material or material:IsError() then return false end

    mapOverview.material = material
    return true
end

local function LoadSavedOverview()
    local indexFile = GetOverviewRoot() .. "_current.json"
    if not file.Exists(indexFile, "DATA") then return false end

    local raw = file.Read(indexFile, "DATA")
    local meta = raw and util.JSONToTable(raw) or nil
    if not istable(meta) or not isstring(meta.file) then return false end
    if not file.Exists(meta.file, "DATA") then return false end
    if not istable(meta.mins) or not istable(meta.maxs) then return false end

    local mins = Vector(tonumber(meta.mins.x) or 0, tonumber(meta.mins.y) or 0, tonumber(meta.mins.z) or 0)
    local maxs = Vector(tonumber(meta.maxs.x) or 0, tonumber(meta.maxs.y) or 0, tonumber(meta.maxs.z) or 0)
    if not IsUsableBounds(mins, maxs) then return false end

    mapOverview.mins = mins
    mapOverview.maxs = maxs
    mapOverview.width = tonumber(meta.width) or 0
    mapOverview.height = tonumber(meta.height) or 0
    mapOverview.side = tonumber(meta.side) or math.max(maxs.x - mins.x, maxs.y - mins.y)
    mapOverview.outputFile = meta.file
    mapOverview.indexFile = indexFile

    if not MakeOverviewMaterial(meta.file) then return false end

    mapOverview.active = false
    mapOverview.status = "MAP IMAGE LOADED"
    return true
end

local function SnapshotAndClearHooks(eventName, ourHookID)
    local saved = {}
    local eventHooks = hook.GetTable()[eventName] or {}
    local toRemove = {}

    -- Hook.Run stops at the first non-nil return. Another addon can therefore
    -- prevent our PrePlayerDraw hook from running. Copy first, then remove, so
    -- changing the hook table cannot skip entries during pairs() iteration.
    for id, fn in pairs(eventHooks) do
        if id ~= ourHookID then
            saved[id] = fn
            toRemove[#toRemove + 1] = id
        end
    end
    for _, id in ipairs(toRemove) do
        hook.Remove(eventName, id)
    end

    return saved
end

local function RestoreHooks(eventName, saved)
    for id, fn in pairs(saved or {}) do
        hook.Add(eventName, id, fn)
    end
end

local function TemporarilyRemoveHook(eventName, hookID)
    local eventHooks = hook.GetTable()[eventName]
    local fn = eventHooks and eventHooks[hookID]
    if fn then
        hook.Remove(eventName, hookID)
    end
    return fn
end

local function HideTrackedEntities()
    local trackedClasses = {
        sw_gaz66 = true,
        sw_uaz469 = true,
        sw_btr60 = true,
        sw_ural4320 = true,
        sw_gaz2330 = true,
        sw_btr82 = true,
        ent_logicrate = true,
        ent_logicrate_ussr = true,
        ent_buildcrate = true,
        ent_armorcrate = true,
        ent_armorcrate_ussr = true
    }

    local players = player.GetAll()
    local playerSet = {}
    for _, ply in ipairs(players) do
        if IsValid(ply) then playerSet[ply] = true end
    end

    local hidden = {}
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) then
            local isPlayer = ent:IsPlayer()
            local parent = ent:GetParent()
            local parentIsPlayer = IsValid(parent) and playerSet[parent] or false
            local ownedByPlayer = false
            if not isPlayer and ent.GetOwner then
                local owner = ent:GetOwner()
                ownedByPlayer = IsValid(owner) and playerSet[owner] or false
            end

            if isPlayer or trackedClasses[ent:GetClass()] or parentIsPlayer or ownedByPlayer then
                local state = {
                    ent = ent,
                    noDraw = ent:GetNoDraw(),
                    isPlayer = isPlayer
                }

                if isPlayer then
                    state.color = ent:GetColor()
                    state.renderMode = ent:GetRenderMode()
                    state.modelScale = ent:GetModelScale()
                    state.renderOverride = ent.RenderOverride
                    state.drawModel = ent.DrawModel

                    -- RenderOverride is called before PrePlayerDraw. Some player
                    -- model addons install it and bypass PrePlayerDraw entirely.
                    -- Replace both entry points, shrink and alpha-hide the model,
                    -- and finally set NoDraw as a last layer of protection.
                    ent.RenderOverride = function() end
                    ent.DrawModel = function() end
                    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
                    local oldColor = state.color
                    ent:SetColor(Color(oldColor.r, oldColor.g, oldColor.b, 0))
                    ent:SetModelScale(0.001, 0)
                end

                hidden[#hidden + 1] = state
                ent:SetNoDraw(true)
            end
        end
    end

    return hidden
end

local function RestoreTrackedEntities(hidden)
    for _, state in ipairs(hidden or {}) do
        local ent = state.ent
        if IsValid(ent) then
            if state.isPlayer then
                -- Restore the model's custom drawing state before restoring
                -- visibility. Keep the exact values present before capture.
                ent.RenderOverride = state.renderOverride
                ent.DrawModel = state.drawModel
                ent:SetModelScale(state.modelScale or 1, 0)
                ent:SetColor(state.color or color_white)
                ent:SetRenderMode(state.renderMode or RENDERMODE_NORMAL)
            end
            ent:SetNoDraw(state.noDraw)
        end
    end
end

local OVERVIEW_RT_SIZE = 1024
local OVERVIEW_CAPTURE_HOOK = "GW3_BriefingMap_GMinimapCapture"

local function EnsureOverviewRenderTarget()
    if mapOverview.renderTarget then
        return mapOverview.renderTarget
    end

    -- Use GMinimap's own allocator when the addon is present. This gives us
    -- the same RT type it uses for its terrain radar. Otherwise create an
    -- equivalent private RT so the briefing map also works without GMinimap.
    if SDrawUtils and isfunction(SDrawUtils.AllocateRT) then
        local ok, id, texture = pcall(SDrawUtils.AllocateRT)
        if ok and texture then
            mapOverview.renderTargetID = id
            mapOverview.renderTarget = texture
            mapOverview.renderTargetFromGMinimap = true
            return texture
        end
    end

    local rtName = "GW3_BriefingOverview_" .. GetSafeMapName()
    mapOverview.renderTarget = GetRenderTarget(rtName, OVERVIEW_RT_SIZE, OVERVIEW_RT_SIZE)
    return mapOverview.renderTarget
end

local function FinishOverviewCapture(pngData, width, height)
    if not isstring(pngData) or #pngData < 1024 then
        mapOverview.active = false
        mapOverview.status = "CAPTURE FAILED - NO PIXELS RECEIVED"
        print("[GW3 Map] render.Capture returned empty image data.")
        return false
    end

    file.CreateDir("gw3_overviews")
    local root = GetOverviewRoot()
    local pngFile = root .. "_overview.png"
    local mins, maxs = mapOverview.mins, mapOverview.maxs

    -- file.Write has no useful success return value. Verify the file itself.
    file.Write(pngFile, pngData)
    if not file.Exists(pngFile, "DATA") or file.Size(pngFile, "DATA") < #pngData then
        mapOverview.active = false
        mapOverview.status = "COULD NOT WRITE PNG TO DATA FOLDER"
        print("[GW3 Map] PNG write verification failed for " .. pngFile)
        return false
    end

    local meta = {
        file = pngFile,
        width = width,
        height = height,
        side = mapOverview.side,
        mins = { x = mins.x, y = mins.y, z = mins.z },
        maxs = { x = maxs.x, y = maxs.y, z = maxs.z },
        projection = "gminimap_topdown_yaw0"
    }
    local indexFile = root .. "_current.json"
    local json = util.TableToJSON(meta, true) or "{}"
    file.Write(indexFile, json)
    if not file.Exists(indexFile, "DATA") or file.Size(indexFile, "DATA") < 2 then
        mapOverview.active = false
        mapOverview.status = "COULD NOT WRITE MAP METADATA"
        print("[GW3 Map] Metadata write verification failed for " .. indexFile)
        return false
    end

    mapOverview.width = width
    mapOverview.height = height
    mapOverview.outputFile = pngFile
    mapOverview.indexFile = indexFile
    mapOverview.active = false
    mapOverview.status = "PNG SAVED - LOADING MATERIAL"

    timer.Simple(0, function()
        if MakeOverviewMaterial(pngFile) then
            mapOverview.status = "MAP IMAGE READY"
            print("[GW3 Map] GMinimap-style top-down PNG saved: garrysmod/data/" .. pngFile .. " (" .. width .. "x" .. height .. ")")
        else
            mapOverview.status = "PNG SAVED BUT MATERIAL DID NOT LOAD"
            print("[GW3 Map] PNG saved but Material('../data/" .. pngFile .. "') failed to load.")
        end
    end)

    return true
end

local function CaptureOverviewLikeGMinimap()
    if not mapOverview.active then return end

    local mins, maxs = mapOverview.mins, mapOverview.maxs
    if not IsUsableBounds(mins, maxs) then
        mapOverview.active = false
        mapOverview.status = "INVALID MAP BOUNDS"
        return
    end

    local rt = EnsureOverviewRenderTarget()
    if not rt then
        mapOverview.active = false
        mapOverview.status = "COULD NOT CREATE MAP RENDERTARGET"
        print("[GW3 Map] Could not allocate the briefing overview RenderTarget.")
        return
    end

    local centerX = (mins.x + maxs.x) * 0.5
    local centerY = (mins.y + maxs.y) * 0.5
    local side = math.max(maxs.x - mins.x, maxs.y - mins.y, 2048)
    local area = side * 0.5
    local top = maxs.z
    local bottom = mins.z
    local offset = 50000
    local oldEyePos = EyePos
    local lastEyePos = EyePos()
    local hidden = HideTrackedEntities()
    local hookID = OVERVIEW_CAPTURE_HOOK
    local haloFunc = hook.GetTable().PostDrawEffects and hook.GetTable().PostDrawEffects.RenderHalos
    local pushedRT, pushedMin, pushedMag = false, false, false
    local pngData

    local savedPrePlayerDraw = SnapshotAndClearHooks("PrePlayerDraw", hookID)
    local savedPostPlayerDraw = SnapshotAndClearHooks("PostPlayerDraw", hookID)
    local savedShouldDrawLocalPlayer = SnapshotAndClearHooks("ShouldDrawLocalPlayer", hookID)
    -- These large circles are the temporary spawn-protection barriers, not map geography.
    -- Remove their world-render hook only while generating the static PNG, then restore it.
    local savedTeamBarrierHook = TemporarilyRemoveHook("PostDrawTranslucentRenderables", "GW3_DrawTeamBarriers")

    hook.Add("PreDrawSkyBox", hookID, function() return true end)
    hook.Add("PrePlayerDraw", hookID, function() return true end)
    hook.Add("PostPlayerDraw", hookID, function() return true end)
    hook.Add("ShouldDrawLocalPlayer", hookID, function() return false end)
    hook.Add("PreDrawViewModel", hookID, function() return true end)
    if haloFunc then hook.Remove("PostDrawEffects", "RenderHalos") end

    -- GMinimap freezes EyePos while rendering its terrain to prevent nested
    -- views from inheriting the wrong camera position.
    EyePos = function() return lastEyePos end

    local ok, err = xpcall(function()
        render.PushRenderTarget(rt, 0, 0, OVERVIEW_RT_SIZE, OVERVIEW_RT_SIZE)
        pushedRT = true
        render.SetStencilEnable(false)

        local cfg = GMinimap and GMinimap.Config or nil
        render.SetLightingMode(cfg and cfg.terrainLighting and 0 or 1)
        render.OverrideAlphaWriteEnable(false)
        render.SetColorMaterial()
        render.Clear(40, 40, 40, 255, true, true)

        render.PushFilterMin(1)
        pushedMin = true
        render.PushFilterMag(1)
        pushedMag = true

        -- This is GMinimap's Radar:Capture camera setup, expanded to cover
        -- the entire BSP instead of the player's current minimap tile.
        render.RenderView({
            origin = Vector(centerX, centerY, top) + Vector(0, 0, offset),
            angles = Angle(90, 0, 0),
            x = 0,
            y = 0,
            w = OVERVIEW_RT_SIZE,
            h = OVERVIEW_RT_SIZE,
            znear = offset,
            zfar = top - bottom + offset,
            drawhud = false,
            drawmonitors = false,
            drawviewmodel = false,
            drawviewer = false,
            dopostprocess = false,
            viewid = 2,
            ortho = {
                top = -area,
                left = -area,
                right = area,
                bottom = area
            }
        })

        if cfg then
            DrawColorModify({
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0,
                ["$pp_colour_brightness"] = cfg.terrainBrightness or 0,
                ["$pp_colour_contrast"] = 1,
                ["$pp_colour_colour"] = cfg.terrainColorMult or 1,
                ["$pp_colour_inv"] = cfg.terrainColorInv or 0
            })
        end
    end, debug.traceback)

    if pushedMag then render.PopFilterMag() end
    if pushedMin then render.PopFilterMin() end
    if pushedRT then render.PopRenderTarget() end
    render.SetLightingMode(0)
    render.OverrideAlphaWriteEnable(false)
    EyePos = oldEyePos
    hook.Remove("PreDrawSkyBox", hookID)
    hook.Remove("PrePlayerDraw", hookID)
    hook.Remove("PostPlayerDraw", hookID)
    hook.Remove("ShouldDrawLocalPlayer", hookID)
    hook.Remove("PreDrawViewModel", hookID)
    RestoreHooks("PrePlayerDraw", savedPrePlayerDraw)
    RestoreHooks("PostPlayerDraw", savedPostPlayerDraw)
    RestoreHooks("ShouldDrawLocalPlayer", savedShouldDrawLocalPlayer)
    if savedTeamBarrierHook then
        hook.Add("PostDrawTranslucentRenderables", "GW3_DrawTeamBarriers", savedTeamBarrierHook)
    end
    if haloFunc then hook.Add("PostDrawEffects", "RenderHalos", haloFunc) end
    RestoreTrackedEntities(hidden)

    if not ok then
        mapOverview.active = false
        mapOverview.status = "GMINIMAP RENDER ERROR - SEE CONSOLE"
        print("[GW3 Map] GMinimap-style terrain render failed: " .. tostring(err))
        return
    end

    local captureOK, captureResult = pcall(function()
        render.SetRenderTarget(rt)
        local data = render.Capture({
            format = "png",
            x = 0,
            y = 0,
            w = OVERVIEW_RT_SIZE,
            h = OVERVIEW_RT_SIZE,
            alpha = false
        })
        render.SetRenderTarget()
        return data
    end)

    if not captureOK then
        render.SetRenderTarget()
        mapOverview.active = false
        mapOverview.status = "PNG CAPTURE ERROR - SEE CONSOLE"
        print("[GW3 Map] render.Capture failed: " .. tostring(captureResult))
        return
    end

    FinishOverviewCapture(captureResult, OVERVIEW_RT_SIZE, OVERVIEW_RT_SIZE)
end

local function QueueOverviewCapture()
    hook.Remove("PreRender", OVERVIEW_CAPTURE_HOOK)
    hook.Add("PreRender", OVERVIEW_CAPTURE_HOOK, function()
        hook.Remove("PreRender", OVERVIEW_CAPTURE_HOOK)
        CaptureOverviewLikeGMinimap()
    end)
end

local function StartOverviewCapture(force)
    if mapData.receivedAt <= 0 then
        pendingForceCapture = pendingForceCapture or force
        mapOverview.status = "WAITING FOR SERVER MAP DATA"
        net.Start("GW3_BriefingMapRequest")
        net.SendToServer()
        return
    end

    if mapOverview.active then return end
    if not force and mapOverview.material and not mapOverview.material:IsError() then return end
    if not force and LoadSavedOverview() then return end

    local mins, maxs = GetCaptureBounds()
    mapOverview.mins = mins
    mapOverview.maxs = maxs
    mapOverview.side = math.max(maxs.x - mins.x, maxs.y - mins.y, 2048)
    mapOverview.material = nil
    mapOverview.active = true
    mapOverview.status = "CAPTURING FULL MAP WITH GMINIMAP CAMERA"
    mapOverview.outputFile = nil

    print("[GW3 Map] Capturing full-map overview with GMinimap camera settings for " .. game.GetMap() .. ".")
    QueueOverviewCapture()
end

function GW3.GenerateBriefingOverview(force)
    if mapData.receivedAt <= 0 then
        pendingForceCapture = pendingForceCapture or (force == true)
        mapOverview.status = "REQUESTING SERVER MAP DATA"
        net.Start("GW3_BriefingMapRequest")
        net.SendToServer()
        return
    end
    StartOverviewCapture(force == true)
end

concommand.Add("gw3_capture_map", function()
    GW3.GenerateBriefingOverview(true)
end)

local function RequestMapData()
    net.Start("GW3_BriefingMapRequest")
    net.SendToServer()
    net.Start("GW3_BriefingAssetsRequest")
    net.SendToServer()
end

net.Receive("GW3_BriefingAssetsSync", function()
    briefingAssets.team = net.ReadUInt(2)
    local count = net.ReadUInt(4)
    local rows = {}
    for i = 1, count do
        rows[i] = {
            name = net.ReadString(),
            current = net.ReadUInt(8),
            maximum = net.ReadUInt(8),
            cooldown = net.ReadUInt(16)
        }
    end
    briefingAssets.rows = rows
    briefingAssets.receivedAt = RealTime()
end)

net.Receive("GW3_BriefingMapSync", function()
    mapData.mins = net.ReadVector()
    mapData.maxs = net.ReadVector()
    mapData.viewerTeam = net.ReadUInt(2)

    local entityCount = net.ReadUInt(12)
    local entities = {}
    for i = 1, entityCount do
        local entry = {
            pos = net.ReadVector(),
            team = net.ReadUInt(2),
            kind = net.ReadUInt(3),
            icon = net.ReadUInt(3),
            yaw = net.ReadFloat()
        }
        -- Armor crates are intentionally omitted from the tactical map.
        if entry.icon ~= 6 and entry.kind ~= 4 then
            entities[#entities + 1] = entry
        end
    end

    local teammateCount = net.ReadUInt(8)
    local players = {}
    for i = 1, teammateCount do
        players[i] = {
            pos = net.ReadVector(),
            yaw = net.ReadFloat(),
            name = net.ReadString(),
            isSelf = net.ReadBool()
        }
    end

    local captureCount = net.ReadUInt(5)
    local capturePoints = {}
    for i = 1, captureCount do
        capturePoints[i] = {
            name = net.ReadString(),
            pos = net.ReadVector(),
            radius = net.ReadFloat(),
            owner = net.ReadInt(16),
            ukraineProgress = net.ReadUInt(8),
            russiaProgress = net.ReadUInt(8)
        }
    end

    mapData.entities = entities
    mapData.players = players
    mapData.capturePoints = capturePoints
    mapData.receivedAt = RealTime()

    if pendingForceCapture then
        pendingForceCapture = false
        StartOverviewCapture(true)
    else
        StartOverviewCapture(false)
    end
end)

hook.Add("Think", "GW3_BriefingMap_RequestSync", function()
    if IsValid(GW3.BriefingMapPanel) and GW3.BriefingMapPanel:IsVisible() then
        if CurTime() >= nextDataRequest then
            RequestMapData()
            nextDataRequest = CurTime() + DATA_REQUEST_INTERVAL
        end
    end
end)

local function CountMarkers()
    local counts = { [1] = 0, [2] = 0, [3] = 0, [4] = 0 }
    for _, item in ipairs(mapData.entities) do
        if counts[item.kind] ~= nil then
            counts[item.kind] = counts[item.kind] + 1
        end
    end
    return counts
end

local function GetCaptureStatus(point)
    if point.owner == 1 then return "CONTROLLED BY UKRAINE", TEAM_COLORS[1] end
    if point.owner == 2 then return "CONTROLLED BY RUSSIA", TEAM_COLORS[2] end

    if point.ukraineProgress > 0 or point.russiaProgress > 0 then
        if point.ukraineProgress > point.russiaProgress then
            return "UKRAINE CAPTURING " .. math.floor(point.ukraineProgress / 2) .. "%", TEAM_COLORS[1]
        elseif point.russiaProgress > point.ukraineProgress then
            return "RUSSIA CAPTURING " .. math.floor(point.russiaProgress / 2) .. "%", TEAM_COLORS[2]
        end
        return "CONTESTED", Color(242, 190, 90)
    end

    return "NEUTRAL", Color(170, 180, 190)
end

local function GetCaptureOwnerColor(point)
    return point.owner == 1 and TEAM_COLORS[1]
        or point.owner == 2 and TEAM_COLORS[2]
        or Color(195, 202, 210)
end

local function DrawCaptureRadius(point, x, y, rectW, mins, maxs)
    local worldRadius = math.max(tonumber(point.radius) or 0, 0)
    if worldRadius <= 0 then return end

    local worldSide = math.max(maxs.x - mins.x, maxs.y - mins.y, 1)
    local radiusPixels = worldRadius / worldSide * rectW
    if radiusPixels < 2 then return end
    radiusPixels = math.min(radiusPixels, rectW * 0.48)

    local color = GetCaptureOwnerColor(point)
    -- Two subtle outlines make the actual capture radius visible without
    -- confusing it with the much larger temporary spawn-protection barriers.
    surface.DrawCircle(x, y, radiusPixels, color.r, color.g, color.b, 105)
    surface.DrawCircle(x, y, math.max(1, radiusPixels - 1), color.r, color.g, color.b, 55)
end

local function DrawCapturePoint(point, x, y)
    local ownerColor = GetCaptureOwnerColor(point)

    draw.NoTexture()
    surface.SetDrawColor(8, 12, 17, 245)
    surface.DrawPoly({
        { x = x, y = y - 14 },
        { x = x + 14, y = y },
        { x = x, y = y + 14 },
        { x = x - 14, y = y }
    })
    surface.SetDrawColor(ownerColor.r, ownerColor.g, ownerColor.b, 255)
    surface.DrawPoly({
        { x = x, y = y - 11 },
        { x = x + 11, y = y },
        { x = x, y = y + 11 },
        { x = x - 11, y = y }
    })
    draw.SimpleText("C", "GW3BriefMapMarker", x, y, Color(10, 14, 18), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local title = CAPTURE_NAMES[point.name] or string.upper(string.gsub(point.name, "([a-z])([A-Z])", "%1 %2"))
    local status, statusColor = GetCaptureStatus(point)
    draw.SimpleTextOutlined(title, "GW3BriefMapSmall", x + 15, y - 13,
        Color(245, 247, 250), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 230))
    local shortStatus = point.owner == 1 and "UKR" or point.owner == 2 and "RUS"
        or status == "CONTESTED" and "CONTESTED" or status == "NEUTRAL" and "NEUTRAL" or status
    draw.SimpleTextOutlined(shortStatus, "GW3BriefMapSmall", x + 15, y + 3,
        statusColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 230))
end

local function DrawPNGIcon(iconID, x, y, size, color, rotation)
    local mat = MAP_ICON_MATERIALS[iconID]
    if not mat or mat:IsError() then return false end

    surface.SetMaterial(mat)
    surface.SetDrawColor(color.r, color.g, color.b, color.a or 255)
    surface.DrawTexturedRectRotated(x, y, size, size, rotation or 0)
    return true
end

local function DrawMarker(item, x, y)
    local teamColor = TEAM_COLORS[item.team] or color_white
    local iconID = item.icon or 1
    local size = ((iconID == 4 or iconID == 5 or iconID == 6) and 18 or 24) * MAP_ICON_SCALE
    local rotation = (iconID == 1 or iconID == 2 or iconID == 3) and -(item.yaw or 0) or 0

    if not DrawPNGIcon(iconID, x, y, size, teamColor, rotation) then
        draw.RoundedBox(3, x - 5 * MAP_ICON_SCALE, y - 5 * MAP_ICON_SCALE, 10 * MAP_ICON_SCALE, 10 * MAP_ICON_SCALE, teamColor)
    end
end

local function DrawTeammateMarker(teammate, x, y)
    local teamColor = TEAM_COLORS[mapData.viewerTeam] or color_white
    if not DrawPNGIcon(7, x, y, 20 * MAP_ICON_SCALE, teamColor, 0) then
        draw.RoundedBox(4, x - 5 * MAP_ICON_SCALE, y - 5 * MAP_ICON_SCALE, 10 * MAP_ICON_SCALE, 10 * MAP_ICON_SCALE, teamColor)
    end

    local label = teammate.isSelf and "YOU" or (teammate.name or "TEAMMATE")
    draw.SimpleTextOutlined(label, "GW3BriefMapSmall", x-6* MAP_ICON_SCALE, y+1  * MAP_ICON_SCALE,
        teammate.isSelf and color_white or teamColor,
        TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 235))
end

local function CreateMapCanvas(parent)
    local canvas = vgui.Create("DPanel", parent)
    canvas:Dock(FILL)
    canvas:DockMargin(12, 12, 8, 12)

    canvas.Paint = function(self, w, h)
        surface.SetDrawColor(6, 10, 14, 255)
        surface.DrawRect(0, 0, w, h)

        local rectX, rectY, rectW, rectH, mins, maxs = GetMapRect(w, h)
        local imageReady = mapOverview.material and not mapOverview.material:IsError()

        if imageReady then
            surface.SetMaterial(mapOverview.material)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(rectX, rectY, rectW, rectH)

            -- Live capture point ownership overlay.
            for _, point in ipairs(mapData.capturePoints) do
                local x, y = WorldToMap(point.pos, rectX, rectY, rectW, rectH, mins, maxs)
                if x >= rectX - 40 and x <= rectX + rectW + 40
                and y >= rectY - 40 and y <= rectY + rectH + 40 then
                    DrawCaptureRadius(point, x, y, rectW, mins, maxs)
                    DrawCapturePoint(point, x, y)
                end
            end

            -- Enemy vehicles/crates are filtered on the server and never reach this list.
            for _, item in ipairs(mapData.entities) do
                if item.pos then
                    local x, y = WorldToMap(item.pos, rectX, rectY, rectW, rectH, mins, maxs)
                    if x >= rectX + 2 and x <= rectX + rectW - 2
                    and y >= rectY + 2 and y <= rectY + rectH - 2 then
                        DrawMarker(item, x, y)
                    end
                end
            end

            -- Living teammates, including the local player, update with each sync.
            for _, teammate in ipairs(mapData.players) do
                if teammate.pos then
                    local x, y = WorldToMap(teammate.pos, rectX, rectY, rectW, rectH, mins, maxs)
                    if x >= rectX + 2 and x <= rectX + rectW - 2
                    and y >= rectY + 2 and y <= rectY + rectH - 2 then
                        DrawTeammateMarker(teammate, x, y)
                    end
                end
            end
        else
            surface.SetDrawColor(18, 25, 33, 255)
            surface.DrawRect(rectX, rectY, rectW, rectH)
            surface.SetDrawColor(63, 78, 94, 220)
            surface.DrawOutlinedRect(rectX, rectY, rectW, rectH, 1)
            draw.SimpleText("GENERATING GMINIMAP TERRAIN OVERVIEW", "GW3BriefMapHeader",
                w * 0.5, h * 0.5 - 18, Color(235, 240, 245), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(mapOverview.status, "GW3BriefMapSmall",
                w * 0.5, h * 0.5 + 12, Color(170, 205, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            if mapOverview.active then
                draw.SimpleText("CAPTURING FULL BSP FROM TOP-DOWN VIEW...", "GW3BriefMapSmall",
                    w * 0.5, h * 0.5 + 36, Color(170, 205, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        surface.SetDrawColor(105, 122, 138, 220)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 1)
        surface.SetDrawColor(230, 235, 240, 190)
        surface.DrawRect(12, 12, 3, 28)
        draw.SimpleText(string.upper(game.GetMap()) .. "  /  2D TACTICAL MAP", "GW3BriefMapText",
            24, 26, Color(240, 243, 247), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local syncText = mapData.receivedAt > 0 and "LIVE UNITS  /  1 SEC" or "WAITING FOR SERVER"
        local syncColor = mapData.receivedAt > 0 and Color(130, 220, 155) or Color(240, 190, 90)
        draw.SimpleText(syncText, "GW3BriefMapSmall", w - 14, h - 13,
            syncColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    local recapture = vgui.Create("DButton", canvas)
    recapture:SetSize(118, 25)
    recapture:SetText("RECAPTURE MAP")
    recapture:SetTooltip("Create a fresh top-down PNG from the current map")
    recapture.DoClick = function()
        GW3.GenerateBriefingOverview(true)
    end
    canvas.PerformLayout = function(self, w, h)
        recapture:SetPos(w - recapture:GetWide() - 12, 12)
    end

    return canvas
end

local function DrawSidebar(parent)
    local sidebar = vgui.Create("DPanel", parent)
    sidebar:Dock(FILL)
    sidebar:DockMargin(8, 12, 12, 12)
    sidebar.Paint = function(self, w, h)
        surface.SetDrawColor(28, 28, 28, 225)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(75, 75, 75, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        local teamID = mapData.viewerTeam
        local teamColor = TEAM_COLORS[teamID] or Color(180, 190, 200)
        local teamName = teamID == 1 and "UKRAINIAN FORCES"
            or teamID == 2 and "RUSSIAN FORCES" or "NO TEAM SELECTED"
        local x, y = 14, 18

        draw.SimpleText("MISSION BRIEFING", "GW3BriefMapText", x, y,
            Color(235, 235, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        y = y + 30
        draw.RoundedBox(2, x, y - 9, 4, 20, teamColor)
        draw.SimpleText(teamName, "GW3BriefMapSmall", x + 11, y,
            teamColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        y = y + 27

        draw.SimpleText("FRIENDLY PERSONNEL", "GW3BriefMapSmall", x, y,
            Color(190, 190, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(tostring(#mapData.players), "GW3BriefMapSmall", w - 14, y,
            Color(240, 240, 240), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        y = y + 27

        surface.SetDrawColor(90, 90, 90, 130)
        surface.DrawRect(x, y, w - x * 2, 1)
        y = y + 17
        draw.SimpleText("AVAILABLE ASSETS", "GW3BriefMapText", x, y,
            Color(225, 225, 225), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        y = y + 25

        if briefingAssets.team ~= teamID or #briefingAssets.rows == 0 then
            draw.SimpleText("Waiting for server data...", "GW3BriefMapSmall", x, y,
                Color(165, 165, 165), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            y = y + 30
        else
            for _, row in ipairs(briefingAssets.rows) do
                if y > h - 165 then break end
                draw.SimpleText(row.name, "GW3BriefMapSmall", x, y,
                    Color(235, 235, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(row.current .. " / " .. row.maximum, "GW3BriefMapSmall", w - 14, y,
                    Color(245, 245, 245), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                y = y + 16

                local status = row.current < row.maximum and row.cooldown > 0
                    and ("Respawn: " .. string.format("%02d:%02d", math.floor(row.cooldown / 60), row.cooldown % 60))
                    or (row.current >= row.maximum and "All available" or "No respawn pending")
                local statusColor = row.cooldown > 0 and Color(230, 190, 110) or Color(165, 175, 165)
                draw.SimpleText(status, "GW3BriefMapSmall", x, y, statusColor,
                    TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                y = y + 22
            end
        end

        y = y + 2
        surface.SetDrawColor(90, 90, 90, 130)
        surface.DrawRect(x, y, w - x * 2, 1)
        y = y + 17
        draw.SimpleText("CAPTURE POINTS", "GW3BriefMapText", x, y,
            Color(225, 225, 225), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        y = y + 25

        if #mapData.capturePoints == 0 then
            draw.SimpleText("No active capture points", "GW3BriefMapSmall", x, y,
                Color(160, 160, 160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            for _, point in ipairs(mapData.capturePoints) do
                if y > h - 35 then break end
                local title = CAPTURE_NAMES[point.name] or string.upper(point.name)
                local status, statusColor = GetCaptureStatus(point)
                draw.SimpleText(title, "GW3BriefMapSmall", x, y,
                    Color(235, 235, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                y = y + 17
                draw.SimpleText(status, "GW3BriefMapSmall", x, y,
                    statusColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                y = y + 23
            end
        end
    end
    return sidebar
end

function GW3.CreateBriefingMapPanel(parent)
    if not IsValid(parent) then return end

    local root = vgui.Create("DPanel", parent)
    root:Dock(FILL)
    root:DockPadding(6, 6, 6, 6)
    root.Paint = function(self, w, h)
        surface.SetDrawColor(32, 32, 32, 225)
        surface.DrawRect(0, 0, w, h)
    end

    local mapHolder = vgui.Create("DPanel", root)
    mapHolder:Dock(LEFT)
    mapHolder.Paint = function(self, w, h)
        surface.SetDrawColor(25, 25, 25, 235)
        surface.DrawRect(0, 0, w, h)
    end
    CreateMapCanvas(mapHolder)

    local side = DrawSidebar(root)

    local function LayoutBriefing(w, h)
        local sideWidth = math.Clamp(w * 0.27, 220, 350)
        local mapWidth = math.min(math.max(280, h - 24), math.max(280, w - sideWidth - 24))
        mapHolder:SetWide(mapWidth)
        side:SetWide(sideWidth)
    end

    root.OnSizeChanged = function(self, w, h)
        LayoutBriefing(w, h)
    end
    LayoutBriefing(root:GetWide(), root:GetTall())

    GW3.BriefingMapPanel = root
    nextDataRequest = 0
    RequestMapData()

    root.OnRemove = function()
        if GW3.BriefingMapPanel == root then
            GW3.BriefingMapPanel = nil
        end
    end

    return root
end
