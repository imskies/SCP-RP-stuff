local OBJ = RDV.TRAINING.Add()

OBJ:SetName("Engineering Department") -- Name of the quiz.

OBJ:SetImage("") -- Cover photo. (Optional)

OBJ:SetTeam({TEAM_CITYWORKER}) -- Team to set the player to (or whitelist if you have BWhitelist installed.)

OBJ:SetPass(80)

OBJ:SetOpenWithF4(true) -- Should attempting to become the job in the F4 menu automatically open the quiz? (No Need for the NPC.)

OBJ:SetLevel(0) -- Set Level Requirement (Nicolas's Level System) (Optional)

OBJ:SetDelay(300) -- 360 Seconds between delay. (Optional)

-- Supported Rank Addons: Nicolas's Rank System, Mac's Rank System
-- OBJ:SetRankRequirement({ -- Branch Name, Rank #
--     ["Test"] = 2, -- Rank #, anything at or above this rank number will have access to this quiz.
-- })

OBJ:AddQuestion("What's 9+10?", {
    {
        Answer = "21",
        Correct = false,
    },
    {
        Answer = "19",
        Correct = true,
    },
    {
        Answer = "4",
        Correct = false,
    },
})

OBJ:AddQuestion("What's funnier than 24?", {
    {
        Answer = "25",
        Correct = true,
    },
    {
        Answer = "7",
        Correct = false,
    },
    {
        Answer = "12",
        Correct = false,
    },
})


OBJ:CustomCheck(function(ply)
end )

OBJ:OnPass(function(ply)
end )

OBJ:Register()