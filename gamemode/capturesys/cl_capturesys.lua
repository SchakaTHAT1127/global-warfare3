print("cl capture sys")

local mat = CreateMaterial("CustomWireframeMat", "UnlitGeneric", {
    ["$basetexture"] = "vgui/white",
    ["$wireframe"]   = 1, 
    ["$vertexcolor"] = 1, 
    ["$vertexalpha"] = 1  
})

local Kureler = {
    ["TokiKure"]   = { pos = Vector(-200.405151, 3079.191406, 83.725899), radius = 1200, color = Color(255, 255, 255) },
    ["YorukKure"]  = { pos = Vector(2551.250000, -6756.968750, -550.031250), radius = 1200,  color = Color(255, 255, 255) },
    ["KasabaKure"] = { pos = Vector(11523.310547, 2078.165771, -159.64688),  radius = 2000,  color = Color(255, 255, 255) },
    ["RusKoy"] = { pos = Vector(-7807.058105, 10200.379883, -530.01007),  radius = 1000,  color = Color(255, 255, 255) }
}

-- Kürelerin görsel çizimi (Render)
hook.Add("PostDrawTranslucentRenderables", "VisualizeAllSpheres", function()
    render.SetMaterial(mat) 
    
    for _, kure in pairs(Kureler) do
        render.DrawSphere(kure.pos, -kure.radius, 8, 8, kure.color)
        render.DrawSphere(kure.pos, kure.radius, 8,8, kure.color)
    end
end)

-- Oyuncunun küre içinde olup olmadığının kontrolü (Think)
-- Saniyede onlarca kez ents.FindInSphere çalıştırmak yerine mesafe kontrolü (Distance) çok daha performanslıdır.

local nextCheck = 0
hook.Add("Think", "MyCoolThinkFunction", function()
    -- Performans için her tick yerine saniyede 4 kez (0.25 saniyede bir) kontrol yapalım
    if CurTime() < nextCheck then return end
    nextCheck = CurTime() + 0.25

    local ply = LocalPlayer()
    if not IsValid(ply) or ply:InVehicle() then return end

    local plyPos = ply:GetPos()

    for isim, kure in pairs(Kureler) do
        -- Oyuncu ile küre merkezi arasındaki mesafenin karesini kontrol eder (Performance-friendly)
        if plyPos:DistToSqr(kure.pos) <= (kure.radius * kure.radius) then
            print("Player found in: " .. isim)
            kure.color = team.GetColor(ply:Team())
        end
    end
end)