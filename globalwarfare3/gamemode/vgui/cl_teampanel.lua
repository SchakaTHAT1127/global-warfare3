AddCSLuaFile("../shared.lua")

function teamPanelMenu(parentPanel)
    local panel = parentPanel

    local scale = ScrW() * 0.3 
    local imgW, imgH = 1100, 600 -- this is the images scale
    local aspect = imgH / imgW

    local nW = scale
    local nH = nW * aspect

    local sW = scale -- original scale
    local sH = sW * aspect

    local btnW = imgW -- make the buttons and images same wide
    print(nH)

    local DermaButton = vgui.Create( "DButton", panel)
    DermaButton:SetText( "" ) 
    DermaButton:SetPos(ScrW() * 0.25 - (nW / 2), ScrH() / 2.5 - (nH / 2) + nH + 12)
    DermaButton:SetSize(nW, 30)
    DermaButton.DoClick = function()
        net.Start( "SendTeam" )
            net.WriteUInt(1,2) -- This is NATO
        net.SendToServer()
    end
    DermaButton.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 215)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(30, 73, 173, 115)
        surface.DrawRect(2, 2, w-4, h-4)

        draw.SimpleTextOutlined(
            "North Atlantic Treaty Forces",
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
    DermaButton:SetPos(ScrW() * 0.75 - (sW / 2), ScrH() / 2.5 - (sH / 2) + sH + 12) -- works good i see
    DermaButton:SetSize(nW, 30)
    DermaButton.DoClick = function()
        net.Start( "SendTeam" )
            net.WriteUInt(2,2) -- This is soviet
        net.SendToServer()
    end

    DermaButton.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 225)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(243, 28, 28, 115)
        surface.DrawRect(2, 2.4, w-5, h-5)
        draw.SimpleTextOutlined(
            "Soviet Ground Forces",
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

    -- NATO
    local nato = vgui.Create("DImage", panel)
    nato:SetSize(nW, nH)    
    nato:SetPos(ScrW() * 0.25 - (nW / 2), ScrH() / 2.5 - (nH / 2))

    -- SOVIET
    local soviet = vgui.Create("DImage", panel)
    soviet:SetSize(sW, sH)
    soviet:SetPos(ScrW() * 0.75 - (sW / 2), ScrH() / 2.5 - (sH / 2))

    wideVignet = panel:GetWide()
    tallVignet = panel:GetTall()

    local vignet = vgui.Create("DImage", panel)
    vignet:Center()
    vignet:SetSize(ScrW(),ScrH()) 

    local vigmid = vgui.Create("DImage", panel)  -- Add image to Frame
    vigmid:SetPos(ScrW()/2.25,ScrH()-ScrH())
    vigmid:SetSize(ScrW()/10, ScrH()) 

    soviet:SetImage("gamemodes/globalwarfare3/gamemode/content/materials/soviet.png")
    nato:SetImage("gamemodes/globalwarfare3/gamemode/content/materials/nato.png")
    --vignet and vigmid is just vignette efects
    vignet:SetImage("gamemodes/globalwarfare3/gamemode/content/materials/vignet.png")
    vigmid:SetImage("gamemodes/globalwarfare3/gamemode/content/materials/lalali.png")

    return panel
end