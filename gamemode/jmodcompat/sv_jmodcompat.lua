-- JMod EZ Toolbox uyumlulugu
-- JMod'un EZprogressTask fonksiyonu bu hook'a salvage islemi ilerletilmeden
-- once gelir. Mesaj dondurmek gorevi iptal eder.

local GW3_NonSalvageableCrates = {
    ["ent_logicrate"] = true,
    ["ent_logicrate_ussr"] = true,
    ["ent_armorcrate"] = true,
    ["sw_btr60"] = true,
    ["sw_uaz469"] = true,
    ["sw_btr82"] = true,
    ["sw_ural4320_troop"] = true,
    ["sw_gaz66"] = true,
    ["sw_gaz2330"] = true,
    ["ent_armorcrate_ussr"] = true
}

hook.Add("JMod_EZprogressTask", "GW3_BlockCrateSalvage", function(ent, pos, deconstructor, task)
    -- Kutularin gevsetme (ALT + sag tik) islemine dokunma;
    -- yalnizca salvage/parcalama islemini engelle.
    if task ~= "salvage" then return end
    if not IsValid(ent) then return end

    local class = ent:GetClass()
    if not GW3_NonSalvageableCrates[class] then return end

    -- Onceki bir denemeden kalmis olasi ilerlemeyi de sifirla.
    if ent.SetNW2Float then
        ent:SetNW2Float("EZsalvageProgress", 0)
    end

    if IsValid(deconstructor) and deconstructor.SetTaskProgress then
        deconstructor:SetTaskProgress(0)
    end

    return "You cant do this."
end)
