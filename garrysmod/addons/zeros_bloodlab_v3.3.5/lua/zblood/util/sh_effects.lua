/*
    Addon id: f60c11f4-6a70-423c-a926-0bea1813031f
    Version: v3.3.5 (stable)
*/

zclib.NetEvent.AddDefinition("zbl_infect_cough", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zclib.Effect.ParticleEffect("zbl_cough_infect", pos, Angle(0, 0, 0))
end)

zclib.NetEvent.AddDefinition("zbl_infect_diaria", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	local pos = ent:GetPos()
	zclib.Effect.ParticleEffect("zbl_diaria_explosion", pos, Angle(0, 0, 0), ent)
	ent:EmitSound("zbl_fart")

	if zclib.Convar.Get("zbl_cl_decals") == 1 then
		zclib.Effect.RandomDecals(pos, "YellowBlood", 50)
	end
end)

zclib.NetEvent.AddDefinition("zbl_explode_head", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zclib.Effect.ParticleEffect("zbl_explode_head", pos, Angle(0, 0, 0))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 416d42f176d5d9b4d00c1b656d08e82ef9d15375d07ca94486d34a6d6705ee10

	if zclib.Convar.Get("zbl_cl_decals") == 1 then
		zclib.Effect.RandomDecals(pos, "Blood", 100)
	end

	zbl.Sound.EmitFromPosition(pos, "VomitExplosion")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199022046337

zclib.NetEvent.AddDefinition("zbl_player_disinfect", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	local entityClass = GetViewEntity():GetClass()

	if entityClass == "gmod_cameraprop" or (entityClass == "player" and GetConVar("simple_thirdperson_enabled") and GetConVar("simple_thirdperson_enabled"):GetBool()) then
		local bone = ent:LookupBone("ValveBiped.Bip01_R_Hand")
		local _pos, _ang

		if bone then
			_pos, _ang = ent:GetBonePosition(bone)
			_ang:RotateAroundAxis(_ang:Right(), -90)
			_pos = _pos + (_ang:Forward() * 5) + (_ang:Right() * 2)
		else
			_pos = ent:GetPos() + ent:GetUp() * 15
			_ang = ent:GetAngles()
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 810517969e54369390d098bf094764ab97c045b14d3b8511404abf93da021955

		zclib.Effect.ParticleEffect("zbl_disinfect", _pos, _ang, ent)
	else
		local ang = ent:EyeAngles()
		ang:RotateAroundAxis(ang:Right(), -90)
		zclib.Effect.ParticleEffect("zbl_disinfect", ent:EyePos() + ang:Up() * 5, ang, ent)
	end
end)

zclib.NetEvent.AddDefinition("zbl_player_shock", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	ent:EmitSound("zbl_fence_zap")
	local effectdata = EffectData()
	effectdata:SetOrigin(ent:GetPos() + Vector(0, 0, 50))
	effectdata:SetMagnitude(1000)
	effectdata:SetScale(1)
	effectdata:SetRadius(5)
	util.Effect("cball_bounce", effectdata)
end)

zclib.NetEvent.AddDefinition("zbl_fence_disinfect", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	ent:EmitSound("zbl_spray")
	zclib.Effect.ParticleEffect("zbl_disinfect", ent:GetPos(), ent:GetAngles(), ent)
end)

zclib.NetEvent.AddDefinition("zbl_node_explode", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zclib.Effect.ParticleEffect("zbl_infect_nodeexplode", pos, Angle(0, 0, 0))
	zbl.Sound.EmitFromPosition(pos, "spore_explo")
end)

zclib.NetEvent.AddDefinition("zbl_jar_break_sample", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zbl.Sound.EmitFromPosition(pos, "JarBreak")
	zclib.Effect.ParticleEffect("zbl_jar_explode_blue", pos, Angle(0, 0, 0))
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ab8b927d1e546f5f12f79c6f148027d249dbc36c87356f49ca8d04a2157f6f4c

zclib.NetEvent.AddDefinition("zbl_jar_break_virus", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zbl.Sound.EmitFromPosition(pos, "JarBreak")
	zclib.Effect.ParticleEffect("zbl_infect_nodeexplode", pos, Angle(0, 0, 0))
end)

zclib.NetEvent.AddDefinition("zbl_jar_break_cure", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zbl.Sound.EmitFromPosition(pos, "JarBreak")
	zclib.Effect.ParticleEffect("zbl_jar_explode_green", pos, Angle(0, 0, 0))
end)

zclib.NetEvent.AddDefinition("zbl_jar_break_abillity", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zbl.Sound.EmitFromPosition(pos, "JarBreak")
	zclib.Effect.ParticleEffect("zbl_jar_explode_yellow", pos, Angle(0, 0, 0))
end)

zclib.NetEvent.AddDefinition("zbl_jar_break_blood", {
	[1] = {
		type = "vector"
	}
}, function(received)
	local pos = received[1]
	if pos == nil then return end
	zbl.Sound.EmitFromPosition(pos, "JarBreak")
	zclib.Effect.ParticleEffect("zbl_jar_explode_blood", pos, Angle(0, 0, 0))
end)

zclib.NetEvent.AddDefinition("zbl_scan_fx", {
	[1] = {
		type = "entity"
	}
}, function(received)
	local ent = received[1]
	if not IsValid(ent) then return end
	if LocalPlayer() == ent then return end
	zclib.Effect.ParticleEffect("zbl_scan_small", ent:GetPos(), Angle(0, 0, 0), ent)
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e0c7f2892030da962e1c4479c4d66a4fab47a43be34ee2c7a44e11d1cf30205c
