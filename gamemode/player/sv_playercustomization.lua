AddCSLuaFile("cl_playercustomization.lua")

hook.Add("SetupMove", "SetPlySpeed", function(ply, mv, cmd)
    if not ply:IsValid() then return end

    ply:SetCrouchedWalkSpeed(0.25)
    ply:SetDuckSpeed(0.20)
    ply:SetSlowWalkSpeed(40)
    ply:SetWalkSpeed(135)
    ply:SetRunSpeed(250)
end)

print("SERVER PLAYER")