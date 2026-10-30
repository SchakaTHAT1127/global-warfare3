AddCSLuaFile("../shared.lua")

local key = KEY_F2
local IsPressed = false
local menu = nil
local cooldown = 0
local cooldownTime = 0.2
local cooldown2 = 0
local cooldownTime2 = 1
local sopar = 20

net.Receive("GW3_WinMenuStart", function()
    local wincolor = net.ReadColor()
    local winyazisi = net.ReadString()
    local winmuzigi = net.ReadString()

    WinMenuStart(wincolor, winyazisi)
    surface.PlaySound(winmuzigi)
end)

-- FONTLAR
surface.CreateFont("GW_MenuTitle", {
    font = "Arial",
    size = 36,
    weight = 1000,
    antialias = true
})

surface.CreateFont("GW_MenuSubtitle", {
    font = "Arial",
    size = 15,
    weight = 600,
    antialias = true
})

surface.CreateFont("GW_TeamName", {
    font = "Arial",
    size = 23,
    weight = 1000,
    antialias = true
})

surface.CreateFont("GW_TicketNumber", {
    font = "Arial",
    size = 42,
    weight = 1000,
    antialias = true
})

surface.CreateFont("GW_VS", {
    font = "Arial",
    size = 85,
    weight = 1000,
    antialias = true
})

surface.CreateFont("GW_CenterText", {
    font = "Arial",
    size = 16,
    weight = 800,
    antialias = true
})



function WinMenuStart(wincolor, winyazisi)

    local w = ScrW()
    local h = ScrH()

    local imgW = w * 0.30
    local imgH = imgW * (600 / 1100)

    local ukrX = w * 0.25 - imgW / 2
    local rusX = w * 0.75 - imgW / 2

    local imgY = h / 2.5 - imgH / 2
    local centerX = w / 2
    local centerY = imgY + imgH / 2

    menu = vgui.Create("DFrame")
    menu:SetPos(0, 0)
    menu:SetSize(w, h)
    menu:SetTitle("")
    menu:SetDraggable(false)
    menu:ShowCloseButton(false)
    menu:MakePopup()

    menu:SetAlpha(0)
    menu:AlphaTo(255, 2, 0.1)

    menu.Paint = function(self, pw, ph)

        self.startTime = self.startTime or SysTime()

        Derma_DrawBackgroundBlur(self, self.startTime)
        surface.SetDrawColor(wincolor)
        surface.DrawRect(0, 0, pw, ph)

        -- UKRAINE TICKET PANEL
        local cardY = imgY + imgH + 22
        local cardW = imgW
        local cardH = 105

        draw.RoundedBox(
            8,
            ukrX,
            cardY,
            cardW,
            cardH,
            Color(12, 20, 32, 240)
        )
        surface.SetDrawColor(65, 135, 225, 220)
        surface.DrawOutlinedRect(ukrX, cardY, cardW, cardH, 2)

        draw.SimpleText(
            "Ukrainian Ground Forces",
            "GW_TeamName",
            ukrX + cardW / 2,
            cardY + 27,
            Color(100, 165, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            tostring(team.GetScore(1).." Tickets"),
            "GW_TicketNumber",
            ukrX + cardW / 2,
            cardY + 72,
            Color(235, 240, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )


        -- RUSSIA TICKET PANEL
        draw.RoundedBox(
            8,
            rusX,
            cardY,
            cardW,
            cardH,
            Color(32, 14, 14, 240)
        )

        surface.SetDrawColor(210, 65, 65, 220)
        surface.DrawOutlinedRect(rusX, cardY, cardW, cardH, 2)

        draw.SimpleText(
            "Russian Ground Forces",
            "GW_TeamName",
            rusX + cardW / 2,
            cardY + 27,
            Color(255, 105, 105),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )

        draw.SimpleText(
            tostring(team.GetScore(2)).." Tickets",
            "GW_TicketNumber",
            rusX + cardW / 2,
            cardY + 72,
            Color(255, 235, 235),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
        draw.SimpleTextOutlined(
            winyazisi,
            "GW_VS",
            centerX,
            centerY*2,
            Color(240, 240, 240),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            3,
            Color(0, 0, 0, 255)
        )
        draw.SimpleTextOutlined(
            "Time to restart server: "..sopar,
            "GW_TeamName",
            centerX,
            centerY*2.2,
            Color(240, 240, 240),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            3,
            Color(0, 0, 0, 255)
        )
    end


    -- UKRAINE RESİM
    local ukr = vgui.Create("DImage", menu)
    ukr:SetSize(imgW, imgH)
    ukr:SetPos(ukrX, imgY)
    ukr:SetImage("gamemodes/globalwarfare3/materials/ukraine.png")


    -- RUSSIA RESİM
    local rus = vgui.Create("DImage", menu)
    rus:SetSize(imgW, imgH)
    rus:SetPos(rusX, imgY)
    rus:SetImage("gamemodes/globalwarfare3/materials/russian.png")

end

-- F2 MENU AÇMA / KAPATMA
hook.Add("Think", "WinnerMenuKeyOpenner", function()
    if input.IsKeyDown(key) then
        if not IsPressed and CurTime() > cooldown then

            IsPressed = true
            cooldown = CurTime() + cooldownTime

            if not IsValid(menu) then
                WinMenuStart(Color(20,20,30,220), "Ukrayna Kazandasdası")
            else
                menu:Close()
                menu = nil
            end
        end
    else
        IsPressed = false
    end
end)

hook.Add("Think", "partsCLIENT", function()
    if IsValid(menu) and CurTime() > cooldown2 then
        cooldown2 = CurTime() + cooldownTime2
        print("sopar client")
        sopar = sopar - 1
    end
end)