AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("globalwarfare3/gamemode/vgui/cl_logipanelbuild.lua")

include("globalwarfare3/gamemode/logihandler/sv_logihandler.lua")
include("shared.lua")

util.AddNetworkString("callClientBuild")
util.AddNetworkString("buildVector")

-- Buildcrate spawn noktaları
local BUILDCRATE_SPAWN_POINTS = {
    ukr = Vector(13082.137695, -13277.175781, -25.96875),
    rus = Vector(-14322.014648, -2026.330566, -767.968750)
}

-- Spawn olduğu konuma en yakın üssü bulur.
local function GetNearestBuildCrateSpawnSide(spawnPos)
    if not isvector(spawnPos) then return nil end

    local ukrDistance = spawnPos:DistToSqr(
        BUILDCRATE_SPAWN_POINTS.ukr
    )

    local rusDistance = spawnPos:DistToSqr(
        BUILDCRATE_SPAWN_POINTS.rus
    )

    if ukrDistance <= rusDistance then
        return "ukr"
    end

    return "rus"
end

-- these are the props, when ent gets damaged a random prop will be selected from here
local randomProps = {
    "models/weapons/w_pist_glock18.mdl",
    "models/weapons/w_eq_eholster_elite.mdl",
    "models/props_junk/Shoe001a.mdl",
    "models/props_c17/tools_wrench01a.mdl",
    "models/props_lab/box01a.mdl",
    "models/props/cs_office/trash_can_p5.mdl",
    "models/Items/357ammo.mdl",
    "models/Items/BoxSRounds.mdl",
    "models/Items/item_item_crate_chunk05.mdl",
    "models/gibs/wood_gib01c.mdl",
    "models/gibs/wood_gib01e.mdl",
    "models/gibs/wood_gib01b.mdl",
    "models/Items/item_item_crate_chunk08.mdl",
    "models/gibs/furniture_gibs/furniture_chair01a_gib02.mdl"
}

-- same with top one, this time only sounds.
local randomSounds = {
    "physics/cardboard/cardboard_box_break1.wav",
    "physics/cardboard/cardboard_box_break2.wav",
    "physics/cardboard/cardboard_box_break3.wav",
    "physics/cardboard/cardboard_box_impact_bullet1.wav",
    "physics/cardboard/cardboard_box_impact_bullet2.wav",
    "physics/cardboard/cardboard_box_impact_bullet3.wav",
    "physics/cardboard/cardboard_box_impact_bullet4.wav",
    "physics/cardboard/cardboard_box_impact_bullet5.wav"
}

function ENT:Initialize()
    -- Kasanın ilk spawn olduğu konumu kaydet.
    self.GW3BuildCrateSpawnPos = self:GetPos()

    -- Lojistik miktarı
    self.crateLogisticBuild = 200
    self:SetNWInt("buildLogisticAmount", self.crateLogisticBuild)

    -- Sağlık
    self:SetMaxHealth(2000)
    self:SetHealth(2000)

    self:SetModel("models/props/de_dust/stoneblock01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetMass(200)
        phys:Wake()
        phys:EnableGravity(true)
    end

    self.cooldown = 0
    self.cooldownTime = 1.5

    -- Pozisyonu istemcilere gönder.
    timer.Simple(0.1, function()
        if IsValid(self) then
            local pos = self:GetPos()

            net.Start("buildVector")
                net.WriteVector(pos)
            net.Broadcast()
        end
    end)
end

-- Lojistik sıfırlandığında ve kasa kaldırıldığında çalışır.
function ENT:OnRemove()
    if not self.GW3BuildCrateDepleted then return end
    if self.GW3BuildCrateRespawnHookSent then return end

    self.GW3BuildCrateRespawnHookSent = true

    local spawnPos = self.GW3BuildCrateSpawnPos
    if not isvector(spawnPos) then return end

    local side = GetNearestBuildCrateSpawnSide(spawnPos)

    if side == "rus" then
        hook.Run(
            "logistikcrateBittiRUS",
            "ent_buildcrate"
        )
    elseif side == "ukr" then
        hook.Run(
            "logistikcrateBitti",
            "ent_buildcrate"
        )
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local curPos = self:GetPos()
    local distance = curPos:Distance(activator:GetPos())
    local maxDistance = 75

    if distance <= maxDistance then
        if CurTime() > self.cooldown then
            -- ALT (slowwalk) basılı olmalı.
            if activator:KeyDown(262144) then
                self.cooldown = CurTime() + self.cooldownTime

                if self.crateLogisticBuild > 0 then
                    net.Start("buildVector")
                        net.WriteVector(curPos)
                    net.Broadcast()

                    net.Start("callClientBuild")
                        net.WriteEntity(self)
                    net.Send(activator)

                    self:EmitSound("snd_jack_aidboxopen.ogg")
                else
                    self:EmitSound("buttons/combine_button_locked.wav")
                end
            end
        end
    end
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()

    self:SetHealth(math.max(0, self:Health() - damage))

    -- Hasar alınca rastgele prop oluştur.
    local prop = ents.Create("prop_physics")

    if IsValid(prop) then
        prop:SetModel(table.Random(randomProps))
        prop:SetPos(self:GetPos() + Vector(0, 0, 40))
        prop:SetAngles(AngleRand())
        prop:Spawn()
        prop:SetRenderMode(1)

        local alpha = 255
        local timerID1 = "FadeProp1_" .. prop:EntIndex()
        local timerID2 = "FadeProp2_" .. prop:EntIndex()

        timer.Create(timerID2, 1, 1, function()
            timer.Create(timerID1, 0.05, 26, function()
                if IsValid(prop) then
                    alpha = alpha - 15

                    if alpha < 0 then
                        alpha = 0
                    end

                    prop:SetColor(Color(255, 255, 255, alpha))

                    if alpha <= 0 then
                        prop:Remove()
                    end
                else
                    timer.Remove(timerID1)
                end
            end)
        end)
    end

    self:EmitSound(table.Random(randomSounds))

    -- Hasardan dolayı lojistik azalt.
    self.crateLogisticBuild = math.max(
        0,
        (tonumber(self.crateLogisticBuild) or 0) - damage / 10
    )

    self:SetNWInt(
        "buildLogisticAmount",
        math.Round(self.crateLogisticBuild)
    )

    -- Lojistik sıfırlandıysa kaldırılma sebebini kaydet.
    if self.crateLogisticBuild <= 0 then
        self.GW3BuildCrateDepleted = true
    end

    if self:Health() <= 0 or self.crateLogisticBuild <= 0 then
        self:Remove()
    end
end

function ENT:SetbuildLogisticAmount(amount)
    amount = tonumber(amount) or 0

    self.crateLogisticBuild = math.max(0, amount)

    self:SetNWInt(
        "buildLogisticAmount",
        math.Round(self.crateLogisticBuild)
    )

    print(
        self:GetClass()
        .. " yeni lojistik amountı: "
        .. self.crateLogisticBuild
    )

    if self.crateLogisticBuild <= 0 then
        self.GW3BuildCrateDepleted = true
        self:Remove()
    end
end