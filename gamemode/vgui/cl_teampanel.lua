AddCSLuaFile("../shared.lua")
GW3 = GW3 or {} -- Gamemode ismine özel bir tablo oluştur

function GW3.teamPanelMenu(parentPanel)
    local panel = parentPanel

    local scale = ScrW() * 0.3 
    local imgW, imgH = 1100, 600 -- Takım bayrak resimlerinin büyüklüğü 
    local aspect = imgH / imgW

    local nW = scale
    local nH = nW * aspect

    local sW = scale
    local sH = sW * aspect

    local btnW = imgW -- Buton ve resmin genişliğini aynı yaptım

    local DermaButton = vgui.Create( "DButton", panel)
    DermaButton:SetText( "" ) 
    DermaButton:SetPos(ScrW() * 0.25 - (nW / 2), ScrH() / 2.5 - (nH / 2) + nH + 12)
    DermaButton:SetSize(nW, 30)
    DermaButton.DoClick = function()
        net.Start( "SendTeam" )
            net.WriteUInt(1,2) -- UKR (1), 2 BIT
        net.SendToServer()
        GW3.uiSound("button")
        GW3.uiSound("team") -- sesleri oynatıyoz
    end
    DermaButton.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 215)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(30, 73, 173, 115)
        surface.DrawRect(2, 2, w-4, h-4)

        draw.SimpleTextOutlined(
            "Ukrainian Ground Forces",
            "MenuSelectHud2",
            w / 2,
            h / 2,
            Color(230, 230, 230),           -- color
            TEXT_ALIGN_CENTER,              -- xalignment
            TEXT_ALIGN_CENTER,              -- yalignment
            1,                              -- outline wideness
            Color(5, 5, 5, 255)
        )
    end

    local DermaButton = vgui.Create("DButton", panel) 
    DermaButton:SetText("")
    DermaButton:SetPos(ScrW() * 0.75 - (sW / 2), ScrH() / 2.5 - (sH / 2) + sH + 12) -- Hiçbir fikrim yok
    DermaButton:SetSize(nW, 30)
    DermaButton.DoClick = function()
        net.Start( "SendTeam" )
            net.WriteUInt(2,2) -- RUS (2), 2 BIT
        net.SendToServer()  
        GW3.uiSound("button")
        GW3.uiSound("team")
    end

    DermaButton.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 225)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(236,67,61, 115)
        surface.DrawRect(2, 2.4, w-5, h-5)
        draw.SimpleTextOutlined(
            "Russian Ground Forces",
            "MenuSelectHud2",
            w / 2,
            h / 2,
            Color(230, 230, 230),           -- color
            TEXT_ALIGN_CENTER,              -- xalignment
            TEXT_ALIGN_CENTER,              -- yalignment
            1,                              -- outline wideness
            Color(5, 5, 5, 255)
        )
    end

    local scale = ScrW() * 0.3 
    local imgW, imgH = 1100, 600
    local aspect = imgH / imgW

    -- ukrayna resim
    local ukr = vgui.Create("DImage", panel)
    ukr:SetSize(nW, nH)    
    ukr:SetPos(ScrW() * 0.25 - (nW / 2), ScrH() / 2.5 - (nH / 2))

    -- rusya resim
    local rus = vgui.Create("DImage", panel)
    rus:SetSize(sW, sH)
    rus:SetPos(ScrW() * 0.75 - (sW / 2), ScrH() / 2.5 - (sH / 2))

    -- Aşağıdakilerde karanlık hissi versin diye vignet
    wideVignet = panel:GetWide()
    tallVignet = panel:GetTall()

    local vignet = vgui.Create("DImage", panel)
    vignet:Center()
    vignet:SetSize(ScrW(),ScrH()) 

    local vigmid = vgui.Create("DImage", panel)  -- Add image to Frame
    vigmid:SetPos(ScrW()/2.25,ScrH()-ScrH())
    vigmid:SetSize(ScrW()/10, ScrH()) 

    rus:SetImage("gamemodes/globalwarfare3/materials/russian.png")
    ukr:SetImage("gamemodes/globalwarfare3/materials/ukraine.png")

    vignet:SetImage("gamemodes/globalwarfare3/materials/vignet.png")
    vigmid:SetImage("gamemodes/globalwarfare3/materials/lalali.png")

    return panel
end
