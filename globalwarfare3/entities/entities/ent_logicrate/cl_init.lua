include("shared.lua")
include("globalwarfare3/gamemode/vgui/cl_logipanel.lua")
include("globalwarfare3/gamemode/logihandler/cl_logihandler.lua")

-- cl_init.lua içine yazılacak
function ENT:Draw()
    self:DrawModel() -- Entity'nin kendisini (sandığı) çizmesi için şart
end

hook.Add("HUDPaint", "DrawCrateHint_", function()
    for _, ent in ipairs(ents.FindByClass("ent_logicrate")) do
        if IsValid(ent) then
            local distance = LocalPlayer():GetPos():Distance(ent:GetPos())
            if distance < 300 then
                -- Sandığın üzerindeki özel değeri oku
                local ammount = ent:GetNWInt("LogiAmount", 0) 
                
                local worldPos = ent:GetPos() + Vector(0, 0, 25)
                local screenData = worldPos:ToScreen()
                if screenData.visible then
                    local x, y = screenData.x, screenData.y
                    draw.RoundedBox(4, x-120, y - 13, 240, 25, Color(0, 0, 0, 150))
                    draw.SimpleText("NATO LOGISTIC CRATE", "TargetID", x, y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(4, x-90, y+23, 180, 25, Color(0, 33, 203, 90))
                    draw.SimpleText("Amount: " .. ammount, "TargetID", x, y + 36, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    end
end)
function logisticMenuStart(targetEntity)
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
                        -- background
        surface.SetDrawColor(25, 25, 25, 210)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(45, 45, 45, 225)
        surface.DrawRect(0, 0, w, 30)
        draw.SimpleText("Logistic Menu", "DermaDefaultBold", 12, 7, Color(220, 220, 220), TEXT_ALIGN_LEFT)
    end
                
    local lSheet = vgui.Create("DPropertySheet", logisticMenu)
    lSheet:Dock(FILL)

    lSheet.Paint = function(self, w, h)
        surface.SetDrawColor(125, 125, 125, 5) 
        surface.DrawRect(0, 20, w, h - 20)
    end
                
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

    lSheet:AddSheet("   Logistic Crate   ", logiPanel, "icon16/report.png")
    GW3.logiPanelMenu(logiPanel, logiLocation, targetEntity) --Calling the panel code
    print(logiLocation)
end

net.Receive("alertPlayer", function()
    local targetEnt = net.ReadEntity() -- Hangi sandık olduğunu al
    logisticMenuStart(targetEnt) -- Menü fonksiyonuna bu sandığı pasla
end)

net.Receive( "vectorOfSelf", function( len )
    logiLocation = net.ReadVector()
    print(logiLocation)
end)

net.Receive("logiSend", function()
    local targetEnt = net.ReadEntity()
    local amount = net.ReadInt(16)
    
    if IsValid(targetEnt) then
        targetEnt.logisticAmount = amount -- Değeri entity'nin içine kaydet
    end
end)