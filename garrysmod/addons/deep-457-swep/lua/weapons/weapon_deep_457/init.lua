resource.AddFile( "materials/scp457-custom/passive.png" )
resource.AddFile( "materials/scp457-custom/onfire.png" )

local delay457 = (DeepGaming457 and DeepGaming457.HeatWaveCooldown) or 5
local nextOccurance457 = 0
local current457EffectStatus = 0

local function spec457Ability(wep, playerself)
    delay457 = delay457 or 5
    nextOccurance457 = nextOccurance457 or 0

    local timeLeft457 = nextOccurance457 - CurTime()
    if timeLeft457 >= 0 then return end

    local wasOnFire = current457EffectStatus
    current457EffectStatus = 0

    if CLIENT then return end

    for _, ply in ipairs(player.GetAll()) do
        if playerself:GetPos():DistToSqr(ply:GetPos()) <= DeepGaming457.BurnDistance^2 then
            if not DeepGaming457.ImmuneJobs[team.GetName(ply:Team())] then
                if ply != playerself then
                    local boomSpec457 = DamageInfo()
                    boomSpec457:SetDamageType(67108864)
                    boomSpec457:SetDamage(DeepGaming457.BoomDamage)
                    boomSpec457:SetAttacker(playerself)
                    boomSpec457:SetInflictor(wep)
                    ply:TakeDamageInfo(boomSpec457)
                    ply:Freeze(true)
                    if wasOnFire == 1 then ply:Ignite(0.5) end
                    timer.Simple(DeepGaming457.StunnedTime, function()
                        if IsValid(ply) then ply:Freeze(false) end
                    end)
                end
            end
        end
    end

    wep:SetNextPrimaryFire(CurTime() + DeepGaming457.SetNextBurn)
    playerself:EmitSound("deep457swep/457boom.mp3", 66, 100, 1, 1)
    nextOccurance457 = CurTime() + delay457
end

function SWEP:Deploy()
    self:SetHoldType("normal")
    current457EffectStatus = 0
    self:GetOwner():SetModelScale(DeepGaming457.StartingSize, 0)
    if SERVER then
        self:GetOwner():GodEnable()
    end
end

function SWEP:PrimaryAttack()
    current457EffectStatus = 1
    self.Owner:SetModelScale(DeepGaming457.MaxSize, 35)
end

function SWEP:SecondaryAttack()
    current457EffectStatus = 0
    self:GetOwner():SetModelScale(DeepGaming457.StartingSize, 25)
end

if DeepGaming457 and DeepGaming457.EnableHeatWave == true then
    function SWEP:Reload()
        spec457Ability(self, self:GetOwner())
    end
end

function SWEP:Think()
    if CLIENT then return end
    if current457EffectStatus == 1 then
        for _, ply in ipairs(player.GetAll()) do
            if self:GetOwner():GetPos():DistToSqr(ply:GetPos()) <= DeepGaming457.BurnDistance^2 then
                if not DeepGaming457.ImmuneJobs[team.GetName(ply:Team())] then
                    ply:Ignite(DeepGaming457.BurnTime)
                end
            end
        end
    end
end

hook.Add("ExtinguisherDoExtinguish", "scp457BeGone", function(ply)
    if ply:IsPlayer() and ply:Alive() and ply:HasWeapon("weapon_deep_457") then
        ply:Extinguish()
        current457EffectStatus = 0
    end
    return true
end)

if CLIENT then
    function SWEP:OnRemove()
        current457EffectStatus = 0
    end
end

if SERVER then
    function SWEP:OnRemove()
        if IsValid(self:GetOwner()) then
            self:GetOwner():GodDisable()
        end
    end
end