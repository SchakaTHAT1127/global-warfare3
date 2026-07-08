-- bütün cl ve sv dosyalarını ekliyoruz
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("vgui/cl_menu.lua")
AddCSLuaFile("vgui/cl_teampanel.lua")
AddCSLuaFile("vgui/cl_tabmenu.lua")
AddCSLuaFile("sounds/cl_soundpr.lua")
AddCSLuaFile("logihandler/cl_logihandler.lua")
AddCSLuaFile("capturesys/cl_capturesys.lua")
AddCSLuaFile("shared.lua")

include("logihandler/sv_logihandler.lua")
include("shared.lua") 
include("player/playercustomization.lua")
include("vgui/sv_menu.lua")
include("cvars.lua")
include("capturesys/sv_capturesys.lua")

include("vehiclespawn/sv_ukraine_arac_spawn.lua")
include("vehiclespawn/sv_russia_arac_spawn.lua")

include("ticketsys/sv_ticketsystem.lua")

--Ana oyunmodunu seçiyoz
DeriveGamemode("sandbox")

--Bunu yazaraktan basit bir şekilde tüm takımları tek bir rakama sığdırıyorum
-- bu sayede bazı durumlarda işim daha kolaylaşıyor
UKR = 1
RUS = 2

-- Ticket variablesini oluşturuyoruz ve bi sayı veriyoruz
UKRticket = 100
RUSticket = 100

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

-- Takımlar:
team.SetUp(UKR, "Ukrainian Ground Forces", Color(0, 33, 203))
team.SetUp(RUS, "Russian Ground Forces", Color(223, 8, 8))

-- Oyuncunun kendisini öldürmesini yasaklayıp yasaklamamak
hook.Add("CanPlayerSuicide", "stopSuicide", function(ply)
    return true
end)

--Burada, oyuncunun takımına göre girebileceği araçları ayarlıyoruz.
hook.Add( "CanPlayerEnterVehicle", "PrintPlayersInVehicles", function( ply, veh, role )
    local parentVehicle = veh:GetParent() --LVS araçlarında koltuk vehicleleri vardır, ana parenti olan aracı alıyoz ki genelleme olsun
    local team = ply:Team()

    if not IsValid(parentVehicle) then return false end 

    --Ukraynanın girebildikleri
    local ukrVehicleList = {
        "sw_gaz66",
        "sw_uaz469",
        "sw_btr60"
    }

    --rusyanın girebildikleri
    local rusVehicleList = {
        "sw_ural4320",
        "sw_gaz2330",
        "sw_btr82",
        "sw_mtlb"
    }

    --Eğer takım 1(Ukrayna) ise isim ve data(class) olarak
    if team == 1 then
        for _, data in ipairs(ukrVehicleList) do -- Birini seçtik
            if parentVehicle:GetClass() == data then -- Binmeye çalıştığı aracın adı datadaki isimle aynı mı diye baktık
                return true -- öyleyse okey dedik bin dedik
            end
        end
        return false --değilse çöpe attık

    elseif team == 2 then -- aynısı yukardakinin
        for _, data in ipairs(rusVehicleList) do
            if parentVehicle:GetClass() == data then
                return true
            end
        end
        return false 

    else -- hata durumda binemesin
        return false
    end
end )

hook.Add( "InitPostEntity", "SunucuHazirKodu", function() --Her şey yüklendikten sonra ticketleri tekrar setliyoruz, ve her takıma score olarak ticketleri koyuyoruz. 
    print("InitPostEntity")
    UKRticket = 100
    RUSticket = 100
    team.SetScore(1, UKRticket)
    team.SetScore(2, RUSticket)
end)