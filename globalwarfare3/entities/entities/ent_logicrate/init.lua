AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("globalwarfare3/gamemode/vgui/cl_logipanel.lua")
include("globalwarfare3/gamemode/logihandler/sv_logihandler.lua")
include("shared.lua")

util.AddNetworkString("alertPlayer")
function ENT:Initialize()
    crateLogistic = 200 -- adding the initial logistic amount
    self:SetModel( "models/props/de_nuke/crate_extrasmall.mdl" )
    --self:SetBodygroup(1,1) (This is important for later)
    self:PhysicsInit( SOLID_VPHYSICS ) 
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    local phys = self:GetPhysicsObject() 
    if phys:IsValid() then
    	phys:SetMass(110)
        phys:Wake()
        phys:EnableGravity(true)
    end
    
	local cooldown = 0
	local cooldownTime = 1
	local isPressed = false

	function self:Use(activator, caller) 
	    
	    if activator:IsPlayer() and CurTime() > cooldown and crateLogistic > 0 then
	        isPressed = !isPressed 
	        cooldown = CurTime() + cooldownTime
	        self:EmitSound("ambient/creatures/seagull_idle3.wav")
	        net.Start("alertPlayer")
	    	net.Send(activator)

	    elseif activator:IsPlayer() and CurTime() > cooldown and crateLogistic <= 0 then
	    	isPressed = !isPressed 
	        cooldown = CurTime() + cooldownTime
	    	self:EmitSound("buttons/combine_button_locked.wav")
	    end
	end
end