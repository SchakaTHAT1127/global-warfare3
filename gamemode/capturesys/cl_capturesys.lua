KureMaterial = CreateMaterial("CustomWireframeMat", "UnlitGeneric", {
    ["$basetexture"] = "vgui/white",
    ["$wireframe"]   = 1, 
    ["$vertexcolor"] = 1, 
    ["$vertexalpha"] = 1  
})

ModeKurelerTablesi = {
    ["wid_peremen"] = {
        Kureler = {
            ["TokiKure"]   = { pos = Vector(-200.405151, 3079.191406, 83.725899), radius = 1200, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png"},
            ["YorukKure"]  = { pos = Vector(2551.250000, -6756.968750, -550.031250), radius = 1200, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png" },
            ["KasabaKure"] = { pos = Vector(11523.310547, 2078.165771, -159.64688), radius = 2000, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png" },
            ["RusKoy"]     = { pos = Vector(-7807.058105, 10200.379883, -530.01007), radius = 1000, color = Color(255, 255, 255), controlledByTeam = 1001, ukraineCapPoint = 0, rusCapPoint = 0, flag = "gamemodes/globalwarfare3/materials/unknown.png" }
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
local sw, sh = ScrW(), ScrH()
local KureninIcinde = false
local flagframe = nil
local flagImagePanel = nil
local progressbarUKR = nil
local PointKure = nil
local DynamicTASSAK = nil

local screenSettings = {
    { threshold = 2560, fonts = "MenuSelectHud3", labels = "LabelHud4", yamount = 144 },
    { threshold = 1920, fonts = "MenuSelectHud3", labels = "LabelHud3", yamount = 108 },
    { threshold = 1600, fonts = "MenuSelectHud2", labels = "LabelHud2", yamount = 90 },
    { threshold = 1440, fonts = "MenuSelectHud2", labels = "LabelHud1", yamount = 90 },
    { threshold = 1280, fonts = "MenuSelectHud2", labels = "LabelHud1S", yamount = 77 },
    { threshold = 0,    fonts = "MenuSelectHud1", labels = "LabelHud1S", yamount = 0}
}

for _, setting in ipairs(screenSettings) do
    if sw >= setting.threshold then
        DynamicTASSAK = setting.yamount
        break 
    end
end

-- Sunucudan gelen verileri dinle ve güncelle
net.Receive("updateClientKureData", function()
    local isim = net.ReadString()
    local flag = net.ReadString()
    local controlledByTeam = net.ReadInt(16)
    local ukraineCapPoint = net.ReadInt(16)
    local rusCapPoint = net.ReadInt(16)

    if aktifKureler[isim] then
        aktifKureler[isim].flag = flag
        aktifKureler[isim].controlledByTeam = controlledByTeam
        aktifKureler[isim].ukraineCapPoint = ukraineCapPoint
        aktifKureler[isim].rusCapPoint = rusCapPoint

        -- Eğer oyuncu şu an bu bölgenin içindeyse ve UI açıksa bayrağı anlık güncelle
        if PointKure and PointKure == aktifKureler[isim] and IsValid(flagImagePanel) then
            flagImagePanel:SetImage(flag)
        end
    end
end)

local function flagframeDraw()
    if IsValid(flagframe) then return end
    
    local frameW, frameH = sw / 11, sh / 8.7

    flagframe = vgui.Create("DFrame")
    flagframe:SetPos(sw / 1.13, sh / 30)
    flagframe:SetSize(frameW, frameH)
    flagframe:SetTitle("")
    flagframe:ShowCloseButton(false)
    
    flagframe.Paint = function(self, w, h)
        surface.SetDrawColor(66, 66, 66, 0)
        surface.DrawRect(0, 0, w, h)
    end

    progressbarUKR = vgui.Create("DPanel", flagframe)
    progressbarUKR:SetPos(0, DynamicTASSAK)
    progressbarUKR:SetSize(0, frameH)

    progressbarUKR.Paint = function(self, w, h)
        surface.SetDrawColor(30, 30, 30, 200)
        surface.DrawRect(0, 0, w, h)
        local time = RealTime() * 2

        for x = 0, w do
            -- Soldan sağa x eksenine ve zamana bağlı dalga hesabı (0 ile 1 arasında değer üretir)
            local wave = (math.sin(x * 0.05 - time) + 1) / 2

            -- Dalga bazlı iki renk arasında geçiş yapıyoruz (Örn: Mavi - Parlak Turkuaz)
            local r = Lerp(wave, 0, 0)
            local g = Lerp(wave, 120, 180)
            local b = Lerp(wave, 255, 255)

            surface.SetDrawColor(r, g, b, 200)
            surface.DrawRect(x, 0, 1, h) -- 1 piksel genişliğinde dikey çizgiler çizer
        end
    end


    progressbarRUS = vgui.Create("DPanel", flagframe)
    progressbarRUS:SetPos(0, DynamicTASSAK)
    progressbarRUS:SetSize(0, frameH)

    progressbarRUS.Paint = function(self, w, h)
        surface.SetDrawColor(30, 30, 30, 200)
        surface.DrawRect(0, 0, w, h)

        local time = RealTime() * 2 -- Hız ayarı

        -- Soldan sağa şeritler halinde çizim
        for x = 0, w do
            -- Sinüs dalgası (0 ile 1 arası değer üretir)
            local wave = (math.sin(x * 0.05 - time) + 1) / 2

            -- Koyu Kırmızı (145, 10, 20) ile Parlak Kırmızı/Mercan (255, 60, 40) arasında geçiş
            local r = Lerp(wave, 145, 255)
            local g = Lerp(wave, 10, 60)
            local b = Lerp(wave, 20, 40)

            surface.SetDrawColor(r, g, b, 200)
            surface.DrawRect(x, 0, 1, h)
        end
    end


    -- Panelin boyutunu her karede dinamik olarak güncelleme Hook'u
    progressbarUKR.Think = function(self)
        if PointKure and PointKure.ukraineCapPoint then
            -- Maximum bar genişliği ana çerçevenin genişliği kadar
            -- ukraineCapPoint'in 0-100 veya max puan oranına göre ayarlanması:
            local maxPoint = 200 -- Maksimum ele geçirme puanınız neyse buraya yazın (Örn: 100)
            local progressRatioUkr = math.Clamp(PointKure.ukraineCapPoint / maxPoint, 0, 1)
            
            local targetWidthUkr = frameW * progressRatioUkr
            self:SetWide(targetWidthUkr)
        end
    end

    -- Panelin boyutunu her karede dinamik olarak güncelleme Hook'u
    progressbarRUS.Think = function(self)
        if PointKure and PointKure.rusCapPoint then
            -- Maximum bar genişliği ana çerçevenin genişliği kadar
            -- ukraineCapPoint'in 0-100 veya max puan oranına göre ayarlanması:
            local maxPoint = 200 -- Maksimum ele geçirme puanınız neyse buraya yazın (Örn: 100)
            local progressRatioRus = math.Clamp(PointKure.rusCapPoint / maxPoint, 0, 1)
            
            local targetWidthRus = frameW * progressRatioRus
            self:SetWide(targetWidthRus)
        end
    end
    
    flagImagePanel = vgui.Create("DImage", flagframe)
    if PointKure and PointKure.flag then
        flagImagePanel:SetImage(PointKure.flag)
    end
    flagImagePanel:SetPos(0, 0)
    flagImagePanel:SetSize(frameW, sh / 10.5)
end

local function flagframeClose()
    if IsValid(flagframe) then
        flagframe:Remove()
        flagframe = nil
        flagImagePanel = nil
        progressbarUKR = nil
    end
end

hook.Add("PostDrawTranslucentRenderables", "VisualizeAllSpheres", function()
    if not KureMaterial then return end
    render.SetMaterial(KureMaterial) 
    for kureAdi, kure in pairs(aktifKureler) do
        render.DrawSphere(kure.pos, -kure.radius, 6, 6, kure.color)
        render.DrawSphere(kure.pos, kure.radius, 6, 6, kure.color)
    end
end)

local function dasakx()
    local nextCheck = 0
    hook.Add("Think", "ConquestModeThink", function()
        if CurTime() < nextCheck then return end
        nextCheck = CurTime() + 0.1

        local ply = LocalPlayer()
        if not IsValid(ply) or ply:InVehicle() then return end

        local plyPos = ply:GetPos()
        local plyTeam = ply:Team()
        local herhangiBirKuredemi = false

        for isim, kure in pairs(aktifKureler) do
            if plyPos:DistToSqr(kure.pos) <= (kure.radius * kure.radius) then
                herhangiBirKuredemi = true

                PointKure = kure

                if plyTeam ~= 1001 then 
                    net.Start("alertServerKureler")
                        net.WriteString(isim)
                        net.WriteInt(plyTeam, 16)
                    net.SendToServer()
                end

                if not KureninIcinde then
                    flagframeDraw()
                    KureninIcinde = true
                end
                break
            end
        end

        if not herhangiBirKuredemi and KureninIcinde then
            KureninIcinde = false
            PointKure = nil
            flagframeClose()
        end
    end)
end

dasakx()