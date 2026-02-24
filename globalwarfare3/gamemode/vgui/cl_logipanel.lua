GW3 = GW3 or {}

-- the panel code
function GW3.logiPanelMenu(parentPanel, entLocation, targetEntity, logiAmount)
    print("logiPanelMenu çağırıldı, ben cl_logipanel. aldığım miktar;" ..logiAmount)
    local ply = LocalPlayer()
    local team = ply:Team()

    local panel = parentPanel
    local wide = ScrW()
    local tall = ScrH()

    -- scaling factors etc.
    local categoryWide = wide * 0.25
    local categoryTall = tall * 0.45
    local labelWide = wide * 0.35
    local labelTall = tall * 0.45
    local buttonHeight = tall * 0.035

    --defaults
    local DynamicFont = "MenuSelectHud2"
    local DynamicLabelFont = "LabelHud1"

    -- The descriptions
local descTable = {
        ["assault"] = [[
Cost: 20, Infantry Rifles;
Standard issue automatic rifle for frontline combat operations.
        ]],
        ["machinegun"] = [[
Cost: 30, Automatic Weapons;
High-rate-of-fire weapons designed for suppression and sustained heavy fire.
        ]],
        ["sniper"] = [[
Cost: 25, Marksman Rifles;
High-caliber bolt-action rifles for long-range engagement.
        ]],
        ["antitank"] = [[
Cost: 40, Anti-Armor Weaponry;
Specialized launchers and projectiles designed to neutralize armored vehicles.
        ]],
        ["artillery1"] = [[
Cost: 50, Small Barrel Artillery;
Lightweight, mobile indirect fire support system for mid-range strikes.
        ]],
        ["misc"] = [[
Cost: 80, Placed Heavy Machinegun;
A placeble Heavy Machinegun that can penatrate armored vehicles.
        ]],
        ["ammo"] = [[
Cost: 60, Standard Ammunition;
Ammunition for weapons.
        ]],
        ["rocketammo"] = [[
Cost: 50, Explosive Projectiles;
Rockets for rocket launchers.
        ]],
        ["bandage"] = [[
Cost: 5, Field Dressing and Hemostatics;
Basic medical supplies used to stop bleeding and protect open wounds.
        ]],
        ["splint"] = [[
Cost: 5, Trauma and Fracture Support;
Medical devices used to immobilize fractured limbs during field extraction.
        ]],
        ["ointment"] = [[
Cost: 5, Topical Medical Treatments;
Antiseptic creams and ointments for treating burns and preventing infection.
        ]],
        ["surgerykit"] = [[
Cost: 10, Advanced Field Surgical Kit;
Professional tools for invasive procedures and shrapnel removal in the field.
        ]],
        ["grenade"] = [[
Cost: 15, Fragmentation and High Explosives;
Hand-thrown anti-personnel explosives for clearing rooms or trenches.
        ]],
        ["smoke"] = [[
Cost: 10, Visual Obscuration Devices;
Canisters designed to create smoke screens for concealment and signaling.
        ]],
        ["flash"] = [[
Cost: 10, Non-Lethal Stun Munitions;
Tactical devices used to temporarily disorient targets with light and sound.
        ]],
        ["satchel"] = [[
Cost: 80, Demolition Satchel Charges;
Portable heavy explosive packs used for destroying structures and obstacles.
        ]],
        ["c4"] = [[
Cost: 70, Plastic Explosive Compounds;
Stable, high-velocity explosives typically used with timers.
        ]],
        ["tnt"] = [[
Cost: 70, Standard Demolition Blocks;
Traditional explosive material used for sabotage, can explode in diffrent times..
        ]],
        ["radio"] = [[
Cost: 25, Tactical Communication Systems;
Long-range radio units for unit coordination and air support requests.
        ]]
    }
    -- changes the font by looking at the res v1
    local screenSettings = {
        { threshold = 2560, fonts = "MenuSelectHud3", labels = "LabelHud4" },
        { threshold = 1920, fonts = "MenuSelectHud3", labels = "LabelHud3" },
        { threshold = 1600, fonts = "MenuSelectHud2", labels = "LabelHud2" },
        { threshold = 1440, fonts = "MenuSelectHud2", labels = "LabelHud1" },
        { threshold = 1280, fonts = "MenuSelectHud2", labels = "LabelHud1S" },
        { threshold = 0,    fonts = "MenuSelectHud1", labels = "LabelHud1S" }
    }

    -- changes the font by looking at the res v2
    for _, setting in ipairs(screenSettings) do
        if wide >= setting.threshold then
            DynamicFont = setting.fonts
            DynamicLabelFont = setting.labels
            print("Applied settings for width: " .. wide .. " (Threshold: " .. setting.threshold .. ")")
            break 
        end
    end
-- other teams cannot open this crate.
    if team ~= 1 then
        GW3.uiSound("locked")
        local lbl = vgui.Create("DLabel", panel)
        lbl:SetPos(wide * 0.353, tall * 0.38)
        lbl:SetSize(labelWide, labelTall)
        lbl:SetText("You tried to open the crate but you couldnt open the lock... Probably its just enemy's crate")
        lbl:SetFont("MenuSelectHud3") -- 'setting.labels' yerine döngüde belirlediğimiz değişkeni kullandık
        lbl:SetWrap(true)
        lbl:SetAutoStretchVertical(true)
        lbl:SetContentAlignment(7)
    return end

    -- this thing is really good, ill use it from now on
    -- the button color system
    local function PaintCustomButton(self, w, h, text)
        surface.SetDrawColor(8, 8, 8, 215)
        surface.DrawRect(0, 0, w, h)

        local borderColor = self:IsHovered() and Color(50, 150, 255) or Color(30, 73, 173, 115)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.SimpleTextOutlined(
            text,
            DynamicFont,
            w / 2, h / 2,
            Color(230, 230, 230),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,
            1, Color(5, 5, 5, 255)
        )
    end

       -- label func very important like the button one
    local function AddLabel(list, txt, x, y, sizex, sizey)
        local lbl = vgui.Create("DLabel", list)
        lbl:SetPos(x, y)
        lbl:SetSize(sizex, sizey)
        lbl:SetText(txt)
        lbl:SetFont(DynamicLabelFont)
        lbl:SetWrap(true)
        lbl:SetAutoStretchVertical(true)
        lbl:SetContentAlignment(7)
    end

    -- helper to add buttons easily
    local function AddLogiButton(list, label, netString)
        local btn = vgui.Create("DButton", list)
        btn:SetText("")
        btn:SetTall(buttonHeight)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 5)
        btn.DoClick = function()
            local logisticAmount = targetEntity:GetNWInt("logisticAmountNato", 0)
            GW3.uiSound("button")
            net.Start("logisticSendNewAmountNato")
                net.WriteString(netString)
                net.WriteVector(entLocation)
                net.WriteEntity(targetEntity)
                net.WriteInt(logisticAmount, 9)
            net.SendToServer()
            print(logisticAmount)
            print("çağırdım")
            if logiAmount <= 0 then
                print("alo muhittin uzaylılar kacırdı diyorum")
            end
        end
        btn.Paint = function(self, w, h) PaintCustomButton(self, w, h, label) end
        return btn
    end


    -----------------------------------------------------
    -- WEAPONS CATEGORY
    -----------------------------------------------------
    local DWeapons = vgui.Create( "DCollapsibleCategory", panel )
    DWeapons:SetLabel("") 
    DWeapons:SetPos(wide * 0.05, tall * 0.05)
    DWeapons:SetSize(categoryWide, categoryTall)
    DWeapons:SetExpanded(false)

    DWeapons.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, 0, w, h)
    end
    
    DWeapons.Header:SetTall( buttonHeight )
    DWeapons.Header.Paint = function(self, w, h)
        surface.SetDrawColor(8, 24, 8, 215)
        surface.DrawRect(0, 0, w, h)

        local borderColor = self:IsHovered() and Color(10, 150, 23) or Color(10, 100, 10)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.SimpleTextOutlined("Weapons Box", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListWeapons = vgui.Create( "DListLayout", DWeapons ) 
    ListWeapons:Dock( FILL )
    ListWeapons:DockPadding( 10, 10, 10, 0 )
    DWeapons:SetContents( ListWeapons ) 

    AddLogiButton(ListWeapons, "Assault Rifle", "assault")
    AddLabel(ListWeapons, descTable["assault"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Sniper Rifle", "sniper")
    AddLabel(ListWeapons, descTable["sniper"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Machinegun", "machinegun")
    AddLabel(ListWeapons, descTable["machinegun"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Anti-Tank Rocket Launcher", "antitank")
    AddLabel(ListWeapons, descTable["antitank"], 50, 100, categoryWide,tall)

    -----------------------------------------------------
    -- AMMO CATEGORY
    -----------------------------------------------------
    local DAmmos = vgui.Create( "DCollapsibleCategory", panel )
    DAmmos:SetLabel("") 
    DAmmos:SetPos(wide * 0.125 + categoryWide, tall * 0.05)
    DAmmos:SetSize(categoryWide, categoryTall)
    DAmmos:SetExpanded(false)

    DAmmos.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, 0, w, h)
    end
    
    DAmmos.Header:SetTall( buttonHeight )
    DAmmos.Header.Paint = function(self, w, h)
        surface.SetDrawColor(8, 24, 8, 215)
        surface.DrawRect(0, 0, w, h)

        local borderColor = self:IsHovered() and Color(10, 150, 23) or Color(10, 100, 10)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.SimpleTextOutlined("Ammo Crate", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListAmmo = vgui.Create( "DListLayout", DAmmos ) 
    ListAmmo:Dock( FILL )
    ListAmmo:DockPadding( 10, 10, 10, 0 )
    DAmmos:SetContents( ListAmmo )

    AddLogiButton(ListAmmo, "Ammo Box", "ammo")
    AddLabel(ListAmmo, descTable["ammo"], 50, 100, categoryWide,tall)
    AddLogiButton(ListAmmo, "Munition Box", "rocketammo")
    AddLabel(ListAmmo, descTable["rocketammo"], 50, 100, categoryWide,tall)

    -----------------------------------------------------
    -- MISC VEHICLE CATEGORY
    -----------------------------------------------------
    local DAntiTank = vgui.Create( "DCollapsibleCategory", panel )
    DAntiTank:SetLabel("") 
    DAntiTank:SetPos(wide * 0.45 + categoryWide, tall * 0.05)
    DAntiTank:SetSize(categoryWide, categoryTall)
    DAntiTank:SetExpanded(false)

    DAntiTank.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, 0, w, h)
    end
    
    DAntiTank.Header:SetTall( buttonHeight )
    DAntiTank.Header.Paint = function(self, w, h)
        surface.SetDrawColor(8, 24, 8, 215)
        surface.DrawRect(0, 0, w, h)

        local borderColor = self:IsHovered() and Color(10, 150, 23) or Color(10, 100, 10)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.SimpleTextOutlined("Miscs Box", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListMisc = vgui.Create( "DListLayout", DAntiTank ) 
    ListMisc:Dock( FILL )
    ListMisc:DockPadding( 10, 10, 10, 0 )
    DAntiTank:SetContents( ListMisc )

    AddLogiButton(ListMisc, "Medium Barrel Artillery", "artillery1")
    AddLabel(ListMisc, descTable["artillery1"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Long-Barreled Artillery", "artillery2")
    AddLabel(ListMisc, descTable["misc"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Radio Kit Crate", "radio")
    AddLabel(ListMisc, descTable["radio"], 50, 100, categoryWide,tall)

    -----------------------------------------------------
    -- HANDHELD GRENADE CATEGORY
    -----------------------------------------------------
    local DGrenade = vgui.Create( "DCollapsibleCategory", panel )
    DGrenade:SetLabel("") 
    DGrenade:SetPos(wide * 0.45 + categoryWide, tall * 0.50)
    DGrenade:SetSize(categoryWide, categoryTall)
    DGrenade:SetExpanded(false)

    DGrenade.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, 0, w, h)
    end
    
    DGrenade.Header:SetTall( buttonHeight )
    DGrenade.Header.Paint = function(self, w, h)
        surface.SetDrawColor(8, 24, 8, 215)
        surface.DrawRect(0, 0, w, h)

        local borderColor = self:IsHovered() and Color(10, 150, 23) or Color(10, 100, 10)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.SimpleTextOutlined("Handheld Explosives Box", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListGrenade = vgui.Create( "DListLayout", DGrenade ) 
    ListGrenade:Dock( FILL )
    ListGrenade:DockPadding( 10, 10, 10, 0 )
    DGrenade:SetContents( ListGrenade )

    AddLogiButton(ListGrenade, "Hand Grenade", "grenade")
    AddLabel(ListGrenade, descTable["grenade"], 50, 100, categoryWide,tall)
    AddLogiButton(ListGrenade, "Smoke Grenade", "smoke")
    AddLabel(ListGrenade, descTable["smoke"], 50, 100, categoryWide,tall)
    AddLogiButton(ListGrenade, "Flash Grenade", "flash")
    AddLabel(ListGrenade, descTable["flash"], 50, 100, categoryWide,tall)

    -----------------------------------------------------
    -- MEDİCAL CATEGORY
    -----------------------------------------------------
    local DMedical = vgui.Create( "DCollapsibleCategory", panel )
    DMedical:SetLabel("") 
    DMedical:SetPos(wide * 0.125 + categoryWide, tall * 0.40)
    DMedical:SetSize(categoryWide, categoryTall)
    DMedical:SetExpanded(false)

    DMedical.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, 0, w, h)
    end
    
    DMedical.Header:SetTall( buttonHeight )
    DMedical.Header.Paint = function(self, w, h)
        surface.SetDrawColor(8, 24, 8, 215)
        surface.DrawRect(0, 0, w, h)

        local borderColor = self:IsHovered() and Color(10, 150, 23) or Color(10, 100, 10)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.SimpleTextOutlined("First Aid Box", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListGrenade = vgui.Create( "DListLayout", DMedical ) 
    ListGrenade:Dock( FILL )
    ListGrenade:DockPadding( 10, 10, 10, 0 )
    DMedical:SetContents( ListGrenade )

    AddLogiButton(ListGrenade, "Bandage", "bandage")
    AddLabel(ListGrenade, descTable["bandage"], 50, 100, categoryWide,tall)
    AddLogiButton(ListGrenade, "Splint", "splint")
    AddLabel(ListGrenade, descTable["splint"], 50, 100, categoryWide,tall)
    AddLogiButton(ListGrenade, "Burn Ointment", "ointment")
    AddLabel(ListGrenade, descTable["ointment"], 50, 100, categoryWide,tall)
    AddLogiButton(ListGrenade, "Surgery Kit", "surgerykit")
    AddLabel(ListGrenade, descTable["surgerykit"], 50, 100, categoryWide,tall)

    -----------------------------------------------------
    -- HIGH EXPLOSİVE CATEGORY
    -----------------------------------------------------
    local DExplosive = vgui.Create( "DCollapsibleCategory", panel )
    DExplosive:SetLabel("") 
    DExplosive:SetPos(wide * 0.05, tall * 0.50)
    DExplosive:SetSize(categoryWide, categoryTall)
    DExplosive:SetExpanded(false)

    DExplosive.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, 0, w, h)
    end
    
    DExplosive.Header:SetTall( buttonHeight )
    DExplosive.Header.Paint = function(self, w, h)
        surface.SetDrawColor(8, 24, 8, 215)
        surface.DrawRect(0, 0, w, h)

        local borderColor = self:IsHovered() and Color(10, 150, 23) or Color(10, 100, 10)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 2)

        draw.SimpleTextOutlined("Explosives Crate", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListExplosive = vgui.Create( "DListLayout", DExplosive ) 
    ListExplosive:Dock( FILL )
    ListExplosive:DockPadding( 10, 10, 10, 0 )
    DExplosive:SetContents( ListExplosive )

    AddLogiButton(ListExplosive, "Satchel Charge", "satchel")
    AddLabel(ListExplosive, descTable["satchel"], 50, 100, categoryWide,tall)
    AddLogiButton(ListExplosive, "C4", "c4")
    AddLabel(ListExplosive, descTable["c4"], 50, 100, categoryWide,tall)
    AddLogiButton(ListExplosive, "TNT", "tnt")
    AddLabel(ListExplosive, descTable["tnt"], 50, 100, categoryWide,tall)

    local Seperator1 = vgui.Create( "DPanel", panel )
    Seperator1:SetPos(wide * 0.413 + categoryWide, tall * 0.02) -- Set the position of the panel
    Seperator1:SetSize( 10, tall ) -- Set the size of the panel
    Seperator1.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, -20, w, h)
    end

    local Seperator2 = vgui.Create( "DPanel", panel )
    Seperator2:SetPos(wide * 0.088 + categoryWide, tall * 0.02) -- Set the position of the panel
    Seperator2:SetSize( 10, tall ) -- Set the size of the panel
    Seperator2.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, -20, w, h)
    end
    return panel
end