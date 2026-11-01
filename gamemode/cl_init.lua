-- Client kodlarını ekliyoruz
include("shared.lua")
include("vgui/cl_briefingmap.lua")
include("vgui/cl_menu.lua")
include("vgui/cl_teampanel.lua")
include("vgui/cl_winnermenu.lua")
include("vgui/cl_tabmenu.lua")
include("sounds/cl_soundpr.lua")
include("logihandler/cl_logihandler.lua")
include("cratehints/cl_cratehints.lua")
include("capturesys/cl_capturesys.lua")
include("player/cl_playercustomization.lua")
-- Fontlar.
surface.CreateFont( "LabelHud1S", {
	font = "Arial",
	extended = false,
	size = 15,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "LabelHud1", {
	font = "Arial",
	extended = false,
	size = 16,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "LabelHud2", {
	font = "Arial",
	extended = false,
	size = 18,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "LabelHud3", {
	font = "Arial",
	extended = false,
	size = 20,
	weight = 560,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "LabelHud4", {
	font = "Arial",
	extended = false,
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "MenuSelectHud2", {
	font = "Arial",
	extended = false,
	size = 24,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "MenuSelectHud3", {
	font = "Arial",
	extended = false,
	size = 30,
	weight = 400,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "LoadSelectHud", {
	font = "Arial",
	extended = false,
	size = 2,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = true,
	outline = false,
} )

surface.CreateFont( "BigLoadSelectHud", {
	font = "CreditsOutroText",
	extended = false,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = true,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = true,
	outline = true,
} )

GW3 = GW3 or {}

local barriers = {}
local barrierColors = {
    [1] = Color(40, 140, 255, 230),
    [2] = Color(255, 65, 65, 230),
}

net.Receive("GW3_TeamBarrierSync", function()

    for _, teamID in ipairs({ UKR, RUS }) do
        barriers[teamID] = {
            active = net.ReadBool(),
            pos = net.ReadVector(),
            radius = net.ReadFloat(),
            endTime = net.ReadFloat()
        }
    end

end)

-- KÜRELERİ ÇİZ
hook.Add("PostDrawTranslucentRenderables", "GW3_DrawTeamBarriers", function(depth, skybox)

    if depth or skybox then return end

    for teamID, data in pairs(barriers) do

        if not data.active or CurTime() >= data.endTime then
            continue
        end

        render.DrawWireframeSphere(
            data.pos,
            data.radius,
            32,
            16,
            barrierColors[teamID] or barrierColors[1],
            true
        )

    end

end)

local baskatable = {
    -- Team 1 = Ukraine, Team 2 = Russia. Keep these centers identical
    -- to the server-side TeamBarriers table so the circles never swap sides.
    [UKR] = {
        -- Match the center of the actual Ukrainian player-spawn cluster.
        pos = Vector(13487.118765, -12187.677358, -70.968750),
        radius = 5000
    },
    [RUS] = {
        pos = Vector(-13667.385742, -1544.606445, -762.212280),
        radius = 5000
    }
}

local glowingPlayers = {}
local nextHaloRefresh = 0
local haloRefreshInterval = 0.2
local enemyHaloColor = Color(255, 0, 0)
local zoneOneRadiusSqr = baskatable[UKR].radius * baskatable[UKR].radius
local zoneTwoRadiusSqr = baskatable[RUS].radius * baskatable[RUS].radius

-- Rakip spawnına girmiş oyuncu hem halo listesine eklenir hem de
-- kendi ekranında uyarı görür.
local function IsPlayerInEnemySpawn(ply)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then
        return false
    end

    local teamID = ply:Team()
    local plyPos = ply:GetPos()

    if teamID == 2 then
        return plyPos:DistToSqr(baskatable[UKR].pos) <= zoneOneRadiusSqr
    elseif teamID == 1 then
        return plyPos:DistToSqr(baskatable[RUS].pos) <= zoneTwoRadiusSqr
    end

    return false
end

hook.Add("PreDrawHalos", "GW3_EnemyZoneWallhack", function()
    local now = CurTime()

    if now >= nextHaloRefresh then
        nextHaloRefresh = now + haloRefreshInterval
        table.Empty(glowingPlayers)

        for _, ply in ipairs(player.GetAll()) do
            if IsPlayerInEnemySpawn(ply) then
                glowingPlayers[#glowingPlayers + 1] = ply
            end
        end
    end

    if #glowingPlayers > 0 then
        halo.Add(glowingPlayers, enemyHaloColor, 1, 1, 1, true, true)
    end
end)

-- Yalnızca rakip spawnında bulunup parlayan oyuncunun ekranında görünür.
hook.Add("HUDPaint", "GW3_EnemySpawnGlowWarning", function()
    local ply = LocalPlayer()
    if not IsPlayerInEnemySpawn(ply) then return end

    local centerX = ScrW() / 2
    draw.SimpleTextOutlined(
        "YOU ARE SHINING!",
        "Trebuchet24",
        centerX,
        105,
        Color(255, 55, 55),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        2,
        Color(0, 0, 0, 230)
    )

    draw.SimpleTextOutlined(
        "The enemy can see you, Leave the enemys spawn area!",
        "Trebuchet20",
        centerX,
        132,
        Color(255, 255, 255),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        1,
        Color(0, 0, 0, 230)
    )
end)

if CLIENT then

    local function IsAllowedToOpenMenus()
        local ply = LocalPlayer()
        return IsValid(ply) and ply:IsSuperAdmin()
    end

    -- Q menüsü
    hook.Add("SpawnMenuOpen", "GW3_AdminOnlySpawnMenu", function()
        if not IsAllowedToOpenMenus() then
            return false
        end
    end)

    -- C menüsü
    hook.Add("ContextMenuOpen", "GW3_AdminOnlyContextMenu", function()
        if not IsAllowedToOpenMenus() then
            return false
        end
    end)

    -- Q ve C tuşlarını da engelle
    hook.Add("PlayerBindPress", "GW3_AdminOnlyMenuKeys", function(ply, bind)
        if not IsValid(ply) or ply:IsSuperAdmin() then return end

        bind = string.lower(bind)

        if bind == "+menu" or bind == "+menu_context" then
            return true
        end
    end)
end

hook.Add("PlayerButtonDown", "F2ClientCommand", function(ply, button)
    if ply ~= LocalPlayer() then return end

    if button == KEY_F2 then
        RunConsoleCommand("rapd_show_info")
    end
end)