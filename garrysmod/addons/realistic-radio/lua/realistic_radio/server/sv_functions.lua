/*
    Addon id: 2bab5356-b4ae-4c4d-acb8-e199f204bd54
    Version: v1.3.8 (stable)
*/

local RDOMeta = FindMetaTable("Player")

-- Check if the player is on a base frequency if yes he can't change his frequency but only change the dispatch 
-- Like for the 911 ( Police can just change the number next the frequency 911.0, 911.1 ...)
function RDOMeta:CheckBaseFrequency()
    local Result = false 
    for k,v in pairs(Realistic_Radio.BaseFrequencies) do
        if not Realistic_Radio.SecureFrequencyChange then
            if v.Team[team.GetName(self:Team())] then 
                Result = true
            end
        end
    end

    return Result
end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 5fa1e6df5fd1b55cf2f6f5dfb9364c1e6615d258fcc9159a1c9ab64208e71c95 */

-- Give the radio if the job of the player is on the base frequencies 
function RDOMeta:GiveRadio()
    for k,v in pairs(Realistic_Radio.BaseFrequencies) do 
        if v.Team[team.GetName(self:Team())] then 
            self:Notification(Realistic_Radio.GetSentence("help"), 10)
            self:Give("weapon_rdo_radio")
            self:SelectWeapon("weapon_rdo_radio")
            break
        end 
    end 
end 

-- Send Informations about the radio 
function RDOMeta:SendInformations()
    if not self.RDOTable then return end 
    net.Start("RDO:SetFrequencies")
        net.WriteTable(self.RDOTable)
    net.Send(self)
end 

-- Set the radio Frequency of the player
function RDOMeta:SetFrequency(Freq, Dispatch)
    if not self.RDOTable then self.RDOTable = {} end 
    if not isnumber(Freq) then return end 
    if not isnumber(Dispatch) then Dispatch = 0 end 
    if Dispatch < 0 or Dispatch > 9 then return end 
    if Freq < 0 or Freq > Realistic_Radio.MaxFrequencies then return end 

    self.RDOTable["Freq"] = Freq
    self.RDOTable["Dispatch"] = Dispatch
    self.RDOTable["Mute"] = true

    self:SetNWFloat("rdo_frequency", ((self.RDOTable["Freq"] + self.RDOTable["Dispatch"]/10) or 0.0))
    self:SendInformations()

    timer.Simple(0, function()
        if IsValid(self) && self:IsPlayer() then 
            net.Start("RDO:SecureFrequencies")
                net.WriteUInt(self:CanHearPlayer() and 5 or 4, 5)
            net.Send(self)
        end 
    end ) 
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 1d139e0850450ff0c55cc5ad19568a0794d4d3bdce3fa3d34f714425a4e44079 */

-- Change Settings Like Mute, Sound, Radio On or Off, 
function RDOMeta:ChangeSettings(String)
    if not self.RDOTable then self.RDOTable = {} end 

    if self.RDOTable[String] then 
        if String == "StopSound" then 
            self:Notification(Realistic_Radio.GetSentence("offStopSound"), 10)
        elseif String == "Mute" then 
            self:Notification(Realistic_Radio.GetSentence("unmutenotify"), 10)
        end 
        self.RDOTable[String] = false  
    else 
        if String == "StopSound" then 
            self:Notification(Realistic_Radio.GetSentence("mutesoundnotify"), 10)
        elseif String == "Mute" then 
            self:Notification(Realistic_Radio.GetSentence("mutenotify"), 10)
        end 
        self.RDOTable[String] = true  
    end 
    self:SendInformations()
end     

-- Get the frequencies of the player
function RDOMeta:GetFrequencies()
    self.RDOTable = self.RDOTable or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 62b35ce3a02dafbf5bb97998ac5e1886a97ed5d0e48e20b97ca269692c124a07

    return (self.RDOTable["Freq"] or 0) 
end 

-- Get Dispatch for the DefaultFrequency 
function RDOMeta:GetDispatch()
    self.RDOTable = self.RDOTable or {}

    return (self.RDOTable["Dispatch"] or 0)
end 

-- Create a Secury Frequency with a password 
function RDOMeta:CreateSecureFrequency(Freq, Password)
    if not self.RDOTable then self.RDOTable = {} end 
    if not isnumber(Freq) then return end 
    if self:CheckBaseFrequency() then self:Notification(Realistic_Radio.GetSentence("cantcreatesecure1"), 10) return end

    if Freq == 0 then self:Notification(Realistic_Radio.GetSentence("frequencyno0"), 10) return end 
    if Realistic_Radio.FreqIsSecure(Freq) then self:Notification(Realistic_Radio.GetSentence("alreadysecure"), 10) return end 
    if Realistic_Radio.GetAllPlayersInFreq(Freq) > 0 then self:Notification(Realistic_Radio.GetSentence("cancreatesecurefreq"), 10) return end 
    if #Realistic_Radio.GetAllSecureFreq() >= Realistic_Radio.MaxSecureFrequency then self:Notification(Realistic_Radio.GetSentence("toomuchsecure"), 10) return end 

    self:RemoveSecureFrequency()
    self:LeaveSecureFrequency()

    self.RDOTable["SecureFrequency"] = {
        ["Freq"] = Freq, 
        ["Password"] = Password, 
        ["Players"] = {},  
    }
    self:SetFrequency(Freq)
    
    -- Send to all player the table of all secure frequency
    Realistic_Radio.SendAllSecureFreq(2, self)
end 

-- Remove a secure Frequency of a player 
function RDOMeta:RemoveSecureFrequency()
    if not self.RDOTable then self.RDOTable = {} end 
    if not self.RDOTable["SecureFrequency"] then return end 
    
    -- Reset the frequence of all player into the Secure Frequency
    if self.RDOTable["SecureFrequency"] then 
        if self.RDOTable["SecureFrequency"]["Players"] then 
            for k,v in pairs(self.RDOTable["SecureFrequency"]["Players"]) do 
                if IsValid(v) then 
                    v:SetFrequency(0)
                end 
            end 
        end 
        self.RDOTable["SecureFrequency"] = nil 
        Realistic_Radio.SendAllSecureFreq(1, self)
    end 
end

-- Join a secure frequency if the password is correct 
function RDOMeta:JoinSecureFrequency(RPlayer, Password)
    if self:CheckBaseFrequency() then self:Notification(Realistic_Radio.GetSentence("cantjoinfreq"), 10) return end
    if not IsValid(RPlayer) or not RPlayer:IsPlayer() then return end 
    if not RPlayer.RDOTable then RPlayer.RDOTable = {} end 
    if not RPlayer.RDOTable["SecureFrequency"] then return end 
    if self == RPlayer then self:Notification(Realistic_Radio.GetSentence("cantjoinyoursecure"), 10) return end 

    if Password == RPlayer.RDOTable["SecureFrequency"]["Password"] then 
        -- Leave the before frequency
        self:RemoveSecureFrequency()
        self:LeaveSecureFrequency()

        if not RPlayer.RDOTable["SecureFrequency"] then self:SetFrequency(0) return end 
        RPlayer.RDOTable["SecureFrequency"]["Players"][#RPlayer.RDOTable["SecureFrequency"]["Players"] + 1] = self
        self:SetFrequency(RPlayer.RDOTable["SecureFrequency"]["Freq"])
        self.RDOTable["PlayerSecure"] = RPlayer

        self:Notification(Realistic_Radio.GetSentence("joinedfrequency").." "..RPlayer.RDOTable["SecureFrequency"]["Freq"].." mhz", 10)
        RPlayer:Notification(self:GetName().." "..Realistic_Radio.GetSentence("joinedyour").." ( "..RPlayer.RDOTable["SecureFrequency"]["Freq"].." mhz )", 10)
        
        -- Reset and send the table to the player
        net.Start("RDO:SecureFrequencies")
            net.WriteUInt(2, 5)
            net.WriteTable(Realistic_Radio.GetAllSecureFreq(self))
        net.Send(self)
    else 
        self:Notification(Realistic_Radio.GetSentence("passwordfailed"), 10)

        -- Just reset the menu of the radio because the password is wrong
        net.Start("RDO:SecureFrequencies")
            net.WriteUInt(3, 5)
        net.Send(self)
    end 
end 

-- Leave the Secure Frequency 
function RDOMeta:LeaveSecureFrequency()
    if not self.RDOTable then self.RDOTable = {} end
    
    if self.RDOTable["PlayerSecure"] && self.RDOTable["PlayerSecure"].RDOTable["SecureFrequency"] && self.RDOTable["PlayerSecure"].RDOTable["SecureFrequency"]["Players"] then 
        for k,v in pairs(self.RDOTable["PlayerSecure"].RDOTable["SecureFrequency"]["Players"]) do 
            if v == self then 
                self.RDOTable["PlayerSecure"].RDOTable["SecureFrequency"]["Players"][k] = nil 
                self.RDOTable["PlayerSecure"] = nil 
            end 
        end 
    end 
end

-- Send all Secure frequency to all player with just the password of his frequency
function Realistic_Radio.SendAllSecureFreq(Uint, RPlayer)   
    for k,v in pairs(player.GetAll()) do 
        if IsValid(v) && v:IsPlayer() then 
            net.Start("RDO:SecureFrequencies")
                net.WriteUInt((RPlayer == v) and 2 or 1, 5)
                net.WriteTable(Realistic_Radio.GetAllSecureFreq(v))
            net.Send(v)
        end 
    end 
end 

-- Send all Secure Frequency to one player 
function RDOMeta:SendPlayerSecureFreq()
    net.Start("RDO:SecureFrequencies")
        net.WriteUInt(1, 5)
        net.WriteTable(Realistic_Radio.GetAllSecureFreq(self))
    net.Send(self)
end 

-- If the player can Hear the Talker
function RDOMeta:CanHearPlayer()
    local CanHear = false 
    if Realistic_Radio.FreqIsSecure(self:GetFrequencies()) then 
        -- Check if he is able to hear in the Default frequency 
        for k,v in pairs(Realistic_Radio.BaseFrequencies) do 
            if Realistic_Radio.BaseFrequencies[k]["Team"][team.GetName(self:Team())] && Realistic_Radio.BaseFrequencies[k]["Frequency"] == self:GetFrequencies() then 
                CanHear = true 
            end 
        end  
        -- Check if the player joined with the password the secure frequency
        for k,v in pairs(Realistic_Radio.GetAllSecureFreq(self)) do 
            if v.Freq == self:GetFrequencies() then 
                if table.HasValue(Realistic_Radio.GetAllSecureFreq(self)[k]["Players"], self) or Realistic_Radio.GetAllSecureFreq(self)[k]["Owner"] == self then 
                    CanHear = true 
                end 
            end 
        end 
    else 
        CanHear = true 
    end 
    return CanHear
end 

-- Get All secure frequencies created by players
function Realistic_Radio.GetAllSecureFreq(RPlayer)
    local SecureTable = {}
    for k,v in pairs(player.GetAll()) do
        v.RDOTable = v.RDOTable or {}
        
        if v.RDOTable["SecureFrequency"] && isnumber(v.RDOTable["SecureFrequency"]["Freq"]) then 
            SecureTable[#SecureTable + 1] = {
                ["Owner"] = v, 
                ["Freq"] = v.RDOTable["SecureFrequency"]["Freq"],
                ["Password"] = (RPlayer == v) and v.RDOTable["SecureFrequency"]["Password"] or "", 
                ["Players"] = v.RDOTable["SecureFrequency"]["Players"], 
            }
        end 
    end 
    return SecureTable
end 

-- Get the Base frequency of the Job ( like 911 for the police )
function Realistic_Radio.GetBaseFrequency(Team) 
    local Freq, Dispatch = 0, 0 
    for k,v in pairs(Realistic_Radio.BaseFrequencies) do 
        if Realistic_Radio.BaseFrequencies[k]["Team"][Team] then 
            Freq = Realistic_Radio.BaseFrequencies[k]["Frequency"]
            Dispatch = (isnumber(Dispatch) && Dispatch >= 0 && Dispatch <= 9) and Realistic_Radio.BaseFrequencies[k]["Dispatch"] or 0 
            break 
        end 
    end 
    return Freq, Dispatch
end

function Realistic_Radio.GetAllBaseFrequencies(Team)
    local frequencies, count, firstToJoin = {}, 0, nil
    for k, v in pairs(Realistic_Radio.BaseFrequencies) do 
        if Realistic_Radio.BaseFrequencies[k]["Team"][Team] then
            Freq = Realistic_Radio.BaseFrequencies[k]["Frequency"]
            Dispatch = (isnumber(Dispatch) && Dispatch >= 0 && Dispatch <= 9) and Realistic_Radio.BaseFrequencies[k]["Dispatch"] or 0
            
            frequencies[Freq] = {
                ["Freq"] = Freq,
                ["Dispatch"] = Dispatch,
            }
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199123350945
            
            if not istable(firstToJoin) then
                firstToJoin = frequencies[Freq]
            end

            count = count + 1
        end
    end

    return frequencies, count, firstToJoin
end

-- Check if the Frequency is secure or not 
function Realistic_Radio.FreqIsSecure(Freq)
    local SecureFrequency = {}
    for k,v in pairs(Realistic_Radio.BaseFrequencies) do 
        SecureFrequency[#SecureFrequency + 1] = v.Frequency
    end 
    for k,v in pairs(Realistic_Radio.GetAllSecureFreq()) do 
        if v.Freq == Freq then 
            SecureFrequency[#SecureFrequency + 1] = v.Freq
        end 
    end 
    return table.HasValue(SecureFrequency, Freq)
end 

function Realistic_Radio.GetAllPlayersInFreq(Freq)
    local Number = 0 
    for k,v in pairs(player.GetAll()) do 
        if v:GetFrequencies() == Freq then 
            Number = Number + 1 
        end 
    end 
    return Number 
end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c750873a37e0a75f99a502a9e5939b02f1b88b5df95e9c2b5c42581a8e324e05

-- Create a notification
function RDOMeta:Notification(msg, time)
    local TableNotification = {
        ["message"] = msg, 
        ["time"] = time, 
    }
    net.Start("Kobralost:Notifications")
        net.WriteTable(TableNotification)
    net.Send(self)
end 
