/*
    Addon id: 2bab5356-b4ae-4c4d-acb8-e199f204bd54
    Version: v1.3.8 (stable)
*/

util.AddNetworkString("RDO:SetFrequencies")
util.AddNetworkString("RDO:SecureFrequencies")
util.AddNetworkString("RDO:Other")
util.AddNetworkString("Kobralost:Notifications")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 5fa1e6df5fd1b55cf2f6f5dfb9364c1e6615d258fcc9159a1c9ab64208e71c95 */

net.Receive("RDO:SetFrequencies", function(len, ply)
    ply.RDOAntiSpam = ply.RDOAntiSpam or CurTime()
    if ply.RDOAntiSpam > CurTime() then return end 
    ply.RDOAntiSpam = CurTime() + 0.1
    
    local UInt = net.ReadUInt(5)

    if UInt == 1 then 
        -- Read the Frequencies of the Radio 
        local Freq = net.ReadUInt(32)
        local Dispatch = net.ReadUInt(32)
        
        ply:RemoveSecureFrequency()
        ply:LeaveSecureFrequency()
        ply:SetFrequency(Freq, Dispatch)

    elseif UInt == 2 then 
        -- Change Settings of the Radio 
        local String = net.ReadString() 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 1d139e0850450ff0c55cc5ad19568a0794d4d3bdce3fa3d34f714425a4e44079 */

        ply:ChangeSettings(String)
    end 
end )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 5fa1e6df5fd1b55cf2f6f5dfb9364c1e6615d258fcc9159a1c9ab64208e71c95

net.Receive("RDO:SecureFrequencies", function(len,ply)
    ply.RDOAntiSpam = ply.RDOAntiSpam or CurTime()
    if ply.RDOAntiSpam > CurTime() then return end 
    ply.RDOAntiSpam = CurTime() + 0.1
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c750873a37e0a75f99a502a9e5939b02f1b88b5df95e9c2b5c42581a8e324e05

    local UInt = net.ReadUInt(5)
    
    if UInt == 1 then 
        -- Create the Secure Frequency 
        local Freq = net.ReadUInt(32)
        local Password = net.ReadString()

        ply:CreateSecureFrequency(Freq, Password)

    elseif UInt == 2 then 
        -- Join a Secure Frequency 
        local RPlayer = net.ReadEntity()
        local Password = net.ReadString()

        ply:JoinSecureFrequency(RPlayer, Password)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350968

    elseif UInt == 3 then 
        -- Send all secure frequencies to the player
        ply:SendPlayerSecureFreq()
    end 
end )
