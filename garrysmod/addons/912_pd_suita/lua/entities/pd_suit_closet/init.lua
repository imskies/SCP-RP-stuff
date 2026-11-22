AddCSLuaFile("shared.lua") 

include("shared.lua")

function ENT:Initialize()
    self:SetModel( "models/props_wasteland/controlroom_storagecloset001a.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS ) 
    self:SetMoveType( MOVETYPE_VPHYSICS ) 
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self:SetBodygroup( 0, 0 )
    local phys = self:GetPhysicsObject()
    if ( phys:IsValid() ) then
		phys:Wake()
    end
end

function ENT:Use(activator, caller)
	local hasSuit = true
	
	for _, ply in pairs( player.GetAll() ) do
		if ply:GetModel() == "models/arachnit/HDTF/characters/soldier/soldier_player_blck.mdl" then 
			hasSuit = false
			break
		end
	end
	
	if hasSuit == true then
		self.PreviousModel = caller:GetModel()
		caller:SetModel( "models/arachnit/HDTF/characters/soldier/soldier_player_blck.mdl" )
		caller:ChatPrint( "[SCP-912] - You are now wearing the SWAT Captain Uniform" )
	else
		if caller:GetModel() == "models/arachnit/HDTF/characters/soldier/soldier_player_blck.mdl" then
			caller:SetModel( self.PreviousModel )
			caller:ChatPrint( "[SCP-912] - You have put the SWAT Captain Uniform away" )
		else
			caller:ChatPrint( "[SCP-912] - The SWAT Captain Uniform has already been taken" )
		end
	end
end