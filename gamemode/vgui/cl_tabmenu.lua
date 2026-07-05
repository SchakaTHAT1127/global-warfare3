AddCSLuaFile("../shared.lua")

-- Scoreboard'u başlatan ana fonksiyon
local function InitializeScoreboard()
    print("LocalPlayer geçerli! Scoreboard yükleniyor...")
    
    local myScoreboard = nil
    local natoBoards = nil
    local teamTwoBoard = nil 

    local sw, sh = ScrW(), ScrH()
    local w, h = sw * 0.15, sh * 0.4 

    -- Oyuncu satırı oluşturma (Helper)
    local function CreatePlayerRow(parent, ply)
        if not IsValid(ply) then return end
         
        local pnl = parent:Add("DPanel")
        pnl:Dock(TOP)
        pnl:SetHeight(30)
        pnl:DockMargin(5, 2, 5, 2)
        
        pnl.Paint = function(self, w, h)
            if not IsValid(ply) then return end
            local col = team.GetColor(ply:Team())
            draw.RoundedBox(4, 0, 0, w, h, Color(col.r, col.g, col.b, 30))
            draw.RoundedBox(0, 0, 0, 3, h, col) 
        end

        local avatar = vgui.Create("AvatarImage", pnl)
        avatar:SetSize(24, 24)
        avatar:SetPos(5, 3)
        avatar:SetPlayer(ply, 32)

        local name = vgui.Create("DLabel", pnl)
        name:SetText(ply:Nick())
        name:SetPos(35, 5)
        name:SetFont("DermaDefaultBold")
        name:SetSize(120, 20)
        name:SetTextColor(color_white)

        local ping = vgui.Create("DLabel", pnl)
        ping:Dock(RIGHT)
        ping:DockMargin(0, 0, -20, 0)
        ping:SetTextColor(Color(200, 200, 200))
        ping.Think = function(s) 
            if IsValid(ply) then s:SetText(ply:Ping()) end 
        end
    end

    -- Menüyü yenileyen ana fonksiyon
    local function RefreshScoreboard()
        if not IsValid(myScoreboard) or not IsValid(natoBoards) or not IsValid(teamTwoBoard) then return end
        
        myScoreboard.Scroll:Clear()
        natoBoards.Scroll:Clear()
        teamTwoBoard.Scroll:Clear()

        local allPlayers = player.GetAll()

        for _, ply in ipairs(allPlayers) do
            local tID = ply:Team()

            if tID == 1 then
                CreatePlayerRow(natoBoards.Scroll, ply)
            elseif tID == 2 then
                CreatePlayerRow(teamTwoBoard.Scroll, ply)
            else
                CreatePlayerRow(myScoreboard.Scroll, ply)
            end
        end
    end

    -- Panel Oluşturma Fonksiyonu
    local function CreateBaseFrame(title, xPos, teamScoreNumb)
        local frame = vgui.Create("DFrame")
        frame:SetSize(w, h * 0.6)
        frame:SetPos(xPos, sh * 0.04)
        frame:SetTitle("")
        frame:ShowCloseButton(false)
        frame:SetDraggable(false)
        frame:SetVisible(false)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, Color(25, 25, 25, 220))
            draw.SimpleText(title, "DermaDefaultBold", w / 2, 15, color_white, TEXT_ALIGN_CENTER)
            
            local currentTicket = team.GetScore(teamScoreNumb)
            draw.SimpleText("Ticket: " .. currentTicket, "DermaDefaultBold", w / 2, 35, color_white, TEXT_ALIGN_CENTER)
        end

        frame.Scroll = vgui.Create("DScrollPanel", frame)
        frame.Scroll:Dock(FILL) 
        frame.Scroll:DockMargin(5, 30, 5, 10)
        
        return frame
    end

    -- Hooklar
    hook.Add("ScoreboardShow", "CustomScoreboard_Open", function()
        local spacing = 20
        local totalW = (w * 3) + (spacing * 2)
        local startX = (sw - totalW) / 2

        if not IsValid(natoBoards) then natoBoards = CreateBaseFrame("Ukraine Statistics", startX, 1) end
        if not IsValid(myScoreboard) then myScoreboard = CreateBaseFrame("Other(s)", startX + w + spacing, 1001) end
        if not IsValid(teamTwoBoard) then teamTwoBoard = CreateBaseFrame("Russia Statistics", startX + (w + spacing) * 2, 2) end
        
        RefreshScoreboard()
        
        natoBoards:SetVisible(true)
        myScoreboard:SetVisible(true)
        teamTwoBoard:SetVisible(true)
        
        gui.EnableScreenClicker(true)
        return true
    end)

    hook.Add("ScoreboardHide", "CustomScoreboard_Close", function()
        if IsValid(myScoreboard) then myScoreboard:SetVisible(false) end
        if IsValid(natoBoards) then natoBoards:SetVisible(false) end
        if IsValid(teamTwoBoard) then teamTwoBoard:SetVisible(false) end
        
        gui.EnableScreenClicker(false)
        return true
    end)
end

-- Giriş kontrolü yapan döngü mekanizması
hook.Add("InitPostEntity", "some_unique_name", function()
    -- Eğer şansımıza oyuncu direkt geçerliyse döngüye girmeden başlat
    if IsValid(LocalPlayer()) then
        InitializeScoreboard()
    else
        -- Oyuncu geçerli olana kadar her 0.2 saniyede bir kontrol et (Sonsuz döngü korumalı)
        timer.Create("Scoreboard_PlayerCheck_Timer", 0.2, 0, function()
            if IsValid(LocalPlayer()) then
                
                timer.Remove("Scoreboard_PlayerCheck_Timer") -- Bulduğumuz an timer'ı temizle
                timer.Simple(1, function()
                    InitializeScoreboard()
                end)
            end
        end)
    end
end)

timer.Create("test12", 0.5, 0, function()
    print(team.GetScore(1))
    print(team.GetScore(2))
end)