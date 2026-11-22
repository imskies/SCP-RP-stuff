/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 15
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zclib.Player.SetOwner(ent, ply)

	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	local r = 1
	self.PhysObjRadius = r
	self:PhysicsInitSphere(r, "default")
	self:SetCollisionBounds(Vector(-r, -r, -r), Vector(r, r, r))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self.PhysgunDisabled = true
	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:Wake()
	else
		self:Remove()

		return
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

	self:StartMotionController()
	self:SetCustomCollisionCheck(true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	-- This gets set by other system to tell it where to fly
	-- but if it doesent then we just fly up
	if self.FlyDir == nil then
		self.FlyDir = self:GetAngles():Up()
	end

	self.HitPlayer = false
end

function ENT:GravGunPickupAllowed(ply)
	return false
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

local maxForce = 2 ^ 32

function ENT:PhysicsSimulate(phys, dt)
	if self.zbl_Collided then return end

	if not self.zbl_Increase then
		self.zbl_Increase = 1
	end

	self.zbl_Increase = math.Approach(self.zbl_Increase, maxForce, dt * maxForce * 0.01)
	local force = Vector(0, 0, 0)
	local angForce = Vector(0, 0, 0)
	force = force + self.FlyDir * self.zbl_Increase
	force = force * dt
	angForce = angForce * dt

	return angForce, force, SIM_GLOBAL_ACCELERATION
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046360

function ENT:PhysicsCollide(data, physobj)
	local ent = data.HitEntity

	if IsValid(data.HitObject) and IsValid(ent) and ent:IsPlayer() and ent:Alive() then
		self.HitPlayer = true
		-- Give the player some damage
		zbl.Player.Damage(ply,DMG_ACID,5,self)
	end

	if not self.zbl_Collided then
		local velPlus = data.OurOldVelocity and data.OurOldVelocity:GetNormal() * 60 or Vector(0, 0, 0)
		-- Disable all physics to be save

		local phys = self:GetPhysicsObject()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337
		
		if IsValid(phys) then
			phys:EnableMotion(false)
		end

		timer.Simple(FrameTime(), function()
			if not self:IsValid() then return end
			local pos = data.HitPos - data.HitNormal * self.PhysObjRadius
			self:SetPos(pos + velPlus)
		end)

		local deltime = FrameTime() * 2

		if not game.SinglePlayer() then
			deltime = FrameTime() * 6
		end

		SafeRemoveEntityDelayed(self, deltime)

		if self.VirusID and self.VirusStage then

			local vData = {
				vaccine_id = self.VirusID,
				vaccine_stage = self.VirusStage,
				inflictor = ent.inflictor,
				infect_type = "vomit_projectile"
			}

			zbl.Infect.Proximity(self:GetPos(), 150, 75,vData)
		end

		self.zbl_Collided = true
	end
end
