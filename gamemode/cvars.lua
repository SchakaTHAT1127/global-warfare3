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

sv_russiaticket    = CreateConVar("sv_russiaticket", "100", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Russia Ticket Amount")
sv_ukraineticket    = CreateConVar("sv_ukraineticket", "100", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "Ukraine Ticket Amount")

sv_conquest = CreateConVar("sv_conquest", "1", FCVAR_ARCHIVE)
sv_resourcecontrol = CreateConVar("sv_resourcecontrol", "0", FCVAR_ARCHIVE)
sv_teamelimination = CreateConVar("sv_teamelimination", "0", FCVAR_ARCHIVE)

local function convarModDegisici()
    if sv_conquest:GetInt() == 1 then
        sv_resourcecontrol:SetInt(0)
        sv_teamelimination:SetInt(0)
    elseif sv_resourcecontrol:GetInt() == 1 then
        sv_conquest:SetInt(0)
        sv_teamelimination:SetInt(0)
    elseif sv_teamelimination:GetInt() == 1 then
        sv_conquest:SetInt(0)
        sv_resourcecontrol:SetInt(0)
    end
    print("convarModDegisici")
end
convarModDegisici()