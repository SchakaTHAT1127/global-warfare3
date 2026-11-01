-- Global Warfare 3 - ticket system
-- Ticket scores are initialized by gamemode/init.lua after the ConVars are available.
local cooldown2 = 0
local cooldownTime2 = 1
local sopar = 20

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

end

hook.Add("PlayerDeath", "GW3_PlayerDeathTicketCost", function(victim)
    HandlePlayerDeath(victim)
end)

util.AddNetworkString("GW3_WinMenuStart")

local function getwinneri1()

    net.Start("GW3_WinMenuStart")
        net.WriteColor(Color(20,20,30,220))
        net.WriteString("Ukrainian Victory!")
        net.WriteString("telephone/ukrayna.mp3")
    net.Broadcast()
end

local function getwinneri2()

    net.Start("GW3_WinMenuStart")
        net.WriteColor(Color(30,20,20,220))
        net.WriteString("Russian Victory!")
        net.WriteString("telephone/rusya.mp3")
    net.Broadcast()
end

local nextCheck = 0
local MacBitti = false

local fonksiyonCalistir = {
    [1] = getwinneri2,
    [2] = getwinneri1
}

hook.Add("Think", "OyunBittiMi", function()
    if CurTime() < nextCheck or MacBitti then return end

    nextCheck = CurTime() + 1

    for i = 1, 2 do
        if team.GetScore(i) <= 0 then
            fonksiyonCalistir[i]()

            MacBitti = true
            break
        end
    end
end)

hook.Add("Think", "partsSERVER", function() 
    if MacBitti and CurTime() > cooldown2 and sopar > 0 then
        cooldown2 = CurTime() + cooldownTime2
        sopar = sopar - 1
    elseif sopar <= 0 then
        RunConsoleCommand("changelevel", game.GetMap())
    end
end)