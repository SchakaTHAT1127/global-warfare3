-- Global Warfare 3 - optimized crate hint renderer.
-- One HUDPaint hook handles every crate class; entity lists refresh twice per second.

local crateHintConfigs = {
    {
        class = "ent_logicrate",
        maxDistanceSqr = 300 * 300,
        offset = Vector(0, 0, 25),
        title = "Ukranian Logistics Crate",
        amountKey = "logisticAmountUkr",
        titleWidth = 240,
        titleColor = Color(0, 0, 0, 150),
        amountColor = Color(0, 33, 203, 90),
    },
    {
        class = "ent_logicrate_ussr",
        maxDistanceSqr = 300 * 300,
        offset = Vector(0, 0, 25),
        title = "Russian Logistics Crate",
        amountKey = "logisticAmountRus",
        titleWidth = 240,
        titleColor = Color(0, 0, 0, 150),
        amountColor = Color(236, 67, 61, 150),
    },
    {
        class = "ent_buildcrate",
        maxDistanceSqr = 300 * 300,
        offset = Vector(0, 0, 25),
        title = "Construction and Barricade Box",
        amountKey = "buildLogisticAmount",
        titleWidth = 340,
        titleColor = Color(0, 0, 0, 150),
        amountColor = Color(103, 133, 103, 90),
    },
    {
        class = "ent_armorcrate",
        maxDistanceSqr = 300 * 300,
        offset = Vector(0, 0, 25),
        title = "Ukranian Armor Box",
        amountKey = "armorUKRLogisticAmount",
        titleWidth = 340,
        titleColor = Color(0, 0, 0, 150),
        amountColor = Color(0, 33, 203, 90),
    },
    {
        class = "ent_armorcrate_ussr",
        maxDistanceSqr = 300 * 300,
        offset = Vector(0, 0, 25),
        title = "Russian Armor Box",
        amountKey = "armorRUSLogisticAmount",
        titleWidth = 340,
        titleColor = Color(0, 0, 0, 150),
        amountColor = Color(236, 67, 61, 150),
    },
    {
        class = "ent_radcrate",
        maxDistanceSqr = 350 * 350,
        offset = Vector(0, 0, 10),
        title = "Open box to get radio equipment",
        titleWidth = 340,
        titleColor = Color(0, 0, 0, 150),
    },
}

local cachedCrates = {}
local nextCrateRefresh = 0
local crateRefreshInterval = 0.5
local white = Color(255, 255, 255)

local function RefreshCrateCache()
    local newCache = {}

    for _, config in ipairs(crateHintConfigs) do
        for _, ent in ipairs(ents.FindByClass(config.class)) do
            if IsValid(ent) then
                newCache[#newCache + 1] = {
                    entity = ent,
                    config = config,
                }
            end
        end
    end

    cachedCrates = newCache
end

hook.Add("HUDPaint", "GW3_OptimizedCrateHints", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local now = CurTime()
    if now >= nextCrateRefresh then
        nextCrateRefresh = now + crateRefreshInterval
        RefreshCrateCache()
    end

    if #cachedCrates == 0 then return end

    local playerPos = ply:GetPos()

    for i = 1, #cachedCrates do
        local entry = cachedCrates[i]
        local ent = entry.entity
        local config = entry.config

        if not IsValid(ent) then continue end

        local entPos = ent:GetPos()
        if playerPos:DistToSqr(entPos) > config.maxDistanceSqr then continue end

        local screenData = (entPos + config.offset):ToScreen()
        if not screenData.visible then continue end

        local x, y = screenData.x, screenData.y
        draw.RoundedBox(4, x - config.titleWidth / 2, y - 13, config.titleWidth, 25, config.titleColor)
        draw.SimpleText(config.title, "TargetID", x, y, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if config.amountKey then
            local amount = ent:GetNWInt(config.amountKey, 0)
            draw.RoundedBox(4, x - 90, y + 23, 180, 25, config.amountColor)
            draw.SimpleText("Amount: " .. amount, "TargetID", x, y + 36, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Press Walk (ALT) + Use", "LabelHud1", x, y + 60, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Press Walk (ALT) + Use", "LabelHud1", x, y + 25, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)
