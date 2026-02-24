AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("alertClientAboutUse")
util.AddNetworkString("progressDone")

function ENT:Initialize()
    self:SetModel("models/items/item_beacon_crate.mdl")
    self:PhysicsInit(SOLID_VPHYSICS) 
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject() 
    if phys:IsValid() then
        phys:SetMass(60)
        phys:Wake()
        phys:EnableGravity(true)
    end

    self:SetMaxHealth(300)
    self:SetHealth(300)

    self.cooldown = 0
    -- cooldown, you can change it like you want if you want the player to open slower or quicker
    self.cooldownTime = 1.5
end

function ENT:Use(activator, caller)
    if CurTime() > self.cooldown then
	    if activator:KeyDown(262144) then
	        self.cooldown = CurTime() + self.cooldownTime
	        net.Start("alertClientAboutUse")
                net.WriteEntity(self)
		    net.Send(activator)
			self:EmitSound("snd_jack_aidboxopen.ogg")
	    end
	end
end

local randomProps = {
    "models/Items/item_item_crate_chunk05.mdl",
    "models/gibs/wood_gib01c.mdl",
    "models/gibs/wood_gib01e.mdl",
    "models/gibs/wood_gib01b.mdl",
    "models/Items/item_item_crate_chunk08.mdl"
}

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

function ENT:OnTakeDamage( dmginfo )
    local damage = dmginfo:GetDamage()
    self:SetHealth(self:Health() - damage)

    local prop = ents.Create("prop_physics")
    if not IsValid(prop) then return end

    local randomModel = table.Random(randomProps)
    prop:SetModel(randomModel)
    prop:SetPos(self:GetPos() + Vector(0, 0, 40))
    prop:SetAngles(AngleRand())
    prop:Spawn()
    prop:SetRenderMode( 1 )
    local randomSound = table.Random(randomSounds)
    self:EmitSound(randomSound)
        
    local alpha = 255
    local timerID1 = "FadeProp1_" .. prop:EntIndex()
    local timerID2 = "FadeProp2_" .. prop:EntIndex()

    timer.Create(timerID2, 1, 1, function() 
        timer.Create(timerID1, 0.05, 26, function() 
            if IsValid(prop) then
                alpha = alpha - 15
                if alpha < 0 then alpha = 0 end
                
                prop:SetColor(Color(255, 255, 255, alpha))
                
                if alpha <= 0 then
                    prop:Remove()
                end
            else
                timer.Remove(timerID1)
            end
        end)
    end)

    if self:Health() <= 0 then
        self:Remove()
        createRadios(self)
    end
end

function createRadios(targetEnt)

    local currentPos = targetEnt:GetPos()

    local equipment = {
        "sent_djaddon_mic_alt",
        "sent_djaddon_transmitter",
        "sent_djaddon_radio"
    }

    for _, class in ipairs(equipment) do
        local ent = ents.Create(class)
        if IsValid(ent) then
            ent:SetPos(currentPos + Vector(0, 0, 10)) -- Adjusted height so they don't fly away
            ent:Spawn()
            ent:Activate()
        end
    end
    targetEnt:Remove()
    targetEnt:EmitSound("physics/cardboard/cardboard_box_break2.wav")
    targetEnt:EmitSound("physics/cardboard/cardboard_box_break3.wav")
    targetEnt:EmitSound("physics/cardboard/cardboard_box_impact_bullet2.wav")
end

net.Receive( "progressDone", function( len, ply )
    local targetEnt = net.ReadEntity()
    createRadios(targetEnt)
end)