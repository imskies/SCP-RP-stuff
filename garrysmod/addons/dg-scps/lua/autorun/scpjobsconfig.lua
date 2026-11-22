AddCSLuaFile()

SCPJobsConfig = SCPJobsConfig or {}

SCPJobsConfig[96] = SCPJobsConfig[96] or {}

SCPJobsConfig[96].NonRageSpeed = 100
SCPJobsConfig[96].SprintSpeed = 500
SCPJobsConfig[96].IgnoredJobs = {"Foundation AI [Euclid Rank]", "SCP-008 [Thaumiel Rank]", "Mobile Task Force Alpha-1", "Mobile Task Force Epsilon-11", "Staff on Duty", "SCP-173", "SCP-049", "SCP-682", "SCP-106", "SCP-1048", "SCP-999", "SCP-131-A", "SCP-131-B", "SCP-079", "SCP-662", "SCP-610", "SCP-966", "SCP-076-2", "SCP-343 [Euclid Rank]", "SCP-066 [Safe Rank]", "SCP-457", "SCP-912 [Euclid Rank]", "SCP-939", "SCP-372", "MTF Epsilon-11", "MTF Alpha-1", "SCP-053", "SCP-303", "SCP-1370", "SCP-527", "SCP-1000", "SCP-082", "I.A.U. Agent"}
SCPJobsConfig[96].StrikeDamage = 350
SCPJobsConfig[96].DoorPunchChance = 100
SCPJobsConfig[96].EnrageTime = 25 -- Time enraged in seconds

SCPJobsConfig[66] = SCPJobsConfig[66] or {}

SCPJobsConfig[66].EarRapeCooldown = 90
SCPJobsConfig[66].EarRapeDamageRadius = 400
SCPJobsConfig[66].EarRapeDamage = 20
SCPJobsConfig[66].EricCooldown = 5
SCPJobsConfig[66].NoteCooldown = 5
SCPJobsConfig[66].NearbyRage = 6 -- How many players must be near to be raged

SCPJobsConfig[1048] = SCPJobsConfig[1048] or {}

SCPJobsConfig[1048].StabDamage = 30 -- Damage taken when taking an ear
SCPJobsConfig[1048].MaxEars = 6 -- How many ears are required to make 1048-A
SCPJobsConfig[1048].MaxScraps = 6 -- How many scraps are required to make 1048-C
SCPJobsConfig[1048].PickupCooldown = 4 -- Global cooldown for attempting recontainment of 1048
SCPJobsConfig[1048].TakeCooldown = 15 -- Cooldown for 1048's attempt to take ears or scraps

SCPJobsConfig[1048].EarGuyHP = 350 -- 1048-A HP
SCPJobsConfig[1048].EarGuyModel = "models/1048/tdyear/tdybrownearpm.mdl" -- 1048-A Model
SCPJobsConfig[1048].ScreamCooldown = 13 -- Scream cooldown for 1048-A
SCPJobsConfig[1048].ScreamRadius = 400 -- Radius of damaging scream
SCPJobsConfig[1048].ScreamDamage = 15 -- Damage of scream
SCPJobsConfig[1048].ScreamLength = 6 -- How long the should scream last, in seconds (whole number)
SCPJobsConfig[1048].MoveSpeed = 145 -- How fast 1048 can move

SCPJobsConfig[1048].ScrapGuyHP = 300 -- 1048-C HP
SCPJobsConfig[1048].ScrapGuyModel = "models/1048/tdyear/tdybrownearpm.mdl" -- 1048-C Model
SCPJobsConfig[1048].ShredCooldown = 0.25     -- Melee cooldown for 1048-C
SCPJobsConfig[1048].ShredDamage = 11
SCPJobsConfig[1048].ShredRadius = 65
SCPJobsConfig[1048].ThrowCooldown = 0.95 -- Projectile cooldown for 1048-C
SCPJobsConfig[1048].ThrowDamage = 25

SCPJobsConfig[49] = SCPJobsConfig[49] or {}

SCPJobsConfig[49].CureCooldown = 25 -- Cooldown of zombie-making, in seconds
SCPJobsConfig[49].HealCooldown = 10 -- Cooldown of healing zombies, in seconds
SCPJobsConfig[49].HealAmount = 15 -- Amount 049 heals 049-2 for
SCPJobsConfig[49].ZombieHealth = 325 -- 049-2 health
SCPJobsConfig[49].PunchDamage = 40 -- 049-2 punch damage
SCPJobsConfig[49].DoorPunchChance = 0.25 -- Chance of breaking a door when punching as 049-2, 1 is 100%
SCPJobsConfig[49].GunLightsOn = 2 -- How many guns needed to freeze 049 when lights are on
SCPJobsConfig[49].GunLightsOff = 4 -- How many guns needed to freeze 049 when lights are off

SCPJobsConfig[82] = SCPJobsConfig[82] or {}

SCPJobsConfig[82].KnightCooldown = 180 -- Cooldown between making someone a knight
SCPJobsConfig[82].KnightHealth = 375 -- Health of knight
SCPJobsConfig[82].KnightArmor = 100 -- Armor of knight
SCPJobsConfig[82].KnightSword = { "m9k_damascus", "m9k_knife" } -- Knight's weapon
SCPJobsConfig[82].PunchDamage = 75 -- SCP-082's Punch Damage (varies 10%)

SCPJobsConfig[343] = SCPJobsConfig[343] or {}

SCPJobsConfig[343].BlessCD = 80 -- Blessing cooldown (seconds)
SCPJobsConfig[343].BlessArmor = 50 -- How much armor boost is given on blessing
SCPJobsConfig[343].BlessHealth = 50 -- How much health boost is given on blessing
SCPJobsConfig[343].BlessSpeed = 1.3 -- Blessing speed boost multiplier
SCPJobsConfig[343].BlessLength = 60 -- How long a blessing lasts (seconds)
SCPJobsConfig[343].BlessRadius = 300 -- Radius of blessing area in hammer units

SCPJobsConfig[966] = SCPJobsConfig[966] or {}

SCPJobsConfig[966].AttackCooldown = 3 -- Seconds between attacks
SCPJobsConfig[966].VisibleDuration = 3 -- How long 966 is visible after being attacked with fire in seconds
SCPJobsConfig[966].AttackDamage = 80 -- Damage of attack
SCPJobsConfig[966].AttackHeal = 0.10 -- Percent of how much is healed from a successful strike

SCPJobsConfig[1000] = SCPJobsConfig[1000] or {}

SCPJobsConfig[1000].PunchDamage = 75
SCPJobsConfig[1000].DoorPunchChance = 50
SCPJobsConfig[1000].BoostSound = "npc/strider/striderx_pain2.wav" -- sounds like a monkey
SCPJobsConfig[1000].BoostJumpMultiplier = 2
SCPJobsConfig[1000].BoostSpeedMultiplier = 1.5
SCPJobsConfig[1000].BoostDuration = 15 -- Seconds of boost

SCPJobsConfig[303] = SCPJobsConfig[303] or {}

SCPJobsConfig[303].AttackDamage = 50
SCPJobsConfig[303].AttackCD = 0.75 -- Seconds
SCPJobsConfig[303].ShootRange = 5000 -- Range of invisible tracker projectile
SCPJobsConfig[303].ShootCD = 2 -- Cooldown invisible tracker projectile
SCPJobsConfig[303].MarkLength = 180 -- Time spent marked (if you die you are unmarked automatically)
SCPJobsConfig[303].ScreamSound = "ambient/voices/squeal1.wav"

SCPJobsConfig["SafeWeapons"] = { -- SWEPs that are tools or harmless (doesn't deal damage on left click)
    ["weapon_ynot053"] = true,
    ["weapon_ynot1000"] = true,
    ["weapon_physgun"] = true,
    ["weapon_physcannon"] = true,
    ["gmod_tool"] = true,
    ["weapon_medkit"] = true,
    ["weapon_slam"] = true,
    ["weapon_bugbait"] = true,
    ["weapon_keypadchecker"] = true,
    ["arrest_stick"] = true,
    ["door_ram"] = true,
    ["keys"] = true,
    ["lockpick"] = true,
    ["med_kit"] = true,
    ["pocket"] = true,
    ["unarrest_stick"] = true,
    ["weaponchecker"] = true,
    ["gmod_camera"] = true,
    ["stunstick"] = true,
    ["alydus_fortificationbuildertablet"] = true,
    ["bkeycard"] = true,
    ["bkeypads_access_logs"] = true,
    ["bkeypads_cracker"] = true,
    ["weapon_bs_tool"] = true,
    ["cityworker_config"] = true,
    ["weapon_defibrillator"] = true,
    ["weapon_stungun"] = true,
    ["mgs_pickaxe"] = true,
    ["deep_commander"] = true,
    ["deep079config"] = true,
    ["scp280"] = true,
    ["deep939"] = true,
    ["flight_swep"] = true,
    ["gas_log_scanner"] = true,
    ["gu_scp_106"] = true,
    ["weapon_cuff_standard"] = true,
    ["weapon_leash_elastic"] = true,
    ["weapon_cuff_elastic"] = true,
    ["weapon_cuff_tactical"] = true,
    ["weapon_cuff_police"] = true,
    ["weapon_leash_rope"] = true,
    ["weapon_cuff_rope"] = true,
    ["weapon_cuff_plastic"] = true,
    ["weapon_cuff_shackles"] = true,
    ["m9k_ied_detonator"] = true,
    ["m9k_proxy_mine"] = true,
    ["m9k_suicide_bomb"] = true,
    ["weapon_armorkit"] = true,
    ["none"] = true,
    ["weapon_chombie610"] = true,
    ["weapon_m9"] = true,
    ["voice_amplifier"] = true,
    ["weapon_deep_scp1048"] = true,
    ["weapon_deep_flir"] = true,
    ["weapon_deep_372"] = true,
    ["weapon_deep_966"] = true,
    ["weapon_rdo_radio"] = true,
    ["weapon_hqshield"] = true,
    ["weapon_combineshield"] = true,
    ["weapon_fbishield"] = true,
    ["weapon_riotshield"] = true,
    ["weapon_koreanshield"] = true,
    ["weapon_smallcombineshield"] = true,
    ["weapon_smallriotshield"] = true,
    ["weapon_extinguisher"] = true,
    ["weapon_extinguisher_infinite"] = true,
    ["ultimate_disguise_kit"] = true,
    ["fv_scp682"] = true,
    ["laserpointer"] = true,
    ["remotecontroller"] = true,
    ["xmas_bomb"] = true,
    ["xmas_suicide"] = true,
    ["zpn_partypopper"] = true,
    ["zpn_partypopper01"] = true,
    ["weapon_better035swep"] = true,
    ["weapon_ynot049"] = true,
    ["weapon_ynot049_2"] = true,
    ["weapon_ynot066"] = true,
    ["weapon_deepscp096"] = true,
    ["weapon_ynot1048"] = true,
    ["weapon_ynot1048a"] = true,
    ["weapon_ynot1048c"] = true,
    ["weapon_ynot173"] = true,
    ["weapon_ynot457"] = true,
    ["weapon_ynot999"] = true,
    ["weapon_handcuffed"] = true,
    ["re_hands"] = true
}

SCPJobsConfig["MeleeWeapons"] = { -- Weapons that require you to be close to use, knives, crowbars, etc; must do damage on left click
    ["weapon_crowbar"] = true,
    ["weapon_stunstick"] = true,
    ["weapon_bs_greatsword"] = true,
    ["weapon_bs_broadsword"] = true,
    ["weapon_bs_gladius"] = true,
    ["weapon_bs_katana"] = true,
    ["weapon_bs_longsword"] = true,
    ["weapon_bs_raider"] = true,
    ["weapon_bs_rapier"] = true,
    ["weapon_bs_scimitar"] = true,
    ["weapon_bs_shortsword"] = true,
    ["weapon_bs_straightsword"] = true,
    ["cw_extrema_ratio_official"] = true,
    ["m9k_damascus"] = true,
    ["m9k_fists"] = true,
    ["m9k_knife"] = true,
    ["m9k_machete"] = true,
    ["xmas_candy"] = true,
    ["weapon_fists"] = true,

}

SCPJobsConfig["RollBonus"] = {
    ["SCPs"] = 20,
}

SCPJobsConfig["RollBonusJob"] = {
    ["Staff on Duty"] = 100, -- Job based roll bonus, overrides category
    ["SCP-066 [Safe Rank]"] = 20,
    ["SCP-096"] = 30,
    ["SCP-035"] = 40,
    ["SCP-1048"] = 40,
    ["Security Special Response Unit"] = 20,
    ["S.W.D. Heavy Weapons Operator"] = 10,
    ["S.W.D. CQC Specialist"] = 10,
    ["S.W.D. Demolitions Expert"] = 10,
    ["S.W.D. Squadron Leader"] = 10,
    ["S.I.D. Containment Specialist"] = 45,
    ["S.I.D. Operative"] = 30,
    ["S.I.D. Enhanced Operative"] = 30,
    ["S.I.D. Supervisor"] = 30,
    ["S.I.D. Deputy Division Leader"] = 40,
    ["S.I.D. Division Leader"] = 40,
    ["Security Captain"] = 20,
    ["Deputy Security Chief"] = 20,
    ["Chief of Security"] = 20,
    ["Security Strike Unit"] = 10,
    ["MTF Iota-10 Agent"] = 10,
    ["MTF Nu-7 Scout"] = 20,
    ["MTF Nu-7 Breacher"] = 20,
    ["MTF Nu-7 Heavy"] = 20,
    ["MTF Nu-7 Assault"] = 20,
    ["MTF Nu-7 Sniper"] = 30,
    ["MTF Nu-7 Sergeant"] = 35,
    ["MTF Nu-7 Major"] = 30,
    ["MTF Nu-7 Commando"] = 40,
    ["MTF Nu-7 Vice Commander"] = 40,
    ["MTF Pi-1 Sniper"] = 20,
    ["MTF Pi-1 Demolitions"] = 20,
    ["MTF Pi-1 Junior Agent"] = 20,
    ["MTF Pi-1 Senior Agent"] = 20,
    ["MTF Pi-1 Commando"] = 40,
    ["MTF Pi-1 Sergeant"] = 30,
    ["MTF Pi-1 Officer"] = 30,
    ["MTF Pi-1 Vice Commander"] = 40,
    ["MTF Pi-1 Commander"] = 40,
    ["MTF Alpha-1"] = 50,
    ["MTF Omega-1"] = 30,
    ["MTF Kappa-7 [Thaumiel Rank]"] = 45,
    ["MTF Epsilon-11"] = 90,
    ["F.E. Swat"] = 10,
    ["C.I. SIGMA Grunt"] = 10,
    ["C.I. IOTA Soldier"] = 10,
    ["C.I. Medic"] = 10,
    ["C.I. CQC"] = 10,
    ["C.I. Engineer"] = 10,
    ["C.I. Heavy"] = 10,
    ["C.I. Rifleman"] = 10,
    ["C.I. Sniper"] = 10,
    ["C.I. Grenadier"] = 10,
    ["C.I. Liberator"] = 40,
    ["C.I. Juggernaut [Thaumiel Rank]"] = 10,
    ["C.I. Deputy Commander"] = 40,
    ["C.I. R&D Handler"] = 40,
    ["MTF Nu-7 Demolitions"] = 30,
    ["MTF Nu-7 Support Unit"] = 30,
    ["MTF Nu-7 Paramedic"] = 30,
    ["MTF Nu-7 Junior Agent"] = 30,
    ["MTF Nu-7 Senior Agent"] = 30,
    ["MTF Nu-7 Officer"] = 35,
    ["MTF Nu-7 Commander"] = 30,
    ["S.S.U. Vanguard"] = 30,
    ["S.S.U. Enforcer"] = 40,
    ["S.S.U. Spearhead"] = 40,
    ["C.I. Conscript"] = 10,
    ["C.I. Iota"] = 10,
    ["C.I. Kilo"] = 10,
    ["C.I. Gamma"] = 30,
    ["C.I. Alpha"] = 30,
    ["C.I. Vice Commander"] = 40,
    ["C.I. Commander"] = 40,
    ["C.I. Demolitions"] = 10,
    ["C.I. Heavy"] = 10,
    ["C.I. Medic"] = 10,
    ["C.I. Elite"] = 30,
    ["C.I. R&D Scientist"] = 40,
    ["Disciple"] = 10,
    ["Zealot"] = 20,
    ["Serpent"] = 25,
    ["Council"] = 35,
}

if CLIENT then
    surface.CreateFont(
        "SCPJobsFont",
        {
            font = "Arial",
            size = ScreenScale(15),
            weight = 1000,
            antialias = true,
            shadow = false
        }
    )
end