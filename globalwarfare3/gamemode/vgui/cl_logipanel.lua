GW3 = GW3 or {} -- Gamemode ismine özel bir tablo oluştur

function GW3.logiPanelMenu(parentPanel)
    local panel = parentPanel
    local wide = ScrW()
    local tall = ScrH()

    local buttonHeight = 30
    local buttonWide = 200
    local ply = LocalPlayer()
    local team = ply:Team()

    local DermaButton = vgui.Create( "DButton", panel)
    DermaButton:SetText( "" ) 
    DermaButton:SetPos(ScrW() * 0.25 - (buttonWide / 2), ScrH() / 2.5 - (buttonHeight / 2) + buttonHeight + 12)
    DermaButton:SetSize(buttonWide, 30)
    DermaButton.DoClick = function()
        GW3.uiSound("button") -- just ui sound maker
        net.Start("logiRequest")
            net.WriteString("assault") -- the weapon we want
        net.SendToServer()
    end
    DermaButton.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 215)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(30, 73, 173, 115)
        surface.DrawRect(2, 2, w-4, h-4)

        draw.SimpleTextOutlined(
            "Ammunation Box",
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
    return panel
end