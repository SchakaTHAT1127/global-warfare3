AddCSLuaFile("cl_capturesys.lua")

ModeKurelerTablesi = {
    ["wid_peremen"] = {
        Kureler = {
            ["TokiKure"]   = { pos = Vector(-200.405151, 3079.191406, 83.725899), radius = 1200, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png" },
            ["YorukKure"]  = { pos = Vector(2551.250000, -6756.968750, -550.031250), radius = 1200, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png" },
            ["KasabaKure"] = { pos = Vector(11523.310547, 2078.165771, -159.64688), radius = 2000, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png" },
            ["ukraynaKoy"] = { pos = Vector(-7807.058105, 10200.379883, -530.01007), radius = 1000, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png" }
        }
    },
    ["prm_hrabske"] = {
        Kureler = {
            ["AmkKoy"] = { pos = Vector(-3807.058105, 1200.379883, 330.01007), radius = 550, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png" }
        }
    }
}

local SunucuMapi = game.GetMap()
aktifKureler = ModeKurelerTablesi[SunucuMapi] and ModeKurelerTablesi[SunucuMapi].Kureler or {}

local UKR = UKR or 1
local RUS = RUS or 2

util.AddNetworkString("alertServerKureler")
util.AddNetworkString("updateClientKureData") -- İstemciye güncelleme göndermek için yeni ağ kanalı

net.Receive("alertServerKureler", function(len, ply)
    local isim = net.ReadString()
    local plyTeam = net.ReadInt(16)

    local kure = aktifKureler[isim]
    if not kure then return end

    if plyTeam == UKR then
        if kure.rusCapPoint <= 0 then
            kure.ukraineCapPoint = math.min(kure.ukraineCapPoint + 1, 200)
        elseif kure.rusCapPoint > 0 then
            kure.rusCapPoint = kure.rusCapPoint - 1
        end
    elseif plyTeam == RUS then
        if kure.ukraineCapPoint <= 0 then
            kure.rusCapPoint = math.min(kure.rusCapPoint + 1, 200)
        elseif kure.ukraineCapPoint > 0 then
            kure.ukraineCapPoint = kure.ukraineCapPoint - 1
        end
    end
end)

local nextCheck = 0
hook.Add("Think", "controlledByTeamModifier", function()
    if CurTime() < nextCheck then return end
    nextCheck = CurTime() + 0.1

    for isim, kure in pairs(aktifKureler) do
        local oldFlag = kure.flag

        if kure.ukraineCapPoint == 200 then
            kure.flag = "gamemodes/globalwarfare3/materials/ukraineflag.png"
            kure.controlledByTeam = UKR
        elseif kure.rusCapPoint == 200 then
            kure.flag = "gamemodes/globalwarfare3/materials/russiaflag.png"
            kure.controlledByTeam = RUS
        elseif kure.rusCapPoint == 0 and kure.ukraineCapPoint == 0 then
            kure.flag = "gamemodes/globalwarfare3/materials/unknown.png"
            kure.controlledByTeam = 1001
        end

        print(isim, kure.controlledByTeam, kure.ukraineCapPoint, kure.rusCapPoint)
        
        -- Tüm oyunculara güncel küre durumunu gönder
        net.Start("updateClientKureData")
            net.WriteString(isim)
            net.WriteString(kure.flag)
            net.WriteInt(kure.controlledByTeam, 16)
            net.WriteInt(kure.ukraineCapPoint, 16)
            net.WriteInt(kure.rusCapPoint, 16)
        net.Broadcast()
    end
end)