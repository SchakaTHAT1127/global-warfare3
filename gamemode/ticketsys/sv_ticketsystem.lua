-- Global Warfare 3 - ticket system
-- Ticket scores are initialized by gamemode/init.lua after the ConVars are available.

local function HandleVehicleLoss(ent, list, teamID, teamVarName)
    if not IsValid(ent) or ent.TicketDeducted or not istable(list) then return end

    local entClass = ent:GetClass()
    for name, data in pairs(list) do
        if entClass == data.class then
            ent.TicketDeducted = true

            local currentTickets = tonumber(_G[teamVarName]) or 0
            local newTickets = math.max(0, currentTickets - (tonumber(data.ticket) or 0))
            _G[teamVarName] = newTickets
            team.SetScore(teamID, newTickets)

            print("[SISTEM] Arac imha edildi: " .. tostring(name))
            print("[SISTEM] Kalan bilet: " .. newTickets)
            hook.Run("AracPatladi", data.class, teamID)
            return
        end
    end
end

hook.Add("OnEntityCreated", "GW3_LVS_TicketMonitor", function(ent)
    timer.Simple(0.1, function()
        if not IsValid(ent) or not ent.LVS then return end

        local oldOnDestroyed = ent.OnDestroyed
        ent.OnDestroyed = function(self, ...)
            HandleVehicleLoss(self, entAraclarUkrayna, UKR, "UKRticket")
            HandleVehicleLoss(self, entAraclarRusya, RUS, "RUSticket")

            if isfunction(oldOnDestroyed) then
                return oldOnDestroyed(self, ...)
            end
        end
    end)
end)

hook.Add("EntityRemoved", "GW3_ManualVehicleRemoval", function(ent)
    if not ent or ent.TicketDeducted then return end
    HandleVehicleLoss(ent, entAraclarUkrayna, UKR, "UKRticket")
    HandleVehicleLoss(ent, entAraclarRusya, RUS, "RUSticket")
end)

local function HandlePlayerDeath(ply)
    if not IsValid(ply) then return end

    local victimTeam = ply:Team()
    local teamID, teamVarName

    if victimTeam == UKR then
        teamID, teamVarName = UKR, "UKRticket"
    elseif victimTeam == RUS then
        teamID, teamVarName = RUS, "RUSticket"
    else
        -- Spectators and unassigned players must not touch either team's tickets.
        return
    end

    local currentTickets = tonumber(_G[teamVarName]) or 0
    local newTickets = math.max(0, currentTickets - 2)
    _G[teamVarName] = newTickets
    team.SetScore(teamID, newTickets)

    print("[SISTEM] Oyuncu oldu. Kalan bilet: " .. newTickets)
end

hook.Add("PlayerDeath", "GW3_PlayerDeathTicketCost", function(victim)
    HandlePlayerDeath(victim)
end)
