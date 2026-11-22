DGUtil.DoorBreak = {}

DGUtil.DoorBreak.DestroyParticle = "feeps_veeds_682_doordestroy"



game.AddParticles("particles/fv_scp682.pcf")

PrecacheParticleSystem(DGUtil.DoorBreak.DestroyParticle)



DGUtil.DoorBreak.DestroySound = "fv_addons/682_door_destroy.wav"

DGUtil.DoorBreak.DestroyModels = {

    ["models/foundation/doors/lcz_door.mdl"] = true,

    ["models/foundation/doors/hcz_door_01.mdl"] = true,

    ["models/foundation/doors/hcz_door_02.mdl"] = true

}



DGUtil.DoorBreak.RespawnTimeCVAR = 		CreateConVar("fv_scp682_door_respawn_time", 60 * 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Amount of seconds the destroyed doors take to respawn", 1)

DGUtil.DoorBreak.DestroyTimeCVAR =		CreateConVar("fv_scp682_door_destroy_time", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Amount of seconds SCP-682 takes to destroy a door", 0)

DGUtil.DoorBreak.DoorDestroyCVAR = 		CreateConVar("fv_scp682_enable_doordestroying", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable destroying of the doors for SCP-682")
