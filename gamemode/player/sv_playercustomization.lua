AddCSLuaFile("cl_playercustomization.lua")
util.AddNetworkString("testmasaj")
util.AddNetworkString("feneri_Kapat")

hook.Add("SetupMove", "SetPlySpeed", function(ply, mv, cmd)
    if not ply:IsValid() then return end

    ply:SetCrouchedWalkSpeed(0.45)
    ply:SetDuckSpeed(0.60)
    ply:SetSlowWalkSpeed(70)
    ply:SetWalkSpeed(165)
    ply:SetRunSpeed(270)
    ply:SetUnDuckSpeed(0.60)
    --print( ply:GetEyeTrace().Entity )
end)

-- Oyuncu sunucuya ilk girdiğinde fener kapalı başlasın
hook.Add("PlayerInitialSpawn", "FenerSifirla_Giris", function(ply)
    ply:AllowFlashlight(false)
end)

-- Oyuncu her silah değiştirdiğinde kontrol et
hook.Add("PlayerSwitchWeapon", "FenerSilahKontrol", function(ply, oldWep, newWep)
    if IsValid(newWep) and newWep:GetClass() == "wep_gmod_tilifon" then
        ply:AllowFlashlight(true)
    else
        if ply:FlashlightIsOn() then
            ply:Flashlight(false)
        end
        ply:AllowFlashlight(false)
    end
end)