--[[-----------------------------------------------------------------------
Categories
---------------------------------------------------------------------------
The categories of the default F4 menu.

Please read this page for more information:
https://darkrp.miraheze.org/wiki/DarkRP:Categories

In case that page can't be reached, here's an example with explanation:

DarkRP.createCategory{
    name = "Citizens", -- The name of the category.
    categorises = "jobs", -- What it categorises. MUST be one of "jobs", "entities", "shipments", "weapons", "vehicles", "ammo".
    startExpanded = true, -- Whether the category is expanded when you open the F4 menu.
    color = Color(0, 107, 0, 255), -- The color of the category header.
    canSee = function(ply) return true end, -- OPTIONAL: whether the player can see this category AND EVERYTHING IN IT.
    sortOrder = 100, -- OPTIONAL: With this you can decide where your category is. Low numbers to put it on top, high numbers to put it on the bottom. It's 100 by default.
}


Add new categories under the next line!
---------------------------------------------------------------------------]]
DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 0, 
    startExpanded = true, 
    color = Color(255, 191, 0, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "D-Class", 
    categorises = "jobs", 
})

DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 1, 
    startExpanded = true, 
    color = Color(25, 25, 170, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "Security", 
    categorises = "jobs", 
})

DarkRP.createCategory({ 
    updateTime = 1780940853, 
    sortOrder = 2, 
    startExpanded = true, 
    color = Color(25, 25, 170, 255), 
    updateBy = "D-1606 ([DG] Juan)", 
    updateByID = "STEAM_0:1:505389076", 
    name = "Security Specialization", 
    categorises = "jobs", 
})

DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 3, 
    startExpanded = true, 
    color = Color(240, 40, 40, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "Foundation Enforcement", 
    categorises = "jobs", 
})

DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 4, 
    startExpanded = true, 
    color = Color(255, 255, 255, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "Research", 
    categorises = "jobs", 
})

DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 5, 
    startExpanded = true, 
    color = Color(120, 0, 24, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "Mobile Task Force", 
    categorises = "jobs", 
})


DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 6, 
    startExpanded = true, 
    color = Color(0,127,31, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "Chaos Insurgency", 
    categorises = "jobs", 
})

DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 7, 
    startExpanded = true, 
    color = Color(255, 220, 0, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "SCPs", 
    categorises = "jobs", 
})

DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 8, 
    startExpanded = true, 
    color = Color(0,0,0, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "Site Administration", 
    categorises = "jobs", 
})

DarkRP.createCategory({ 
    updateTime = 1775324890, 
    sortOrder = 9, 
    startExpanded = true, 
    color = Color(85, 85, 85, 255), 
    updateBy = "LCPL Thrawn", 
    updateByID = "STEAM_0:0:581542620", 
    name = "Other MTF Units", 
    categorises = "jobs", 
})

FoundationTeamTables = FoundationTeamTables or {
    MTF = {},
    Research = {},
    FE = {},
    Security = {}
}

FoundationTeamLookup = FoundationTeamLookup or {
    MTF = {},
    Research = {},
    FE = {},
    Security = {}
}

MTFTeams = FoundationTeamTables.MTF
ResearchTeams = FoundationTeamTables.Research
FETeams = FoundationTeamTables.FE
SecurityTeams = FoundationTeamTables.Security

local function ResolveFoundationTeamIndex(teamOrPlayer)
    if IsEntity(teamOrPlayer) and teamOrPlayer.Team then
        return teamOrPlayer:Team()
    end

    return tonumber(teamOrPlayer)
end

local function GetFoundationTeamGroup(teamIndex)
    local job = RPExtraTeams and RPExtraTeams[teamIndex]
    local searchValues = {
        string.Trim(string.lower(tostring(job and job.category or ""))),
        string.Trim(string.lower(tostring(job and job.name or ""))),
        string.Trim(string.lower(team.GetName(teamIndex) or ""))
    }

    for _, value in ipairs(searchValues) do
        if value ~= "" then
            if string.find(value, "mobile task force", 1, true) or string.find(value, "mtf", 1, true) then
                return "MTF"
            elseif string.find(value, "research", 1, true) then
                return "Research"
            elseif string.find(value, "foundation enforcement", 1, true) or string.find(value, "f.e.", 1, true) or string.find(value, "fe", 1, true) then
                return "FE"
            elseif string.find(value, "security", 1, true) then
                return "Security"
            end
        end
    end

    return nil
end

function RefreshFoundationTeamTables()
    for groupName, teamList in pairs(FoundationTeamTables) do
        table.Empty(teamList)
        FoundationTeamLookup[groupName] = FoundationTeamLookup[groupName] or {}
        table.Empty(FoundationTeamLookup[groupName])
    end

    for teamIndex, _ in pairs(RPExtraTeams or {}) do
        local groupName = GetFoundationTeamGroup(teamIndex)
        local teamList = groupName and FoundationTeamTables[groupName]
        local teamLookup = groupName and FoundationTeamLookup[groupName]

        if teamList and teamLookup and not teamLookup[teamIndex] then
            table.insert(teamList, teamIndex)
            teamLookup[teamIndex] = true
        end
    end

    return FoundationTeamTables
end

local function IsFoundationTeamInGroup(teamOrPlayer, groupName)
    local teamIndex = ResolveFoundationTeamIndex(teamOrPlayer)
    if not teamIndex then return false end

    RefreshFoundationTeamTables()

    local teamLookup = FoundationTeamLookup[groupName]
    if teamLookup and teamLookup[teamIndex] then
        return true
    end

    local teamList = FoundationTeamTables[groupName]
    return teamList and table.HasValue(teamList, teamIndex) or false
end

function IsMTFTeam(teamOrPlayer)
    return IsFoundationTeamInGroup(teamOrPlayer, "MTF")
end

function IsResearchTeam(teamOrPlayer)
    return IsFoundationTeamInGroup(teamOrPlayer, "Research")
end

function IsFETeam(teamOrPlayer)
    return IsFoundationTeamInGroup(teamOrPlayer, "FE")
end

function IsSecurityTeam(teamOrPlayer)
    return IsFoundationTeamInGroup(teamOrPlayer, "Security")
end

timer.Simple(0, function()
    if RefreshFoundationTeamTables then
        RefreshFoundationTeamTables()
    end
end)