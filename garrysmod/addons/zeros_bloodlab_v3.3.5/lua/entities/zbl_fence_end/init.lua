/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 75
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)

	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	local parent = self:GetMain()

	if IsValid(parent) then

		local min,max = self:GetBoxData(parent)

		local x0 = min.x
		local y0 = min.y
		local z0 = min.z

		local x1 = max.x
		local y1 = max.y
		local z1 = max.z
		self:PhysicsInitConvex( {
			Vector( x0, y0, z0 ),
			Vector( x0, y0, z1 ),
			Vector( x0, y1, z0 ),
			Vector( x0, y1, z1 ),

			Vector( x1, y0, z0 ),
			Vector( x1, y0, z1 ),
			Vector( x1, y1, z0 ),
			Vector( x1, y1, z1 )
		} )

		self:SetSolid( SOLID_VPHYSICS )

		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self:SetSolid(SOLID_VPHYSICS)

		self:EnableCustomCollisions( true )
		self:SetTrigger(true)

		self:SetCollisionBounds(min,max)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

		self.PhysgunDisabled = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

		self:PhysWake()
	else
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	self:DrawShadow( false )
end

function ENT:StartTouch(other)
	if not IsValid(other) then return end
	if other:IsPlayer() and other:Alive() then
		if zbl.config.Fence.dmg_per_touch > 0 then
			zbl.Fence.ShockPlayer(self,other)
		end
	elseif other:IsVehicle() and zbl.config.Fence.kill_driver == true then
		local ply = other:GetDriver()
		if IsValid(ply) then
			ply:Kill()
			self:EmitSound("zbl_fence_zap")
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	if (not self.m_bApplyingDamage) then
		self.m_bApplyingDamage = true
		self:TakeDamageInfo(dmginfo)
		if IsValid(self:GetMain()) then
			zbl.Fence.OnDamage(self:GetMain(), dmginfo)
		end
		self.m_bApplyingDamage = false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
