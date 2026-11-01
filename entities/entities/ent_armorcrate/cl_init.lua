include("shared.lua")
include("globalwarfare3/gamemode/vgui/cl_logipanelarmor.lua")
include("globalwarfare3/gamemode/logihandler/cl_logihandler.lua")

function ENT:Draw()
    self:DrawModel()
end

-- this code makes you see the information in person
-- the logistic menu frame, the panel code located in cl_logipanel
function logisticMenuStartArmorUKR(targetEntity)

    logisticMenu = vgui.Create("DFrame")
    logisticMenu:SetPos(100, 100)
    logisticMenu:SetSize(ScrW(), ScrH())
    logisticMenu:SetTitle("")
    logisticMenu:Center()
    logisticMenu:MakePopup()
    logisticMenu:SetAlpha(0)
    logisticMenu:AlphaTo(255, 0.8, 0.2)
    logisticMenu:SetDraggable(false)
    
    logisticMenu.Paint = function(self, w, h)
        self.startTime = self.startTime or SysTime()
        Derma_DrawBackgroundBlur(self, self.startTime)
        surface.SetDrawColor(25, 25, 25, 210)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(45, 45, 45, 225)
        surface.DrawRect(0, 0, w, 30)
        draw.SimpleText("Ukranian Armor Box", "DermaDefaultBold", 12, 7, Color(220, 220, 220), TEXT_ALIGN_LEFT)
    end
                
    local lSheet = vgui.Create("DPropertySheet", logisticMenu)
    lSheet:Dock(FILL)

    lSheet.Paint = function(self, w, h)
        surface.SetDrawColor(125, 125, 125, 5) 
        surface.DrawRect(0, 20, w, h - 20)
    end
    -- tab colors , if active etc.  
    local oldAddSheet = lSheet.AddSheet
    function lSheet:AddSheet(label, panel, material, ...)
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

    local logiPanel = vgui.Create("DPanel", lSheet)
    logiPanel.Paint = function(self, w, h)
        surface.SetDrawColor(75, 30, 30, 10)
        surface.DrawRect(0, 0, w, h)    
    end

    lSheet:AddSheet("   Ukranian Armor Box   ", logiPanel, "icon16/report.png")
    logisticAmount = IsValid(targetEntity) and targetEntity:GetNWInt("armorUKRLogisticAmount", 0) or 0

    -- calling the panel code, i use this for no spagetti code
    GW3.logiPanelMenuArmorUKR(logiPanel, logiLocation, targetEntity, logisticAmount)
end

net.Receive("callClientArmorUKR", function()
    -- receiving entity id etc. and sending it to the func
    local targetEnt = net.ReadEntity()
    logisticMenuStartArmorUKR(targetEnt)
end)
net.Receive("armorUKRVector", function( len )
    -- receving the vector
    logiLocation = net.ReadVector()
end)
-- worst name ever
net.Receive("logisticSendNewAmountArmorUKR", function()
    -- reading the entity and the sended amount. then setting it.
    local targetEnt = net.ReadEntity()
    local amount = net.ReadInt(16)
    if IsValid(targetEnt) then
        -- placing the amount to the variable
        targetEnt.crateLogisticArmorUKR = amount
    end
end)