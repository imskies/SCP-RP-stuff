/*
    Addon id: 2bab5356-b4ae-4c4d-acb8-e199f204bd54
    Version: v1.3.8 (stable)
*/

local InfosPlayers = {}
timer.Create("rdo_voicedelay", 1, 0, function()
    for k,v in pairs(player.GetAll()) do
        local firstFreq = v:GetFrequencies()

        local Freq = (firstFreq..v:GetDispatch())
        local CanHear = (firstFreq == 0 and false or v:CanHearPlayer())
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350968 */

        v.RDOTable = v.RDOTable or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350968 */

        InfosPlayers[v:SteamID64()] = {
            ["InfosFreq"] = Freq,
            ["CanTalk"] = (v:HasWeapon("weapon_rdo_radio") && firstFreq != 0 && v.RDOTable["Statut"] && not v.RDOTable["StopSound"] && CanHear),
            ["CanHearPlayer"] = CanHear,
        }
    end
end)

local function canHear(listener, talker)
    if not IsValid(talker) or not IsValid(listener) then return end

    local TalkerId, ListenerId = talker:SteamID64(), listener:SteamID64()
    if InfosPlayers && InfosPlayers[TalkerId] && InfosPlayers[ListenerId] && InfosPlayers[ListenerId]["CanTalk"] then
        talker.RDOTable = talker.RDOTable or {}

        if not talker.RDOTable["Mute"] && (InfosPlayers[ListenerId]["InfosFreq"] == InfosPlayers[TalkerId]["InfosFreq"]) && InfosPlayers[TalkerId]["CanHearPlayer"] then
            return true
        end
    end
end
hook.Add("PlayerCanHearPlayersVoice", "RDO:PlayerCanHearPlayersVoice", canHear)

local function voiceboxCanHear(listener, talker)
    if not IsValid(talker) or not IsValid(listener) then return end

    local TalkerId, ListenerId = talker:SteamID64(), listener:SteamID64()
    if InfosPlayers && InfosPlayers[TalkerId] && InfosPlayers[ListenerId] && InfosPlayers[ListenerId]["CanTalk"] then

        talker.RDOTable = talker.RDOTable or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350968 */
        
        if not talker.RDOTable["Mute"] && (InfosPlayers[ListenerId]["InfosFreq"] == InfosPlayers[TalkerId]["InfosFreq"]) && InfosPlayers[TalkerId]["CanHearPlayer"] then
            VoiceBox.FX.IsRadioComm(listener:EntIndex(), talker:EntIndex(), not VoiceBox.FX.__PlayerCanHearPlayersVoice(listener, talker))
            return true
        end
    end

	VoiceBox.FX.IsRadioComm(listener:EntIndex(), talker:EntIndex(), false)
end
if VoiceBox && VoiceBox.FX then
	hook.Add("PlayerCanHearPlayersVoice", "RDO:PlayerCanHearPlayersVoice", voiceboxCanHear)
else
	hook.Add("VoiceBox.FX", "RDO", function()
		hook.Add("PlayerCanHearPlayersVoice", "RDO:PlayerCanHearPlayersVoice", voiceboxCanHear)
	end)
end

hook.Add("PlayerDisconnected", "RDO:PlayerDisconnected", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    ply:RemoveSecureFrequency()
    ply:LeaveSecureFrequency()
end )

hook.Add("PlayerDeath", "RDO:PlayerDeath", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    if Realistic_Radio.SaveFrequencyOnDeath then return end

    ply:RemoveSecureFrequency()
    ply:LeaveSecureFrequency()
    ply:SetFrequency(0,0)
end )

hook.Add( "PlayerChangedTeam", "RDO:PlayerChangedTeam", function( ply, oldTeam, newTeam )
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local teamName = team.GetName(newTeam)
    local frequencies, count, firstToJoin = Realistic_Radio.GetAllBaseFrequencies(teamName)
    if not istable(frequencies) or not isnumber(count) or not istable(firstToJoin) then return end

    if count <= 0 then return end

    local freqToJoin = frequencies[Realistic_Radio.SetFrenquencyByJob[teamName]]
    if not istable(freqToJoin) then
        freqToJoin = firstToJoin
    end

    local Freq = freqToJoin["Freq"]
    local Dispatch = freqToJoin["Dispatch"]

    if not isnumber(Freq) or not isnumber(Dispatch) then return end
    if Freq == 0 && Dispatch == 0 then return end
    
    ply:RemoveSecureFrequency()
    ply:LeaveSecureFrequency()
    ply:SetFrequency(Freq, Dispatch)

    timer.Simple(0,function()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        ply:GiveRadio()
    end)
end )

hook.Add( "PlayerSpawn", "RDO:PlayerSpawn", function( ply )
    timer.Simple(0, function()
        local teamName = team.GetName(ply:Team())
        local frequencies, count, firstToJoin = Realistic_Radio.GetAllBaseFrequencies(teamName)
        if count <= 0 then return end

        local freqToJoin = frequencies[Realistic_Radio.SetFrenquencyByJob[teamName]]
        if not istable(freqToJoin) then
            freqToJoin = firstToJoin
        end

        local Freq = freqToJoin["Freq"]
        local Dispatch = freqToJoin["Dispatch"]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 76561199123350945 */

        if not isnumber(Freq) or not isnumber(Dispatch) then return end
        if Freq == 0 && Dispatch == 0 then return end
        
        ply:RemoveSecureFrequency()
        ply:LeaveSecureFrequency()
        ply:SetFrequency(Freq, Dispatch)
        ply:GiveRadio()
    end)
end)

hook.Add("PlayerInitialSpawn", "RDO:PlayerInitialSpawn", function( ply )
    timer.Simple(3, function()
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if not istable(ply.RDOTable) then ply.RDOTable = {} end
        -- Debug a litle problem with the table of the radio
        ply.RDOTable["Statut"] = true
                                                                                                                                                                                                                                                                                                                                                                                                                                                       /* 90c45c83c06fd45965c506b0a40f9bf317f89c91d0aae2aa014fd2a772e64796 */

        InfosPlayers[ply:SteamID64()] = {
            ["InfosFreq"] = 0,
            ["HasRadio"] = false,
            ["CanHearPlayer"] = false,
        }
    end)
end)

hook.Add("PlayerSay", "RDO:PlayerSay", function( ply, text )
    local String = string.Explode(" ", text)
	if String[1] == Realistic_Radio.CommandChat && ply:CanHearPlayer(ply:GetFrequencies()) && ply:HasWeapon("weapon_rdo_radio") && tonumber(ply:GetFrequencies()..ply:GetDispatch()) != 0 then
        for k,v in pairs(player.GetAll()) do
            if v:CanHearPlayer(v:GetFrequencies()) && tonumber(v:GetFrequencies()..v:GetDispatch()) == tonumber(ply:GetFrequencies()..ply:GetDispatch()) then
                net.Start("RDO:Other")
                    net.WriteUInt(1, 5)
                    net.WriteString(string.Replace(text, Realistic_Radio.CommandChat, ""))
                    net.WriteEntity(ply)
                net.Send(v)
            end
        end
        return ""
    elseif String[1] == Realistic_Radio.CommandTutorial then
        net.Start("RDO:Other")
            net.WriteUInt(2, 5)
        net.Send(ply)
        return ""
    elseif String[1] == Realistic_Radio.KeysCommand then
        net.Start("RDO:Other")
            net.WriteUInt(3, 5)
        net.Send(ply)
        return ""
	end
end)
