AddCSLuaFile("../shared.lua")

local tus = KEY_F3  --key
local tusBasildi = false -- is the key pressed
local Menu = nil
local soguma = 0  -- last press time
local sogumaSuresi = 0.2 -- time to pass
function menuBaslat()
    local ply = LocalPlayer()

    Menu = vgui.Create("DFrame")
    Menu:SetPos(100, 100)
    Menu:SetSize(1366, 768)
    Menu:SetTitle("")
    Menu:Center()
    Menu:MakePopup()
    Menu:SetAlpha(0)
    Menu:AlphaTo(255, 0.8, 0.2)
    -- FRAME
    Menu.Paint = function(self, w, h)
        self.startTime = self.startTime or SysTime()
        -- draw blur
        Derma_DrawBackgroundBlur(self, self.startTime)
        --Derma_DrawBackgroundBlur(self, self.startTime)
        -- background
        surface.SetDrawColor(25, 25, 25, 210)
        surface.DrawRect(0, 0, w, h)
        -- top bar
        surface.SetDrawColor(45, 45, 45, 225)
        surface.DrawRect(0, 0, w, 30)
        draw.SimpleText("Operations Panel", "DermaDefaultBold", 12, 7, Color(220, 220, 220), TEXT_ALIGN_LEFT)
    end
    -- PROPERTY SHEET
    local Sayfa = vgui.Create("DPropertySheet", Menu)
    Sayfa:Dock(FILL)

    Sayfa.Paint = function(self, w, h)
        surface.SetDrawColor(125, 125, 125, 5) -- sheet arka plan
        surface.DrawRect(0, 20, w, h - 20)    -- tab butonlarını boyamasın diye 20px üstten boş
    end
    
    local oldAddSheet = Sayfa.AddSheet
    function Sayfa:AddSheet(label, panel, material, ...)
        local sheet = oldAddSheet(self, label, panel, material, ...)
        local tab = sheet.Tab
        tab.Paint = function(btn, w, h)
            if self:GetActiveTab() == btn then
                surface.SetDrawColor(70, 120, 200, 155) -- aktif tab (mavi ton)
            else
                surface.SetDrawColor(60, 60, 60, 100) -- pasif tab (gri)
            end
            surface.DrawRect(0, 0, w, h)
        end
        return sheet
    end

    local panel1 = vgui.Create("DPanel", Sayfa)
    panel1.Paint = function(self, w, h)
        surface.SetDrawColor(75, 30, 30, 10)
        surface.DrawRect(0, 0, w, h)    
    end
    local panel2 = vgui.Create("DPanel", Sayfa)
    panel2.Paint = function(self, w, h)
        surface.SetDrawColor(10, 130, 190, 10)
        surface.DrawRect(0, 0, w, h)
    end
    local panel3 = vgui.Create("DPanel", Sayfa)
    panel3.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h)
    end
    local panel4 = vgui.Create("DPanel", Sayfa)
    panel4.Paint = function(self, w, h)
        surface.SetDrawColor(66, 126, 245, 10)
        surface.DrawRect(0, 0, w/2, h) --left screen and blue

        surface.SetDrawColor(171, 52, 22, 10) 
        surface.DrawRect(w/2, 0, w/2, h) -- right screen and red
        print(w.." "..h)
    end


    local DermaButton = vgui.Create( "DButton", panel4 )
    DermaButton:SetText( "" ) 
    DermaButton:SetPos( 135, 425 )
    DermaButton:SetSize( 340, 30 ) 
    DermaButton.DoClick = function()
        net.Start( "SendTeam" )
            net.WriteUInt(1,2) -- This is NATO
        net.SendToServer()
    end
    DermaButton.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 215)
        surface.DrawRect(0, 0, w, h)  -- arka plan
        surface.SetDrawColor(30, 73, 173, 115)
        surface.DrawRect(2, 2.4, w-5, h-5)  -- ikinci katman / overlay gibi
        draw.SimpleTextOutlined(
            "North Atlantic Treaty Forces",                -- text
            "MenuSelectHud2",        -- font
            45, 3,                     -- x, y
            Color(230, 230, 230),      -- text color
            TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, -- alignment
            1,                         -- outline size
            Color(5, 5, 5, 255)    -- outline color
        )
    end

    local DermaButton = vgui.Create( "DButton", panel4 ) -- Create the button and parent it to the frame
    DermaButton:SetText("" )                 -- Set the text on the button
    DermaButton:SetPos(860, 425 )                    -- Set the position on the frame
    DermaButton:SetSize( 340, 30 )                  -- Set the size
    DermaButton.DoClick = function()                -- A custom function run when clicked ( note the . instead of : )
        net.Start( "SendTeam" )
            net.WriteUInt(2,2) -- This is soviet
        net.SendToServer()
    end
    DermaButton.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 225)
        surface.DrawRect(0, 0, w, h)  -- arka plan
        surface.SetDrawColor(243, 28, 28, 115)
        surface.DrawRect(2, 2.4, w-5, h-5) -- ikinci katman / overlay gibi
        draw.SimpleTextOutlined(
            "Soviet Ground Forces",                -- text
            "MenuSelectHud",        -- font
            75, 3,                     -- x, y
            Color(230, 230, 230),      -- text color
            TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, -- alignment
            1,                         -- outline size
            Color(5, 5, 5, 255)    -- outline color
        )
    end

    local soviet = vgui.Create("DImage", panel4)
    soviet:SetPos(860,170)
    soviet:SetSize(340, 240)

    wideVignet = panel4:GetWide()
    tallVignet = panel4:GetTall()

    local vignet = vgui.Create("DImage", panel4)
    vignet:Center()
    vignet:SetSize(1340, 698) 

    local vigmid = vgui.Create("DImage", panel4)  -- Add image to Frame
    vigmid:SetPos(570, 0)
    vigmid:SetSize(200, 698) 

    local nato = vgui.Create("DImage", panel4)
    nato:SetPos(135, 170)
    nato:SetSize(340, 240) 
-- these are the images right here
    soviet:SetImage("gamemodes/globalwarfare3/gamemode/content/materials/soviet.png")
    nato:SetImage("gamemodes/globalwarfare3/gamemode/content/materials/nato.png")
    --vignet and vigmid is just vignette efects
    vignet:SetImage("gamemodes/globalwarfare3/gamemode/content/materials/vignet.png")
    vigmid:SetImage("gamemodes/globalwarfare3/gamemode/content/materials/lalali.png")

--[[
this part is outdated, its from 2.4 
(not 2.3, from 2.4 i was working on it but scrapped cuz i didnt think it was really good)

]]

    Sayfa:AddSheet("   Mission Briefing   ", panel1, "icon16/report.png")
    Sayfa:AddSheet("   Loadout   ", panel2, "icon16/briefcase.png")
    Sayfa:AddSheet("   Vehicle Bay   ", panel3, "icon16/lorry.png")
    Sayfa:AddSheet("   Team Change   ", panel4, "icon16/group_go.png")
end

--openning system of the menu, grabbed right from 2.3 
hook.Add("Think", "TusaGoreMenuAc", function()
    if input.IsKeyDown(tus) then
        if not tusBasildi and CurTime() > soguma then  -- BURASI EKLENDİ
            tusBasildi = true
            soguma = CurTime() + sogumaSuresi  -- tekrar basma zamanı güncelleniyor

            if not IsValid(Menu) then
                menuBaslat()
            else
                Menu:Close()
                Menu = nil
            end
        end
    else
        tusBasildi = false
    end
end)