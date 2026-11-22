local OBJ = RDV.TRAINING.Add()

OBJ:SetName("Security Department") -- Name of the quiz.

OBJ:SetImage("") -- Cover photo. (Optional)

OBJ:SetTeam({TEAM_SECCDT}) -- Team to set the player to (or whitelist if you have BWhitelist installed.)

OBJ:SetPass(100)

OBJ:SetOpenWithF4(true) -- Should attempting to become the job in the F4 menu automatically open the quiz? (No Need for the NPC.)

OBJ:SetLevel(0) -- Set Level Requirement (Nicolas's Level System) (Optional)

OBJ:SetDelay(60) -- 360 Seconds between delay. (Optional)

-- Supported Rank Addons: Nicolas's Rank System, Mac's Rank System
-- OBJ:SetRankRequirement({ -- Branch Name, Rank #
--     ["Test"] = 2, -- Rank #, anything at or above this rank number will have access to this quiz.
-- })

OBJ:AddQuestion("An SCP classified as Euclid has breached containment in a lower-level corridor. Two unarmed researchers are trapped behind a security door, while the entity is roaming nearby. Backup is 2 minutes out. What do you do?", {
    {
        Answer = "Immediately open the door and escort the researchers out.",
        Correct = false,
    },
    {
        Answer = "Hold the position and wait for backup before acting.",
        Correct = false,
    },
    {
        Answer = "Attempt to lure the SCP away, then extract the researchers",
        Correct = true,
    },
    {
        Answer = "Ignore the researchers and focus on recontainment",
        Correct = false,
    },
})

OBJ:AddQuestion("A senior researcher refuses to compply with a lockdown order, insisting their experiment is 'too important to stop.' What do you do?", {
    {
        Answer = "Allow them to continue due to rank.",
        Correct = false,
    },
    {
        Answer = "Physically detain them and enforce lockdown procedures",
        Correct = true,
    },
    {
        Answer = "Ignore the situation.",
        Correct = false,
    },
    {
        Answer = "Argue until they comply.",
        Correct = false,
    },
})

OBJ:AddQuestion("A personnel member approaches a checkpoint but is behaving erratically and fails to properly identify themselves. This occurs shortly after a containment breach involving a mimic-type SCP. What do you do?", {
    {
        Answer = "Immediately terminate the individual",
        Correct = false,
    },
    {
        Answer = "Allow entry to avoid conflict.",
        Correct = false,
    },
    {
        Answer = "Detain the Individual and request verification",
        Correct = true,
    },
    {
        Answer = "Ignore the irregularities",
        Correct = false,
    },
})

OBJ:AddQuestion("A Class-D Subject refuses orders during testing and begins verbally escalating but has not yet become physically agressive. What do you do?", {
    {
        Answer = "Immediately use lethal force.",
        Correct = false,
    },
    {
        Answer = "Attempt verbal de-escalation, escalating force only if necessary",
        Correct = true,
    },
    {
        Answer = "Ignore the subject",
        Correct = false,
    },
    {
        Answer = "Release the subject from custody",
        Correct = false,
    },
})


OBJ:CustomCheck(function(ply)
end )

OBJ:OnPass(function(ply)
end )

OBJ:Register()