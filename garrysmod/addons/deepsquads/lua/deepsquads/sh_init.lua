DeepSquads = DeepSquads or {}

DeepSquads.Success = Color(61,184,50)
DeepSquads.Failure = Color(177,41,41)

-- Squads are organized by the squad creator
--[[ Structure of squads:
DeepSquads.Squads[STEAMID_CREATOR] = {
    name = "Sergeant Jones' Squad",
    tag = "Security",
    sid = STEAMID_CREATOR,
    creator = CreatorEntity,
    members = {
        STEAMID_CREATOR = {name = "Sergeant Jones", hp = 100, plyref = CreatorEntity},
        STEAMID_USER1 = {name = "Officer Austin", hp = 84, plyref = User1Entity},
        STEAMID_USER2 = {name = "Specialist Jack", hp = 100, plyref = User2Entity}
    }
}
]]--
DeepSquads.Squads = DeepSquads.Squads or {}

MsgC("[Deep Squads]", DeepSquads.Success, " Base initialized.\n") -- EOF