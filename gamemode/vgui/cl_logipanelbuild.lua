GW3 = GW3 or {}

function GW3.logiPanelMenuBuild(parentPanel, entLocation, targetEntity, logiAmount)
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
    local descTable = {
    ["dragonsteeth"] = [[
    Cost: 15 Dragon's Teeth
    A fortification designed to block vehicle movement.
        ]],
        ["hedgehog"] = [[
    Cost: 15 Czech Hedgehogs
    A obstacle effective at stopping vehicles.
        ]],
        ["wall"] = [[
    Cost: 15 Sandbags
    A standard sandbag wall.
        ]],
        ["tallwall"] = [[
    Cost: 20 Sandbags
    A tall sandbag wall.
        ]],
        ["corner"] = [[
    Cost: 20 Sandbags
    A cornered sandbag barrier.
        ]],
        ["tallcorner"] = [[
    Cost: 25 Sandbags
    A tall cornered sandbag barrier.
        ]],
        ["metalpanel"] = [[
    Cost: 25 Resources
    Just a tall metal panel about 8.2mm thick.
        ]],
    ["metalpanelkucuk"] = [[
    Cost: 15 Resources
    a metal panel about 8.2mm thick.
        ]],
    ["cabinet"] = [[
    Cost: 15 Resources
    A metal file cabinet.
        ]],
    ["cabinetbig"] = [[
    Cost: 20 Resources
    A large storage cabinet.
        ]],
    ["palet"] = [[
    Cost: 20 Resources
    A wooden pallet.
        ]],
    ["crate"] = [[
    Cost: 25 Resources
    A wooden crate.
        ]],
    ["cratebig"] = [[
    Cost: 25 Resources
    A large wooden crate.
        ]],
    ["metaldesk"] = [[
    Cost: 25 Resources
    A sturdy metal desk.
        ]],
    ["tirebig"] = [[
    Cost: 25 Resources
    A large vehicle tire.
        ]],
    ["tire"] = [[
    Cost: 25 Resources
    A standard rubber tire.
        ]],
    ["shelf"] = [[
    Cost: 25 Resources
    A wooden book shelf.
        ]],
    ["table"] = [[
    Cost: 25 Resources
    A small wooden table.
        ]],
    ["belediye"] = [[
    Cost: 25 Resources
    A wood barricade, with red and white paint.
        ]],
    ["radyator"] = [[
    Cost: 25 Resources
    A metal radiator, wont heat you.
        ]],
    ["dumpsterkapak"] = [[
    Cost: 25 Resources
    A heavy dumpster lid.
        ]],
    ["breendesk"] = [[
    Cost: 25 Resources
    A administrative desk stolen from the city hall.
        ]],
    ["tablebig"] = [[
    Cost: 25 Resources
    A cafeteria table, its wooden.
        ]],
    ["telkucuk"] = [[
    Cost: 25 Resources
    A small wire fence.
        ]],
    ["telbuyuk"] = [[
    Cost: 25 Resources
    A wire fence
        ]],
    ["pushcart"] = [[
    Cost: 25 Resources
    A wheeled cart.
    ]],
    ["woodfence"] = [[
    Cost: 25 Resources
    A wooden fence.
    ]]
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

        local borderColor = self:IsHovered() and Color(120,120,123) or Color(80,80,80, 115)
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
            local logisticAmount = targetEntity:GetNWInt("buildLogisticAmount", 0)
            GW3.uiSound("button")
            net.Start("logisticSendNewAmountBuild")
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
    DWeapons:SetPos(wide * 0.05, tall * 0.02)
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

        draw.SimpleTextOutlined("First Props", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListWeapons = vgui.Create( "DListLayout", DWeapons ) 
    ListWeapons:Dock( FILL )
    ListWeapons:DockPadding( 10, 10, 10, 0 )
    DWeapons:SetContents( ListWeapons ) 

    AddLogiButton(ListWeapons, "Tall Metal Panel", "metalpanel")
    AddLabel(ListWeapons, descTable["metalpanel"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Metal Panel", "metalpanelkucuk")
    AddLabel(ListWeapons, descTable["metalpanelkucuk"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "File Cabinet", "cabinet")
    AddLabel(ListWeapons, descTable["cabinet"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Storage Cabinet", "cabinetbig")
    AddLabel(ListWeapons, descTable["cabinetbig"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Metal Desk", "metaldesk")
    AddLabel(ListWeapons, descTable["metaldesk"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Truck Tire", "tirebig")
    AddLabel(ListWeapons, descTable["tirebig"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Car Tire", "tire")
    AddLabel(ListWeapons, descTable["tire"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Book Shelf", "shelf")
    AddLabel(ListWeapons, descTable["shelf"], 50, 100, categoryWide,tall)
    AddLogiButton(ListWeapons, "Small Table", "table")
    AddLabel(ListWeapons, descTable["table"], 50, 100, categoryWide,tall)

    -----------------------------------------------------
    -- MISC VEHICLE CATEGORY
    -----------------------------------------------------
    local DAntiTank = vgui.Create( "DCollapsibleCategory", panel )
    DAntiTank:SetLabel("") 
    DAntiTank:SetPos(wide * 0.45 + categoryWide, tall * 0.02)
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

        draw.SimpleTextOutlined("Second Props", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListMisc = vgui.Create( "DListLayout", DAntiTank ) 
    ListMisc:Dock( FILL )
    ListMisc:DockPadding( 10, 10, 10, 0 )
    DAntiTank:SetContents( ListMisc )


    AddLogiButton(ListMisc, "Barricade", "belediye")
    AddLabel(ListMisc, descTable["belediye"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Radiator", "radyator")
    AddLabel(ListMisc, descTable["radyator"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Dumpster Lid", "dumpsterkapak")
    AddLabel(ListMisc, descTable["dumpsterkapak"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Townhall Desk", "breendesk")
    AddLabel(ListMisc, descTable["breendesk"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Big Table", "tablebig")
    AddLabel(ListMisc, descTable["tablebig"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Small Fence", "telkucuk")
    AddLabel(ListMisc, descTable["telkucuk"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Fence", "telbuyuk")
    AddLabel(ListMisc, descTable["telbuyuk"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Pushcart", "pushcart")
    AddLabel(ListMisc, descTable["pushcart"], 50, 100, categoryWide,tall)
    AddLogiButton(ListMisc, "Wooden Fence", "woodfence")
    AddLabel(ListMisc, descTable["woodfence"], 50, 100, categoryWide,tall)
    -----------------------------------------------------
    -- HIGH EXPLOSİVE CATEGORY
    -----------------------------------------------------
    local DExplosive = vgui.Create( "DCollapsibleCategory", panel )
    DExplosive:SetLabel("") 
    DExplosive:SetPos(wide * 0.125 + categoryWide, tall * 0.02)
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

        draw.SimpleTextOutlined("Fortifications+", DynamicFont, w / 2, h / 2, Color(230, 230, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(5, 5, 5, 255))
    end

    local ListExplosive = vgui.Create( "DListLayout", DExplosive ) 
    ListExplosive:Dock( FILL )
    ListExplosive:DockPadding( 10, 10, 10, 0 )
    DExplosive:SetContents( ListExplosive )

    AddLogiButton(ListExplosive, "Dragons Teeth", "dragonsteeth")
    AddLabel(ListExplosive, descTable["dragonsteeth"], 50, 100, categoryWide,tall)
    AddLogiButton(ListExplosive, "Hedgehog", "hedgehog")
    AddLabel(ListExplosive, descTable["hedgehog"], 50, 100, categoryWide,tall)
    AddLogiButton(ListExplosive, "Sandbag Wall", "wall")
    AddLabel(ListExplosive, descTable["wall"], 50, 100, categoryWide,tall)
    AddLogiButton(ListExplosive, "Tall Sandbag Wall", "tallwall")
    AddLabel(ListExplosive, descTable["tallwall"], 50, 100, categoryWide,tall)
    AddLogiButton(ListExplosive, "Cornered Sandbag Wall", "corner")
    AddLabel(ListExplosive, descTable["corner"], 50, 100, categoryWide,tall)
    AddLogiButton(ListExplosive, "Cornered Tall Sandbag Wall", "tallcorner")
    AddLabel(ListExplosive, descTable["tallcorner"], 50, 100, categoryWide,tall)

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