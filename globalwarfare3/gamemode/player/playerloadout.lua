hook.Add("SetupMove", "HizAyarla", function(ply, mv, cmd)
    if not ply:IsValid() then return end

    ply:SetCrouchedWalkSpeed(0.25)
    ply:SetDuckSpeed(0.25)
    ply:SetSlowWalkSpeed(90)
    ply:SetWalkSpeed(145)
    ply:SetRunSpeed(290)
end)

-- idk why this part exists prob from old code may update later for loadout systems