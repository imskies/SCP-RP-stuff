sound.Add({
    name = "SCP3199.Scream",
    channel = CHAN_VOICE,
    volume = 1,
    level = 85,
    pitch = {90, 105},
    sound = "3199scream1.wav"
})

sound.Add({
    name = "SCP3199.Bite",
    channel = CHAN_STATIC,
    volume = 1,
    level = 65,
    pitch = {90, 110},
    sound = {"3199attack.wav",
        "3199attack2.wav",
        "3199attack3.wav",
        "3199attack4.wav"}
})

sound.Add({
    name = "SCP3199.Vomit",
    channel = CHAN_STATIC,
    volume = 0.7,
    level = 65,
    pitch = {95, 105},
    sound = "3199vomit1.wav"
})

sound.Add({
    name = "SCP3199.Death",
    channel = CHAN_STATIC,
    volume = 1,
    level = 75,
    pitch = {95, 105},
    sound = "eggspawn.wav"
})

sound.Add({
    name = "SCP3199.AcidSound",
    channel = CHAN_STATIC,
    volume = 1,
    level = 75,
    pitch = {95, 110},
    sound = "3199acid.wav"
})

sound.Add({
    name = "SCP3199.Corrosion",
    channel = CHAN_STATIC,
    volume = 1,
    level = 60,
    pitch = {95,105},
    sound = "3199spitballimpact.wav"
})

sound.Add({
    name = "SCP3199.AcidImpact",
    channel = CHAN_STATIC,
    volume = 1,
    level = 60,
    pitch = {95,105},
    sound = "3199corrosion.wav"
})


sound.Add({
    name = "SCP3199.Steps",
    channel = CHAN_STATIC,
    volume = 1,
    level = 75,
    pitch = {95, 105},
    sound = {"3199step1.mp3",
        "3199step2.mp3",
        "3199step3.mp3",
        "3199step4.mp3",
        "3199step5.mp3",
        "3199step6.mp3",
        "3199step7.mp3",
        "3199step8.mp3",
        "3199step9.mp3",
        "3199step10.mp3",
        "3199step11.mp3",
        "3199step12.mp3",
        "3199step13.mp3",
        "3199step14.mp3",
        "3199step15.mp3"}
})

sound.Add({
    name = "SCP3199.Idle",
    channel = CHAN_STATIC,
    volume = 1,
    level = 75,
    pitch = {95, 105},
    sound = {"3199idle1.wav",
        "3199idle2.wav"}
})
-----------------------------------------------------------------------------------------------------

/*PrecacheParticleSystem( "eml_generic_crsv" )
// game.AddParticles( "particles/bloomtest.pcf" )
// game.AddParticles( "particles/boxglove_fx.pcf" )
game.AddParticles( "particles/corrosion_fx.pcf" )
game.AddParticles( "particles/cryo_fx.pcf" )
// game.AddParticles( "particles/darkling_fx.pcf" )
// game.AddParticles( "particles/fallingstar_fx.pcf" )
// game.AddParticles( "particles/gravrifle_fx.pcf" )
// game.AddParticles( "particles/lanka_fx.pcf" )
game.AddParticles( "particles/ngen_fx.pcf" )*/

-----------------------------------------------------------------------------------------------------

hook.Add("PlayerDeathSound", "scp3199_DeathSound", function(ply)
    if (!IsValid(ply)) then return end
    if (ply:HasWeapon("scp3199swep")) then
        ply:EmitSound("SCP3199.Death")
        return true
    end
    return nil
end)

local function SCP3199Walk(ply, pos, foot, sound, volume, rf)
    if (!IsValid(ply)) then return end
    if (ply:HasWeapon("scp3199swep")) then
        ply:EmitSound("SCP3199.Steps")
        return false
    end
end

hook.Add("PlayerFootstep", "scp3199_WalkHook", SCP3199Walk)

local PLAYER = FindMetaTable("Player")

function PLAYER:SetInSCP3199Taunt(b)
    if (!SERVER) then return end
    self:Freeze(b)
    self:SetNW2Bool("scp3199_tauntview", b)
end

function PLAYER:GetInSCP3199Taunt()
    return self:GetNW2Bool("scp3199_tauntview", false)
end

if !CLIENT then return end

local lastAlertState = false
local camPos
local camAng
local camFov
local orbitAng       = Angle(0, 0, 0)
local camDist        = 15  
local targetDist     = 115  
local distLerp       = 0

hook.Add("InputMouseApply", "scp3199_freelook", function(cmd, x, y, ang)
    local ply = LocalPlayer()
    if !ply:GetInSCP3199Taunt() then return end
    orbitAng.y = orbitAng.y - x*0.02
    orbitAng.p = math.Clamp(orbitAng.p + y*0.02, -60, 60)
    return true 
end)

hook.Add("CalcView", "scp3199_freelookview", function(ply, pos, ang, fov)
     if ((!IsValid(ply)) or (!ply:Alive()) or (ply:InVehicle()) or (ply:GetViewEntity() != ply)) then
        return
    end
    local infreelook   = ply:GetInSCP3199Taunt()
    if (infreelook != lastAlertState) then
        lastAlertState = infreelook
        if (infreelook) then
            camDist    = 15
            distLerp   = 0
        end
    end
    if (!infreelook) then 
        camPos         = nil
        camAng         = nil
        camFov         = nil     
        
        orbitAng.y     = ang.y
        orbitAng.p     = 0
        return 
    end
    if (infreelook) then
        distLerp       = math.min(distLerp + FrameTime()*0.5, 1)
        camDist        = Lerp(distLerp, camDist, targetDist)
    end
    local camDir       = orbitAng:Forward()
    local targetPos    = pos - camDir * camDist + Vector(0,0,14)    
    local targetAng    = (pos - targetPos):Angle()
    local ct           = CurTime()
    local sway         = math.sin(ct*6)*0.5
    targetAng          = targetAng + Angle(sway, 0, sway*0.2)
    camPos             = camPos or targetPos
    camAng             = camAng or targetAng
    local lerpSpeed    = 12*FrameTime()
    camPos             = LerpVector(lerpSpeed, camPos, targetPos)
    camAng             = LerpAngle(lerpSpeed, camAng, targetAng)
    local tr           = util.TraceHull({
        start  = pos,
        endpos = camPos,
        filter = ply,
        mins   = Vector(-6,-6,-6),
        maxs   = Vector(6,6,6),
        mask   = MASK_SOLID
    })
    local finalPos     = tr.Hit and tr.HitPos or camPos
    local shake        = math.sin(ct*4)
    local shakenAng    = camAng + Angle(shake, shake*0.5, shake)
    camFov             = camFov or fov
    local targetFov    = fov*1.1 
    camFov             = Lerp(FrameTime()*4, camFov, targetFov)
    return {
        origin     = finalPos,
        angles     = shakenAng,
        fov        = camFov,
        drawviewer = true,
    }
end)