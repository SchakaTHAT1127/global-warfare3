util.AddNetworkString("SendTeam")
util.AddNetworkString("GW3_ForceTeamSelection")
util.AddNetworkString("GW3_TeamSelectionResult")

GW3 = GW3 or {}

local TakimModelleri = {
    [UKR] = "models/morpeh/ukraine_marine2010.mdl",
    [RUS] = "models/4ervo/ml_project/russian_soldier2012.mdl"
}

local function SendTeamSelectionResult(ply, success, message)
    if not IsValid(ply) then return end

    net.Start("GW3_TeamSelectionResult")
        net.WriteBool(success)
        net.WriteString(message or "")
    net.Send(ply)
end

local function IsInsideOwnStartingZone(ply)
    if not IsValid(ply) then return false end

    local teamID = ply:Team()
    local zones = GW3.TeamBarrierZones
    local zone = zones and zones[teamID]

    -- Bu kontrol yalnızca mevcut takımı UKR/RUS olan oyuncular için çağrılır.
    if not zone or not isvector(zone.pos) or not isnumber(zone.radius) then
        return false
    end

    return ply:GetPos():DistToSqr(zone.pos) <= zone.radius * zone.radius
end

-- Takım seçme / takım değiştirme isteği.
net.Receive("SendTeam", function(_, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local requestedTeam = net.ReadUInt(2)
    if requestedTeam ~= UKR and requestedTeam ~= RUS then
        SendTeamSelectionResult(ply, false, "Geçersiz takım seçimi.")
        return
    end

    local currentTeam = ply:Team()
    local alreadyHasTeam = currentTeam == UKR or currentTeam == RUS

    -- İlk kez takım seçen oyuncu her yerden seçim yapabilir.
    -- UKR/RUS oyuncusu ise yalnızca KENDİ başlangıç dairesinden takım değiştirebilir.
    if alreadyHasTeam and requestedTeam ~= currentTeam and not IsInsideOwnStartingZone(ply) then
        SendTeamSelectionResult(
            ply,
            false,
            "Takım değiştirmek için kendi başlangıç bölgenin içinde olmalısın."
        )
        return
    end

    if requestedTeam == currentTeam then
        ply.GW3HasSelectedTeam = true
        SendTeamSelectionResult(ply, true, "Zaten bu takımdasın.")
        return
    end

    local otherTeam = requestedTeam == UKR and RUS or UKR
    local requestedCount = team.NumPlayers(requestedTeam)
    local otherCount = team.NumPlayers(otherTeam)

    -- Mevcut takımdan ayrılan oyuncuyu sayımdan çıkar.
    if currentTeam == requestedTeam then
        requestedCount = requestedCount - 1
    elseif currentTeam == otherTeam then
        otherCount = otherCount - 1
    end

    local finalTeam = requestedTeam
    if requestedCount > otherCount then
        finalTeam = otherTeam
    end

    ply.GW3HasSelectedTeam = true
    ply:SetTeam(finalTeam)

    local model = TakimModelleri[finalTeam]

    -- Oyuncuyu yeni takımının spawn noktalarında yeniden doğur.
    if ply:Alive() then
        ply:KillSilent()
    end

    ply:Spawn()

    if model then
        timer.Simple(0, function()
            if IsValid(ply) and ply:Team() == finalTeam then
                ply:SetModel(model)
            end
        end)
    end

    local message
    if finalTeam ~= requestedTeam then
        message = "Takımlar dengelendiği için " .. team.GetName(finalTeam) .. " takımına aktarıldın."
    else
        message = team.GetName(finalTeam) .. " takımına katıldın."
    end

    ply:ChatPrint(message)
    SendTeamSelectionResult(ply, true, message)

    -- İlk seçim tamamlandı; zorunlu seçim ekranını tekrar gönderme döngüsünü durdur.
    local timerName = "GW3_ForceTeamSelection_" .. ply:UserID()
    if timer.Exists(timerName) then
        timer.Remove(timerName)
    end
end)

-- Takım modelini her doğuşta tek bir hook ile uygula.
-- Eski kodda her takım değişiminde yeni PlayerSpawn hook'u ekleniyordu;
-- bu da hook birikmesine ve eski takım modelinin sonradan uygulanmasına neden oluyordu.
hook.Add("PlayerSpawn", "GW3_ApplyTeamPlayerModel", function(ply)
    local teamID = ply:Team()
    local model = TakimModelleri[teamID]
    if not model then return end

    timer.Simple(0, function()
        if IsValid(ply) and ply:Team() == teamID then
            ply:SetModel(model)
        end
    end)
end)

-- İlk girişte oyuncuyu takım seçilene kadar kilitle ve seçim ekranını yeniden gönder.
hook.Add("PlayerInitialSpawn", "GW3_RequireInitialTeamSelection", function(ply)
    ply.GW3HasSelectedTeam = false
    ply:SetTeam(TEAM_UNASSIGNED)

    local timerName = "GW3_ForceTeamSelection_" .. ply:UserID()
    timer.Create(timerName, 3, 0, function()
        if not IsValid(ply) then
            timer.Remove(timerName)
            return
        end

        if ply.GW3HasSelectedTeam or ply:Team() == UKR or ply:Team() == RUS then
            ply.GW3HasSelectedTeam = true
            timer.Remove(timerName)
            return
        end

        net.Start("GW3_ForceTeamSelection")
        net.Send(ply)
    end)
end)

local function HasSelectedTeam(ply)
    if ply.GW3HasSelectedTeam then return true end

    -- Lua dosyası sunucu açıkken yenilenirse mevcut UKR/RUS oyuncularını kilitleme.
    local teamID = ply:Team()
    if teamID == UKR or teamID == RUS then
        ply.GW3HasSelectedTeam = true
        return true
    end

    return false
end

-- Zorunlu takım seçimi tamamlanana kadar oyuncu hareket edemez.
hook.Add("SetupMove", "GW3_LockUntilTeamSelected", function(ply, mv)
    if HasSelectedTeam(ply) then return end

    mv:SetOrigin(ply:GetPos())
    mv:SetVelocity(vector_origin)
end)

hook.Add("PlayerUse", "GW3_BlockUseUntilTeamSelected", function(ply)
    if not HasSelectedTeam(ply) then
        return false
    end
end)

hook.Add("PlayerDisconnected", "GW3_ClearTeamSelectionTimer", function(ply)
    local timerName = "GW3_ForceTeamSelection_" .. ply:UserID()
    if timer.Exists(timerName) then
        timer.Remove(timerName)
    end
end)
