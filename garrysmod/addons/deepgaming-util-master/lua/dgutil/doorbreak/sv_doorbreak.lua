--[[-----------
Door Breaking |
---------------

Taken and edited from "Advanced SCP-682 SWEP" for performance and clarity.

For use in SWEPS/Addons where the destruction of a door is needed.
]]

util.AddNetworkString("DGUtil:DestroyDoor")
function DGUtil:DestroyDoor(pos, destroyer) -- Using pos instead of an entity is more reliable because in SCP Map, door uses two func_door
	local doors = ents.FindInSphere(pos, 70)
	local sent = false

	for _,v in pairs(doors) do
		if v:GetClass() ~= "func_door" and not IsValid(v.FPPOwner) then continue end
		local prop_dynamic

		if IsValid(v.FPPOwner) then -- Breaking player props
			if not v.isFadingDoor then continue end

			prop_dynamic = v
		else
			prop_dynamic = v:GetChildren()[1]
		end

		if not IsValid(prop_dynamic) then continue end
		if not DGUtil.DoorBreak.DestroyModels[prop_dynamic:GetModel()] and not IsValid(prop_dynamic.FPPOwner) then continue end
		if v:GetNoDraw() or prop_dynamic:GetNoDraw() then continue end
		if v:GetSaveTable().m_toggle_state == 0 then continue end -- The door is open, don't destroy

		if not sent then
			net.Start("DGUtil:DestroyDoor")
				net.WriteEntity(prop_dynamic)

				local toPly		= (destroyer:GetPos() - v:GetPos()):GetNormalized()
				local face		= toPly:Dot(prop_dynamic:GetAngles():Right()) > 0

				local calcPos	= v:GetPos() + v:OBBMins() + v:GetAngles():Up() * 3 + prop_dynamic:GetAngles():Right() * (face and -70 or 70)
				local calcAngle	= Angle(math.random(0, 1) == 1 and 180 or 0, 90 * math.random() * 70,90)

				net.WriteVector(calcPos)
				net.WriteAngle(calcAngle)
			net.Broadcast()
			sent = true
		end

		v:SetNoDraw(true)
		v:SetNotSolid(true)

		timer.Simple(0.2, function()
			if IsValid(prop_dynamic) then
				prop_dynamic:SetNotSolid(true)
				prop_dynamic:SetNoDraw(true)
			end
		end)

		timer.Simple(DGUtil.DoorBreak.RespawnTimeCVAR:GetFloat(), function()
			if IsValid(v) then
				v:SetNoDraw(false)
				v:SetNotSolid(false)
			end

			if IsValid(prop_dynamic) then
				prop_dynamic:SetNotSolid(false)
				prop_dynamic:SetNoDraw(false)
			end
		end)
	end
end