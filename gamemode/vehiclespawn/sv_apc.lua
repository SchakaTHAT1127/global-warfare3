print("svapc")
--print(sv_ukrainetruckamount:GetInt())

--[[
local function KoordinatAyarlayiciMapeGore()
    for _,data in pairs(KullanilabilirMapler) do -- init.lua'da bulunmakta table
    	print(data) -- sırayla gw_peremen3 ....... diye sıralar
    end
end
-------

for i = 1, amount do
        local nokta = koordinatlar[i]
        if not nokta then continue end
        
        local car = ents.Create("sw_gaz66")
        if not IsValid(car) then continue end 

        car:SetPos(nokta.pos)
        car:SetAngles(nokta.ang)
        car:Spawn()
        car:Activate()
    end

entAraclarUkrayna = {
    ["kamyon"] = { class = "sw_gaz66", getMiktar = function() return cv_kamyonMiktarUkr:GetInt() end, getCooldown = function() return cv_kamyonCooldownUkr:GetInt() end, ticket = 10 },
    ["transport"] = { class = "sw_uaz469", getMiktar = function() return cv_transportMiktarUkr:GetInt() end, getCooldown = function() return cv_transportCooldownUkr:GetInt() end, ticket = 10 },
    ["zirhli"] = { class = "sw_btr60", getMiktar = function() return cv_zirhliMiktarUkr:GetInt() end, getCooldown = function() return cv_zirhliCooldownUkr:GetInt() end, ticket = 20 }
}

local car = ents.Create(entAraclarUkrayna[name].class)
            if not IsValid(car) then continue end
            
            car:SetPos(nokta.pos)
            car:SetAngles(nokta.ang)
            car:Spawn()
            car:Activate()

]]
-- peremen 3 ukrayna koordinatlarına göre hazırlandı 
-- render.DrawSphere diye bir şey var. güzel. kullanılabilir.


local SunucuMapi = game.GetMap()

-- Harita tablosunu bu şekilde değiştirirsen:
local MaplerVeKoordinatlar = {
    ["gw_peremen3"] = { pos = Vector(9332, -11245, -47), ang = Angle(0, 180, 0) },
    ["prm_hrabske"] = { pos = Vector(9332, -11245, -47), ang = Angle(0, 180, 0) },
    ["prm_molodoy"] = { pos = Vector(9332, -11245, -47), ang = Angle(0, 180, 0) }
}

local AracCord = MaplerVeKoordinatlar[SunucuMapi] 
local ACseferSayisi = 0

local function KordinatBos()
    local finderSphere = ents.FindInSphere(GeciciPos, 120)
    for id, ent in pairs(finderSphere) do
        if ent:IsVehicle() then
            return true
        end
    end
    return false
end

local function SpawnVehicleUkraynaInitial()
    local GeciciPos = Vector(AracCord.pos, AracCord.pos.y, AracCord.pos.z)
    for name, _ in pairs(entAraclarUkrayna) do
        for k, v in pairs(entAraclarUkrayna[name]) do

            while not KordinatBos(GeciciPos) do
                GeciciPos.x = GeciciPos.x + 300
                ACseferSayisi = ACseferSayisi + 1
            end

            local vehicleUkr = ents.Create(entAraclarUkrayna[name].class)

            vehicleUkr:SetPos(AracCord.pos)
            vehicleUkr:SetAngles(AracCord.ang)
            vehicleUkr:Spawn()
            vehicleUkr:Activate()

            ACseferSayisi = ACseferSayisi * 300
            GeciciPos.x = GeciciPos.x - ACseferSayisi
            ACseferSayisi = 0
        end
    end
end

local function YazdiriciTester()
    for name, _ in pairs(entAraclarUkrayna) do
        print("\n"..name)
        for k, v in pairs(entAraclarUkrayna[name]) do
            print(k, v)   
        end
    end
end