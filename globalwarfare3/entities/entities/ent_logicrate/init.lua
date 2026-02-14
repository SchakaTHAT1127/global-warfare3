AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("globalwarfare3/gamemode/vgui/cl_logipanel.lua")
include("globalwarfare3/gamemode/logihandler/sv_logihandler.lua")
include("shared.lua")

util.AddNetworkString("alertPlayer")
util.AddNetworkString("vectorOfSelf")
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
	self.crateLogistic = 200
    self:SetNWInt("LogiAmount", self.crateLogistic) -- İlk değeri tanımla
    self:SetMaxHealth(1200)
    self:SetHealth(1200)
    self:SetModel("models/props/de_nuke/crate_extrasmall.mdl")
    self:PhysicsInit(SOLID_VPHYSICS) 
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject() 
    if phys:IsValid() then
        phys:SetMass(250)
        phys:Wake()
        phys:EnableGravity(true)
    end
    
    self.cooldown = 0
    self.cooldownTime = 1.5
    timer.Simple(0.1, function()
        if IsValid(self) then
            local pos = self:GetPos()
            net.Start("vectorOfSelf")
                net.WriteVector(pos)
            net.Broadcast()
        end
    end)
end

function ENT:Use(activator, caller) 
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local curPos = self:GetPos()
    local distance = curPos:Distance(activator:GetPos())
    local maxDistance = 65 -- Increased slightly; 50 is very small

    if distance <= maxDistance then
        if CurTime() > self.cooldown then
            self.cooldown = CurTime() + self.cooldownTime
            
            if self.crateLogistic > 0 then
                net.Start("vectorOfSelf")
                    net.WriteVector(curPos)
                net.Broadcast()

                net.Start("alertPlayer")
				    net.WriteEntity(self)
				net.Send(activator)

                self:EmitSound("snd_jack_aidboxopen.ogg")
            else
                self:EmitSound("buttons/combine_button_locked.wav")
            end
        end
    end
end

function ENT:OnTakeDamage( dmginfo )

    local damage = dmginfo:GetDamage()
    self:SetHealth(self:Health() - damage)
    
    -- Prop Spawn İşlemi
    local prop = ents.Create("prop_physics")
    if not IsValid(prop) then return end

    local randomModel = table.Random(randomProps)
    prop:SetModel(randomModel)
    prop:SetPos(self:GetPos() + Vector(0, 0, 40))
    prop:SetAngles(AngleRand())
    prop:Spawn()
	prop:SetRenderMode( 1 )
	    
	local alpha = 255
	local timerID1 = "FadeProp1_" .. prop:EntIndex()
	local timerID2 = "FadeProp2_" .. prop:EntIndex()

	local randomSound = table.Random(randomSounds)
	self:EmitSound(randomSound)

	timer.Create(timerID2, 1, 1, function() 
		timer.Create(timerID1, 0.05, 26, function() 
		    if IsValid(prop) then
		        alpha = alpha - 15
		        if alpha < 0 then alpha = 0 end -- Alpha eksiye düşmesin
		        
		        prop:SetColor(Color(255, 255, 255, alpha))
		        
		        if alpha <= 0 then
		            prop:Remove()
		        end
		    else
		        timer.Remove(timerID1)
		    end
		end)
	end)

    -- Ana sandık ölürse
    if self:Health() <= 0 or self.crateLogistic <= 0 then
        self:Remove()
    end

    self.crateLogistic = self.crateLogistic - (dmginfo:GetDamage() / 6)
    self:SetNWInt("LogiAmount", math.Round(self.crateLogistic))
    
    if self.crateLogistic <= 0 then self:Remove() end
end