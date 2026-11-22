--[[-----------
Door Breaking |
---------------

Taken and edited from "Advanced SCP-682 SWEP" for performance and clarity.

For use in SWEPS/Addons where the destruction of a door is needed.
]]

net.Receive("DGUtil:DestroyDoor", function(len)
	local door = net.ReadEntity()
	if not IsValid(door) then return end

	door:EmitSound(DGUtil.DoorBreak.DestroySound, 90)
	ParticleEffect(DGUtil.DoorBreak.DestroyParticle, door:GetPos(), angle_zero)

	local calcPos = net.ReadVector()
	local calcAngle = net.ReadAngle()

	local detail = ents.CreateClientProp()
	detail:SetPos(calcPos)
	detail:SetAngles(calcAngle)
	detail:SetModel(door:GetModel())
	detail:Spawn()

	timer.Simple(DGUtil.DoorBreak.RespawnTimeCVAR:GetFloat(), function()
		if IsValid(detail) then
			detail:Remove()
		end
	end)
end)