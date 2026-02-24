include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

function progressFunc(targetEnt)
    if not IsValid(targetEnt) then return end -- Güvenlik kontrolü

    print("PF " .. tostring(targetEnt))
    local duration = 8
    local startTime = CurTime()
    local finishTime = startTime + duration

    local progressMenu = vgui.Create("DFrame")
    progressMenu:SetSize(400, 130)
    progressMenu:Center()
    progressMenu:SetTitle("") 
    progressMenu:MakePopup()
    progressMenu:ShowCloseButton(false)
    progressMenu:SetAlpha(0)
    progressMenu:AlphaTo(255, 0.5, 0)

    local DProgress = vgui.Create("DProgress", progressMenu)
    DProgress:SetPos(20, 60)
    DProgress:SetSize(360, 35)
    DProgress:SetFraction(0)
    progressMenu.ProgressBar = DProgress

    progressMenu.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(self, startTime)
        surface.SetDrawColor(8, 8, 8, 215)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(88, 102, 89, 115)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        draw.SimpleTextOutlined("Opening crate...", "DermaDefault", w / 2, 20, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    -- Tüm mantık tek bir Think içinde
    progressMenu.Think = function(self)
        -- İptal etme (Mouse basılırsa)
        if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
            self:Close()
            surface.PlaySound("buttons/button15.wav")
            return
        end

        local now = CurTime()
        local fraction = math.Clamp(1 - ((finishTime - now) / duration), 0, 1)
        
        if IsValid(self.ProgressBar) then
            self.ProgressBar:SetFraction(fraction)
        end

        -- Tamamlanma
        if now >= finishTime then
            if progressDone then progressDone(targetEnt) end
            self:Close()
            self.Think = nil
        end
    end

    DProgress.Paint = function(self, w, h)
        surface.SetDrawColor(5, 5, 5, 200)
        surface.DrawRect(0, 0, w, h)

        local fraction = self:GetFraction()
        local progressW = w * fraction
        
        if progressW > 0 then
            surface.SetDrawColor(88, 102, 89, 205)
            surface.DrawRect(0, 0, progressW, h)
        end
        surface.SetDrawColor(88, 102, 89, 150)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.SimpleTextOutlined(math.Round(fraction * 100) .. "%", "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 255))
    end
end

function progressDone(targetEnt)
    print("PD " .. tostring(targetEnt))
    net.Start("progressDone")
        net.WriteEntity(targetEnt)
    net.SendToServer()
end

-- this code makes you see the information in person
hook.Add("HUDPaint", "DrawCrateHint_2", function()
    for _, ent in ipairs(ents.FindByClass("ent_radcrate")) do
        if IsValid(ent) then
            local distance = LocalPlayer():GetPos():Distance(ent:GetPos())
            if distance < 350 then
                local worldPos = ent:GetPos() + Vector(0, 0, 10)
                local screenData = worldPos:ToScreen()
                if screenData.visible then
                    local x, y = screenData.x, screenData.y
                    draw.RoundedBox(4, x-170, y - 13, 340, 25, Color(0, 0, 0, 150))
                    draw.SimpleText("Open box to get radio equipment", "TargetID", x, y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Press Walk (ALT) + Use", "LabelHud1", x, y + 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end
    end
end)

net.Receive("alertClientAboutUse", function()
    print("i receiv")
    local targetEnt = net.ReadEntity()
    print(targetEnt)
    progressFunc(targetEnt)
end)