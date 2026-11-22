-- psych_eval/data.lua
hook.Add("Initialize", "PsychEval_LoadData", function()
    PsychEval.LoadEvals()
end)

-- optional: save on shutdown
hook.Add("ShutDown", "PsychEval_SaveData", function()
    PsychEval.SaveEvals()
end)