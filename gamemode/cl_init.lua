-- Client kodlarını ekliyoruz
include("shared.lua")
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

    for teamID = 1, 2 do
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
    [2] = {
        pos = Vector(-13667.385742, -1544.606445, -762.212280),
        radius = 5000
    },

    [1] = {
        pos = Vector(12199.857422, -12617.125000, -47.968742),
        radius = 5000
    }
}

local glowingPlayers = {}
local nextHaloRefresh = 0
local haloRefreshInterval = 0.2
local enemyHaloColor = Color(255, 0, 0)
local zoneOneRadiusSqr = baskatable[1].radius * baskatable[1].radius
local zoneTwoRadiusSqr = baskatable[2].radius * baskatable[2].radius

hook.Add("PreDrawHalos", "GW3_EnemyZoneWallhack", function()
    local now = CurTime()

    if now >= nextHaloRefresh then
        nextHaloRefresh = now + haloRefreshInterval

        for i = #glowingPlayers, 1, -1 do
            glowingPlayers[i] = nil
        end

        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) or not ply:Alive() then continue end

            local teamID = ply:Team()
            local plyPos = ply:GetPos()

            if teamID == 2 then
                if plyPos:DistToSqr(baskatable[1].pos) <= zoneOneRadiusSqr then
                    glowingPlayers[#glowingPlayers + 1] = ply
                end
            elseif teamID == 1 then
                if plyPos:DistToSqr(baskatable[2].pos) <= zoneTwoRadiusSqr then
                    glowingPlayers[#glowingPlayers + 1] = ply
                end
            end
        end
    end

    if #glowingPlayers > 0 then
        halo.Add(glowingPlayers, enemyHaloColor, 1, 1, 1, true, true)
    end
end)