ENT.Type = "ai";
ENT.Base = "base_ai";
ENT.AutomaticFrameAdvance = true;
ENT.PrintName = "Shop NPC";
ENT.Author = "William";
ENT.Category = "William's items";
ENT.Spawnable = false;

function ENT:SetAutomaticFrameAdvance( bUsingAnim ) -- This is called by the game to tell the entity if it should animate itself.
	self.AutomaticFrameAdvance = bUsingAnim;
end
