AddCSLuaFile("globalwarfare3/gamemode/shared.lua")

team.SetScore(UKR, UKRticket)
team.SetScore(RUS, RUSticket)

local rusVehicleList = {
    ["kamyon"] = {class = "sw_ural4320", ticket = 10},
    ["arac"] = {class = "sw_gaz2330", ticket = 10},
    ["apc"] = {class = "sw_btr82", ticket = 30}
}

local ukrVehicleList = {
    ["kamyon"] = {class = "sw_gaz66", ticket = 10},
    ["arac"] = {class = "sw_uaz469", ticket = 10},
    ["apc"] = {class = "sw_btr60", ticket = 20}
}

--[[
Normally this part was expected to be work perfect, but i didnt add the possiblity of
lvs's wreck system. i didnt really know it much so just used some AI here
]]

local function HandleVehicleLoss(ent, list, teamID, teamVarName)
    if not IsValid(ent) or ent.TicketDeducted then return end
    
    local entClass = ent:GetClass()
    
    for name, data in pairs(list) do
        if entClass == data.class then
            ent.TicketDeducted = true
            
            local currentTickets = _G[teamVarName] or 0
            local newTickets = currentTickets - data.ticket
            
            _G[teamVarName] = newTickets
            team.SetScore(teamID, newTickets)
            
            print("[SİSTEM] Araç İmha Edildi: " .. name)
            print("[SİSTEM] Kalan Bilet: " .. newTickets)
            break
        end
    end
end

hook.Add("OnEntityCreated", "LVS_Ticket_Monitor", function(ent)
    timer.Simple(0.1, function()
        if not IsValid(ent) or not ent.LVS then return end

        local oldOnDestroyed = ent.OnDestroyed
        ent.OnDestroyed = function(self)
            print("LVS Aracı Patladı (OnDestroyed Tetiklendi)")
            HandleVehicleLoss(self, ukrVehicleList, UKR, "UKRticket")
            HandleVehicleLoss(self, rusVehicleList, RUS, "RUSticket")
            
            if oldOnDestroyed then oldOnDestroyed(self) end
        end
    end)
end)

hook.Add("EntityRemoved", "GlobalWarfare_ManualRemoval", function(ent)
    if ent.TicketDeducted then return end
    HandleVehicleLoss(ent, ukrVehicleList, UKR, "UKRticket")
    HandleVehicleLoss(ent, rusVehicleList, RUS, "RUSticket")
end)

local function HandlePlayerDeath(ply, teamID, teamVarName)
            
    local currentTickets = _G[teamVarName] or 0
    local newTickets = currentTickets - 2
            
    _G[teamVarName] = newTickets
    team.SetScore(teamID, newTickets)
            
    print("[SİSTEM] Kalan Bilet: " .. newTickets)
end

hook.Add("PlayerDeath", "OyuncuOlunceTicketEksilt", function( victim, inflictor, attacker )
    victimTeam = victim:Team()

    if victimTeam == 1 then
        teamTicket = "UKRticket"
    elseif victimTeam == 2 then
        teamTicket = "RUSticket"
    end

    HandlePlayerDeath(victim, victimTeam, teamTicket)
end)