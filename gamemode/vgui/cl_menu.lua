AddCSLuaFile("../shared.lua")

local key = KEY_F3  --key
local IsPressed = false -- is the key pressed
local menu = nil
local cooldown = 0  -- last press time
local cooldownTime = 0.2 -- time to pass
local ply = LocalPlayer()

function menuStart()
    menu = vgui.Create("DFrame")
    menu:SetPos(0, 0)
    menu:SetSize(ScrW(), ScrH())
    menu:SetTitle("")
    menu:ShowCloseButton(false)
    menu:SetDraggable(false)
    menu:SetSizable(false)
    menu:MakePopup()
    GW3.BriefingMenu = menu
    menu.OnClose = function()
        if GW3.BriefingMenu == menu then GW3.BriefingMenu = nil end
    end
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
    if GW3.CreateBriefingMapPanel then
        GW3.CreateBriefingMapPanel(briefPanel)
    end

    local teamPanel = vgui.Create("DPanel", mSheet)
    teamPanel.Paint = function(self, w, h)
        surface.SetDrawColor(30, 73, 173, 10)
        surface.DrawRect(0, 0, w/2, h) --left screen and blue

        surface.SetDrawColor(206,67,61, 10) 
        surface.DrawRect(w/2, 0, w/2, h) -- right screen and red
    end
    mSheet:AddSheet("   Team Change   ", teamPanel, "icon16/group_go.png")
    GW3.teamPanelMenu(teamPanel) --Calling the panel code
end

-- İlk girişte zorunlu takım seçimi ekranı.
GW3 = GW3 or {}
GW3.ForcedTeamSelectionActive = false
GW3.TeamSelectionPending = false

function GW3.OpenForcedTeamSelection()
    if IsValid(GW3.ForcedTeamFrame) then
        GW3.ForcedTeamFrame:MakePopup()
        return
    end

    GW3.ForcedTeamSelectionActive = true
    GW3.TeamSelectionPending = false

    -- Zorunlu secim ekrani acilirken varsa normal F3 menusunu kapat.
    if IsValid(menu) then
        menu:Remove()
        menu = nil
    end

    -- DFrame kullanmiyoruz: DFrame'in titlebar/client-area inset'i tam ekran
    -- cizim alanini daraltiyor. Borderless DPanel gercek ekran boyutunda calisir.
    local frame = vgui.Create("DPanel")
    GW3.ForcedTeamFrame = frame
    frame:SetPos(0, 0)
    frame:SetSize(ScrW(), ScrH())
    frame:SetZPos(32767)
    frame:SetKeyboardInputEnabled(true)
    frame:SetMouseInputEnabled(true)
    frame:MakePopup()

    -- ESC veya Close cagrisi zorunlu secim ekranini kapatamasin.
    frame.Close = function() end
    frame.OnKeyCodePressed = function(self, keyCode)
        if keyCode == KEY_ESCAPE then return true end
    end

    frame.Paint = function(self, w, h)
        self.startTime = self.startTime or SysTime()
        Derma_DrawBackgroundBlur(self, self.startTime)
        surface.SetDrawColor(8, 10, 15, 245)
        surface.DrawRect(0, 0, w, h)
    end

    local teamPanel = vgui.Create("DPanel", frame)
    teamPanel:Dock(FILL)
    teamPanel:DockMargin(0, 0, 0, 0)
    teamPanel.Paint = function(self, w, h)
        surface.SetDrawColor(30, 73, 173, 10)
        surface.DrawRect(0, 0, w / 2, h)
        surface.SetDrawColor(206, 67, 61, 10)
        surface.DrawRect(w / 2, 0, w / 2, h)

        draw.SimpleTextOutlined(
            "CHOOSE YOUR SIDE",
            "MenuSelectHud3",
            w / 2,
            h * 0.12,
            Color(240, 240, 240),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            2,
            Color(0, 0, 0, 255)
        )
        draw.SimpleTextOutlined(
            "Select a faction to deploy",
            "MenuSelectHud2",
            w / 2,
            h * 0.16,
            Color(190, 190, 190),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            1,
            Color(0, 0, 0, 255)
        )
    end

    GW3.teamPanelMenu(teamPanel)
end

net.Receive("GW3_ForceTeamSelection", function()
    GW3.OpenForcedTeamSelection()
end)

net.Receive("GW3_TeamSelectionResult", function()
    local success = net.ReadBool()
    local message = net.ReadString()
    GW3.TeamSelectionPending = false

    if success then
        GW3.ForcedTeamSelectionActive = false
        if IsValid(GW3.ForcedTeamFrame) then
            GW3.ForcedTeamFrame:Remove()
        end
        GW3.ForcedTeamFrame = nil
    end
end)

--openning system of the menu, grabbed right from 2.3 
hook.Add("Think", "MenuKeyOpenner", function()
    if GW3.ForcedTeamSelectionActive then return end
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

hook.Add("OnScreenSizeChanged", "GW3_ResizeBriefingMenu", function()
    if IsValid(menu) then
        menu:SetPos(0, 0)
        menu:SetSize(ScrW(), ScrH())
    end
end)
