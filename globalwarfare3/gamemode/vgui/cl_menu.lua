AddCSLuaFile("../shared.lua")

local key = KEY_F3  --key
local IsPressed = false -- is the key pressed
local menu = nil
local cooldown = 0  -- last press time
local cooldownTime = 0.2 -- time to pass
local ply = LocalPlayer()

function menuStart()
    menu = vgui.Create("DFrame")
    menu:SetPos(100, 100)
    menu:SetSize(ScrW(), ScrH())
    menu:SetTitle("")
    menu:Center()
    menu:MakePopup()
    menu:SetAlpha(0)
    menu:AlphaTo(255, 0.8, 0.2)
    -- FRAME
    menu.Paint = function(self, w, h)
        self.startTime = self.startTime or SysTime()
        Derma_DrawBackgroundBlur(self, self.startTime)

        -- background
        surface.SetDrawColor(25, 25, 25, 210)
        surface.DrawRect(0, 0, w, h)

        -- top bar
        surface.SetDrawColor(45, 45, 45, 225)
        surface.DrawRect(0, 0, w, 30)
        draw.SimpleText("Operations Panel", "DermaDefaultBold", 12, 7, Color(220, 220, 220), TEXT_ALIGN_LEFT)
    end
    -- PROPERTY SHEET
    local mSheet = vgui.Create("DPropertySheet", menu)
    mSheet:Dock(FILL)

    mSheet.Paint = function(self, w, h)
        surface.SetDrawColor(125, 125, 125, 5) -- sheet arka plan
        surface.DrawRect(0, 20, w, h - 20)    -- tab butonlarını boyamasın diye 20px üstten boş
    end
    
    local oldAddSheet = mSheet.AddSheet
    function mSheet:AddSheet(label, panel, material, ...)
        local sheet = oldAddSheet(self, label, panel, material, ...)
        local tab = sheet.Tab
        tab.Paint = function(btn, w, h)
            if self:GetActiveTab() == btn then
                surface.SetDrawColor(70, 120, 200, 155) -- active tab
            else
                surface.SetDrawColor(60, 60, 60, 100) -- inactive tab
            end
            surface.DrawRect(0, 0, w, h)
        end
        return sheet
    end

    local briefPanel = vgui.Create("DPanel", mSheet)
    briefPanel.Paint = function(self, w, h)
        surface.SetDrawColor(75, 30, 30, 10)
        surface.DrawRect(0, 0, w, h)    
    end
    mSheet:AddSheet("   Mission Briefing   ", briefPanel, "icon16/report.png")

    local teamPanel = vgui.Create("DPanel", mSheet)
    teamPanel.Paint = function(self, w, h)
        surface.SetDrawColor(66, 126, 245, 10)
        surface.DrawRect(0, 0, w/2, h) --left screen and blue

        surface.SetDrawColor(171, 52, 22, 10) 
        surface.DrawRect(w/2, 0, w/2, h) -- right screen and red
    end
    mSheet:AddSheet("   Team Change   ", teamPanel, "icon16/group_go.png")
    teamPanelMenu(teamPanel) --Calling the panel code
end

--openning system of the menu, grabbed right from 2.3 
hook.Add("Think", "MenuKeyOpenner", function()
    if input.IsKeyDown(key) then
        if not IsPressed and CurTime() > cooldown then  -- BURASI EKLENDİ
            IsPressed = true
            cooldown = CurTime() + cooldownTime  -- tekrar basma zamanı güncelleniyor

            if not IsValid(menu) then
                menuStart()
            else
                menu:Close()
                menu = nil
            end
        end
    else
        IsPressed = false
    end
end)