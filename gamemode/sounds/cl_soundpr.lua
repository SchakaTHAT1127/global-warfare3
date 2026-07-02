AddCSLuaFile("../shared.lua")
GW3 = GW3 or {} -- Gamemode ismine özel bir tablo oluştur

function GW3.uiSound(wanted) -- made this for easier ui sfx's
    local sounds = {
        ["button"] = "common/stuck1.wav",
        ["team"]   = "ui/team_join.wav",
        ["locked"]   = "entsound/lockedchain.wav",
        ["error"]  = "buttons/button10.wav"
    } -- may add more later didnt really put work on it

    local soundUsing = sounds[wanted]
    surface.PlaySound(soundUsing)

    -- Literally my first time using a lookup table... im shamed that i didnt use it before
end