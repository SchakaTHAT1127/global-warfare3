GW3 = GW3 or {}

function GW3.logiPanelMenuArmorRUS(parentPanel, entLocation, targetEntity, logiAmount)
    print("logiPanelMenuArmorRUS çağırıldı, ben cl_logipanel. aldığım miktar;" ..logiAmount)
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
    local buttonHeight = tall * 0.045

    --defaults
    local DynamicFont = "MenuSelectHud2"
    local DynamicLabelFont = "LabelHud1"
    local descTable = {
    ["zirh1"] = [[
    Cost: 20 6B13 vest
    A vest that gives balistic protection.
        ]],
    ["zirh2"] = [[
    Cost: 10 Lifchik vest
    A vest that is made for carrying ammo.
        ]],
    ["ssh"] = [[
    Cost: 10 sSH-68 Helmet
    A helmet with some shrapnel protection.
        ]],
    ["3000"] = [[
    Cost: 20 6B7-1M Helmet
    A balistic kevlar helmet.
        ]],
    ["helmetozel"] = [[
    Cost: 15 ZHS-1-2M
    A balistic helmet that can protect agaisnt small caliber.
        ]],
    ["sapka"] = [[
    Cost: 5 Camo Cap
    A camouflage cap.
        ]],
    ["sapka2"] = [[
    Cost: 5 Blue Beret
    A blue beret.
        ]],
    ["backpack"] = [[
    Cost: 10 VKBO Backpack
    A backpack.
        ]],
    ["bant"] = [[
    Cost: 5 Armband
    A colorable armband.
        ]],
    ["balaclava"] = [[
    Cost: 5 Balaclava
    A balaclava that hides your face.
        ]],
    ["halfmask"] = [[
    Cost: 5 Half Skull Mask
    A half skull mask that is very tuff.
        ]],
    ["hat"] = [[
    Cost: 5 Black Hat
    A black hat.
        ]],
    ["glassess"] = [[
    Cost: 5 Aviator Glasses
    Aviator glasses, they look tuff.
        ]],
    ["bandana"] = [[
    Cost: 5 Olive Head Bandana
    It is a olive head bandana.
        ]],
    ["bandana2"] = [[
    Cost: 5 Black Head Bandana
    It is a black head bandana.
        ]],
    ["tanker"] = [[
    Cost: 5 Tank Cap
    It is Korsar balistic vest, you can carry ammo too, and lightweight.
        ]],
    ["termal"] = [[
    Cost: 80 Thermal Googles
    It is modern thermal googles, dont waste supplys buying this.
        ]],
    ["30002"] = [[
    Cost: 80 Night Vision
    It is modern night vision googles, dont waste supplys buying this.
        ]],
    }
    -- changes the font by looking at the res v1
    local screenSettings = {
        { threshold = 2560, fonts = "MenuSelectHud3", labels = "LabelHud4", yamount = 144 },
        { threshold = 1920, fonts = "MenuSelectHud3", labels = "LabelHud3", yamount = 144 },
        { threshold = 1600, fonts = "MenuSelectHud2", labels = "LabelHud2", yamount = 144 },
        { threshold = 1440, fonts = "MenuSelectHud2", labels = "LabelHud1", yamount = 144 },
        { threshold = 1280, fonts = "MenuSelectHud2", labels = "LabelHud1S", yamount = 144 },
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

    -- this thing is really good, ill use it from now on
    -- the button color system
    local function PaintCustomButton(self, w, h, text)
        surface.SetDrawColor(8, 8, 8, 215)
        surface.DrawRect(0, 0, w, h)

        local borderColor = self:IsHovered() and Color(216,161,61) or Color(216,87,61, 115)
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
            local logisticAmount = targetEntity:GetNWInt("armorRUSLogisticAmount", 0)
            GW3.uiSound("button")
            net.Start("logisticSendNewAmountArmorRUS")
                net.WriteString(netString)
                net.WriteVector(entLocation)
                net.WriteEntity(targetEntity)
                net.WriteInt(logisticAmount, 9)
            net.SendToServer()
            print(logisticAmount)
            if logiAmount <= 0 then
                print("alo muhittin uzaylılar kacırdı diyorum")
            end
        end
        btn.Paint = function(self, w, h) PaintCustomButton(self, w, h, label) end
        return btn
    end

-- Diğer takımların bu kutuyu açmasını engelliyoruz
    if team ~= 2 then
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
    -----------------------------------------------------
    -- WEAPONS CATEGORY
    -----------------------------------------------------sss
    local DWeapons = vgui.Create( "DCollapsibleCategory", panel )
    DWeapons:SetLabel("") 
    DWeapons:SetPos(wide * 0.12, tall * 0.05)
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

        draw.SimpleTextOutlined("First Armor Set", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListWeapons = vgui.Create( "DListLayout", DWeapons ) 
    ListWeapons:Dock( FILL )
    ListWeapons:DockPadding( 10, 10, 10, 0 )
    DWeapons:SetContents( ListWeapons ) 

    AddLogiButton(ListWeapons, "6B5-16", "zirh1")
    AddLabel(ListWeapons, descTable["zirh1"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Lifchik", "zirh2")
    AddLabel(ListWeapons, descTable["zirh2"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "sSH-68", "ssh")
    AddLabel(ListWeapons, descTable["ssh"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Armband", "bant")
    AddLabel(ListWeapons, descTable["bant"], 50, 100, categoryWide,tall)

    AddLogiButton(ListWeapons, "Balaclava", "balaclava")
    AddLabel(ListWeapons, descTable["balaclava"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Black Hat", "hat")
    AddLabel(ListWeapons, descTable["hat"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Half Mask", "halfmask")
    AddLabel(ListWeapons, descTable["halfmask"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Thermal Googles", "termal")
    AddLabel(ListWeapons, descTable["termal"], 50, 100, categoryWide,tall)

    -----------------------------------------------------
    -- MISC VEHICLE CATEGORY
    -----------------------------------------------------
    local DAntiTank = vgui.Create( "DCollapsibleCategory", panel )
    DAntiTank:SetLabel("") 
    DAntiTank:SetPos(wide * 0.38 + categoryWide, tall*0.05)
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

        draw.SimpleTextOutlined("Second Armor Set", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListMisc = vgui.Create( "DListLayout", DAntiTank ) 
    ListMisc:Dock( FILL )
    ListMisc:DockPadding( 10, 10, 10, 0 )
    DAntiTank:SetContents( ListMisc )


    AddLogiButton(ListMisc, "6B7-1M", "3000")
    AddLabel(ListMisc, descTable["3000"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Night Vision", "30002")
    AddLabel(ListMisc, descTable["30002"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Army Cap", "sapka")
    AddLabel(ListMisc, descTable["sapka"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Blue Beret", "sapka2")
    AddLabel(ListMisc, descTable["sapka2"], 50, 100, categoryWide,tall)

    AddLogiButton(ListMisc, "Aviator Glasses", "glassess")
    AddLabel(ListMisc, descTable["glassess"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Olive Head Bandana", "bandana")
    AddLabel(ListMisc, descTable["bandana"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Black Head Bandana", "bandana2")
    AddLabel(ListMisc, descTable["bandana2"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Tank Cap", "tanker")
    AddLabel(ListMisc, descTable["tanker"], 50, 100, categoryWide,tall)

    -----------------------------------------------------
    local Seperator1 = vgui.Create( "DPanel", panel )
    Seperator1:SetPos(wide * 0.25 + categoryWide, tall * 0.02) -- Set the position of the panel
    Seperator1:SetSize( 10, tall ) -- Set the size of the panel
    Seperator1.Paint = function(self, w, h)
        surface.SetDrawColor(8, 8, 8, 115)
        surface.DrawRect(0, -20, w, h)
    end
    return panel
end