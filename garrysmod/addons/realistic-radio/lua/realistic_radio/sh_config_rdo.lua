/*
    Addon id: 2bab5356-b4ae-4c4d-acb8-e199f204bd54
    Version: v1.3.8 (stable)
*/

Realistic_Radio = Realistic_Radio or {}
Realistic_Radio.BaseFrequencies = Realistic_Radio.BaseFrequencies or {}

Realistic_Radio.Lang = "en" -- Langage of the Addon ( en, fr, pl, tr, ru, cn, de )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

Realistic_Radio.RadioTheme = "darktheme" -- Theme of the Radio ( darktheme / lighttheme )

Realistic_Radio.MaxFrequencies = 999 -- Max frequencies

Realistic_Radio.UseCustomNotify = true -- Do you want to use custom Notify 

Realistic_Radio.MaxSecureFrequency = 50 -- Max Secure frequency for all player
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 62b35ce3a02dafbf5bb97998ac5e1886a97ed5d0e48e20b97ca269692c124a07 */

Realistic_Radio.SeePlayerName = true -- Can see player name when a person talk 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350968 */

Realistic_Radio.KeyMute = KEY_P -- This is the key for mute your microphone

Realistic_Radio.KeyNoSound = KEY_G -- This is the key for mute the sound

Realistic_Radio.CommandChat = "/r" -- The command for talk on the chat in the frequency

Realistic_Radio.CommandTutorial = "/rdo" -- The command for open the tutorial menu of the radio 

Realistic_Radio.KeysCommand = "/rdokeys" -- Command for open the keys settings 

Realistic_Radio.ColorTextFreq = Color(231, 76, 60) -- Color of the Start of the text 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 1d139e0850450ff0c55cc5ad19568a0794d4d3bdce3fa3d34f714425a4e44079 */

Realistic_Radio.ColorTextMessage = Color(211, 84, 0) -- Color of the message 

Realistic_Radio.PosXY = {0.88, 0} -- Position X, Y of the menu 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c750873a37e0a75f99a502a9e5939b02f1b88b5df95e9c2b5c42581a8e324e05

Realistic_Radio.HUDPosition = false -- true == left or false ==right rotation 

Realistic_Radio.SaveFrequencyOnDeath = True -- Does frequency is saved when you death

Realistic_Radio.DisableSound = false -- Disable sound when you talk

Realistic_Radio.ChanelName = {
    [911] = "Civil Protection", 
}

Realistic_Radio.SecureFrequencyChange = false -- Enable people in base frequencies can switch to standar frequencies

Realistic_Radio.BaseFrequencies[1] = { -- You can create a base frequency for a job 
    ["Frequency"] = 911, 
    ["Dispatch"] = 1, 
    ["Team"] = {
        ["Civil Protection"] = true,
        ["Civil Protection Chief"] = true, 
    }
}

Realistic_Radio.BaseFrequencies[2] = { -- You can create a base frequency for a job 
    ["Frequency"] = 912, 
    ["Dispatch"] = 1, 
    ["Team"] = {
        ["Civil Protection"] = true,
        ["Civil Protection Chief"] = true, 
    }
}

-- Realistic_Radio.BaseFrequencies[2] = { -- You can create a base frequency for a job 
--     ["Frequency"] = 10, 
--     ["Dispatch"] = 0, 
--     ["Team"] = {
--         ["Civil Protection"] = true,
--         ["Civil Protection Chief"] = true,
--     }
-- }

Realistic_Radio.SetFrenquencyByJob = {
    -- ["Civil Protection"] = 10
}
