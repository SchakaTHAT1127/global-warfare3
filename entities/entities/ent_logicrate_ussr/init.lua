AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("globalwarfare3/gamemode/vgui/cl_logipanel_ussr.lua")
include("globalwarfare3/gamemode/logihandler/sv_logihandler.lua")
include("shared.lua")

util.AddNetworkString("callClient_ussr")
util.AddNetworkString("crateVector_ussr")
--[[
these are the props, when ent gets damaged a random prop will be selected from here
]]
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

--[[
same with top one, this time only sounds.
]]

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
	-- the initial logistic amouınt
	self.crateLogistic = 200
	-- giving  the amount of logistic to the client
    self:SetNWInt("logisticAmountUssr", self.crateLogistic)
    -- the health
    self:SetMaxHealth(2000)
    self:SetHealth(2000)

    self:SetModel("models/props/cs_militia/crate_extrasmallmill.mdl")
    self:PhysicsInit(SOLID_VPHYSICS) 
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject() 
    if phys:IsValid() then
    	-- setting the mass, more than 200 is sketchy because player cant pick
        phys:SetMass(200)
        phys:Wake()
        phys:EnableGravity(true)
    end
    
    self.cooldown = 0
    -- cooldown, you can change it like you want if you want the player to open slower or quicker
    self.cooldownTime = 1.5

    -- waiting sometime for initialization
    timer.Simple(0.1, function()
        if IsValid(self) then
        	-- sending the position to clients.
            local pos = self:GetPos()
            net.Start("crateVector_ussr")
                net.WriteVector(pos)
            net.Broadcast()
        end
    end)
end

function ENT:Use(activator, caller) 
	-- preventing any probable errors
    if not IsValid(activator) or not activator:IsPlayer() then return end 

    local curPos = self:GetPos()
    -- you can change the distance to open the crate
    local distance = curPos:Distance(activator:GetPos())
    local maxDistance = 75

    -- distance, cooldown system
    if distance <= maxDistance then
        if CurTime() > self.cooldown then
        	--you cant use it if you dont press ALT (slowwalk)
        	if activator:KeyDown(262144) then
	            self.cooldown = CurTime() + self.cooldownTime

	            -- only can use if the logistic is still usable and not 0
	            if self.crateLogistic > 0 then
	                net.Start("crateVector_ussr")
	                    net.WriteVector(curPos)
	                net.Broadcast()

	                net.Start("callClient_ussr")
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

    if self:Health() <= 0 or self.crateLogistic <= 0 then
        self:Remove()
    end

    self.crateLogistic = self.crateLogistic - (dmginfo:GetDamage() / 10)
    self:SetNWInt("logisticAmountUssr", math.Round(self.crateLogistic))
    
    if self.crateLogistic <= 0 then self:Remove() end
end

function ENT:SetLogisticAmountUssr(amount)
    self.crateLogistic = amount
 	self:SetNWInt("logisticAmountUssr", math.Round(amount))
    print(self:GetClass() .. " yeni lojistik amountı: " .. amount)
end