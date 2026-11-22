AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua") 
include("shared.lua")

function ENT:Initialize()
	self:SetModel(MININGSYSTEM.NPCModel)
	self:SetHullType(HULL_HUMAN);
	self:SetHullSizeNormal();
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetMoveType(MOVETYPE_STEP);
	self:SetSolid(SOLID_BBOX);
	self:SetUseType(SIMPLE_USE);
	self:SetBloodColor(BLOOD_COLOR_RED);

end
local NextUse = 0
function ENT:AcceptInput(it, act, cal)
	if CurTime() < NextUse then return end 
	
	if (it == "Use" and cal:IsPlayer()) then
		net.Start( "OpenMinerMenu" )
		net.Send(cal)
		NextUse = CurTime() + 2
		
		if MININGSYSTEM.FunMode then 
			local sound_choose = math.random(0,100) --i dunno why, but table.random doesn't work here
			
			if sound_choose < 40 then 
				self:EmitSound("miningsystem/fun_mode/300.mp3")
			elseif sound_choose >= 40 and sound_choose < 80 then 
				self:EmitSound("miningsystem/fun_mode/boy_next_door.mp3")
			else 
				self:EmitSound("miningsystem/fun_mode/deep_dark.mp3")
			end 
		end 
	end
end 

