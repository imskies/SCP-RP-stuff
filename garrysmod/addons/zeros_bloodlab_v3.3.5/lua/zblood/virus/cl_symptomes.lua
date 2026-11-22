/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

if SERVER then return end

zbl = zbl or {}
zbl.RunningHooks = zbl.RunningHooks or {}

local function RemoveHook(name)
	hook.Remove("Think", name)
	table.RemoveByValue(zbl.RunningHooks,name)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

local function CreateHook(name,func)
	RemoveHook(name)
	hook.Add("Think", name, func)
	table.insert(zbl.RunningHooks,name)
end


// Used to scale the specified players head
net.Receive("zbl_scalebone", function(len)
	local ply = net.ReadEntity(ply)
	local scale = net.ReadInt(16) / 10
	local boneid = net.ReadInt(16)
	local speed = net.ReadInt(16)
	if IsValid(ply) and scale then
		local name = "zbl_scalebone_" .. boneid .. "_" .. ply:EntIndex()

		CreateHook(name, function()
			if IsValid(ply) and scale then
				local cur_scale = ply.zbl_bonescale or 1

				if cur_scale == scale then
					RemoveHook(name)
					return
				end

				if cur_scale < scale then
					cur_scale = math.Clamp(cur_scale + (speed * FrameTime()), cur_scale, scale)
				else
					cur_scale = math.Clamp(cur_scale - (speed * FrameTime()), scale, cur_scale)
				end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

				ply.zbl_bonescale = cur_scale

				// Scales the players head to the new scale
				if boneid then
					ply:ManipulateBoneScale(boneid, Vector(cur_scale, cur_scale, cur_scale))
				end
			else
				RemoveHook(name)
			end
		end)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c

local LastMoveDistortion = -1
local MoveStrength = 0
local MoveSwitch = false
local function ModifyMovement(ply,cmd)
	if not IsValid(ply) then return end
	if not ply:Alive() then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

	local mEffects = zbl.Vaccine.GetMutationStage_Effects(zbl.Vaccine.Get(ply),zbl.Vaccine.GetStage(ply))
	if mEffects == nil then return end

	local mv_fw = cmd:GetForwardMove()
	local mv_sd = cmd:GetSideMove()

	local strength = mEffects["movement_distortion"]
	if strength then
		if LastMoveDistortion < CurTime() then
			MoveStrength = math.Rand(-strength,strength)
			MoveSwitch = not MoveSwitch
			LastMoveDistortion = CurTime() + math.Rand(5 / strength, 3)
		else
			if MoveSwitch then
				mv_fw = mv_fw + (10000 * MoveStrength)
				mv_sd = mv_sd + (10000 * MoveStrength)
			end
		end
	end

	if mEffects["movement_invert"] then
		mv_fw = -mv_fw
		mv_sd = -mv_sd
	end

	cmd:SetForwardMove(mv_fw)
	cmd:SetSideMove(mv_sd)
end
zclib.Hook.Add("StartCommand", "zbl_movement_StartCommand", function(ply, cmd) ModifyMovement(ply, cmd) end)
