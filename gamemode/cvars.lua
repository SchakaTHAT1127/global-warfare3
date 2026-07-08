if CLIENT then return end

-- convarlar listesi - ukrayna
sv_ukrainetruckamount   = CreateConVar("sv_ukrainetruckamount", "2", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Ukraine Truck Amount")
sv_ukrainetruckcooldown = CreateConVar("sv_ukrainetruckcooldown", "180", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Ukraine Truck Cooldown")

sv_ukrainecaramount     = CreateConVar("sv_ukrainecaramount", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Ukraine Car Amount")
sv_ukrainecarcooldown   = CreateConVar("sv_ukrainecarcooldown", "120", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Ukraine Car Cooldown")

sv_ukraineapcamount     = CreateConVar("sv_ukraineapcamount", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Ukraine APC Amount")
sv_ukraineapccooldown   = CreateConVar("sv_ukraineapccooldown", "300", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Ukraine APC Cooldown")


-- Russya
sv_russiatruckamount    = CreateConVar("sv_russiatruckamount", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Russia Truck Amount")
sv_russiatruckcooldown  = CreateConVar("sv_russiatruckcooldown", "180", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Russia Truck Cooldown")

sv_russiacaramount      = CreateConVar("sv_russiacaramount", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Russia Car Amount")
sv_russiacarcooldown    = CreateConVar("sv_russiacarcooldown", "120", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Russia Car Cooldown")

sv_russiaapcamount      = CreateConVar("sv_russiaapcamount", "1", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Russia APC Amount")
sv_russiaapccooldown    = CreateConVar("sv_russiaapccooldown", "420", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Russia APC Cooldown")

-- ConVar'ları tanımlayalım (Eğer oyun modu veya başka bir yer önceden tanımlamadıysa)
local cvarA = CreateConVar("sv_gwar_mod_a", "0", FCVAR_ARCHIVE)
local cvarB = CreateConVar("sv_gwar_mod_b", "0", FCVAR_ARCHIVE)

-- Mod A değiştiğinde çalışacak kod
cvars.AddChangeCallback("sv_gwar_mod_a", function(convar_name, value_old, value_new)
    -- Eğer Mod A aktif edildiyse (1 yapıldıysa) ve Mod B de o an aktifse
    if tostring(value_new) == "1" and cvarB:GetBool() then
        RunConsoleCommand("sv_gwar_mod_b", "0") -- Mod B'yi kapat
        print("[Global Warfare 3] Mod A aktif edildi, Mod B deaktif duruma getirildi.")
    end
end, "GWar3_ModA_Callback")

-- Mod B değiştiğinde çalışacak kod
cvars.AddChangeCallback("sv_gwar_mod_b", function(convar_name, value_old, value_new)
    -- Eğer Mod B aktif edildiyse (1 yapıldıysa) ve Mod A de o an aktifse
    if tostring(value_new) == "1" and cvarA:GetBool() then
        RunConsoleCommand("sv_gwar_mod_a", "0") -- Mod A'yı kapat
        print("[Global Warfare 3] Mod B aktif edildi, Mod A deaktif duruma getirildi.")
    end
end, "GWar3_ModB_Callback")