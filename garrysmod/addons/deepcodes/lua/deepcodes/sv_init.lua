local resource = resource

for code,_ in pairs(DeepCodes.Codes) do
    resource.AddFile("materials/deepcodes/code_"..code..".png")
end

hook.Add("PlayerSay", "DeepCodes.CommandHandler", function(ply,strMsg,bTeamChat)
    timer.Simple(0, function()
        if not string.StartWith(strMsg, "!code ") then return end

        local team = team.GetName(ply:Team())

        if not DeepCodes.Jobs[team] and not DeepCodes.AdminGroups[ply:GetUserGroup()] then return end

        local space = string.find(strMsg, " ", 1) + 1

        local code = string.sub(strMsg, space)
        code = string.lower(code)

        if not DeepCodes.Codes[code] then return end

        local oldScreens = ents.FindByName("code_" .. DeepCodes.CurrentCode)

        for _,screen in ipairs(oldScreens) do
            screen:Fire("Disable")
        end

        DeepCodes.CurrentCode = code

        local newScreens = ents.FindByName("code_" .. code)

        for _,screen in ipairs(newScreens) do
            screen:Fire("Enable")
        end

        DeepCodes.LastCodeChange = CurTime()

        net.Start("DeepCodes.SendCode")
            net.WriteString(DeepCodes.CurrentCode)
            net.WriteString(DeepCodes.DBlock)
            net.WriteFloat(DeepCodes.LastCodeChange)
            net.WriteFloat(DeepCodes.LastDBlockChange)
        net.Broadcast()
    end )

end )

hook.Add("PlayerSay", "DeepCodes.DBlock", function(ply,strMsg,bTeamChat)
    timer.Simple(0, function()
        if not string.StartWith(strMsg, "!dblock ") then return end

        local team = team.GetName(ply:Team())

        if not DeepCodes.DBJobs[team] and not DeepCodes.AdminGroups[ply:GetUserGroup()] then return end

        local space = string.find(strMsg, " ", 1) + 1

        local code = string.sub(strMsg, space)
        code = string.lower(code)

        if not DeepCodes.DBlockCodes[code] then return end

        DeepCodes.DBlock = code

        DeepCodes.LastDBlockChange = CurTime()

        net.Start("DeepCodes.SendCode")
            net.WriteString(DeepCodes.CurrentCode)
            net.WriteString(DeepCodes.DBlock)
            net.WriteFloat(DeepCodes.LastCodeChange)
            net.WriteFloat(DeepCodes.LastDBlockChange)
        net.Broadcast()
    end )

end )

MsgC("[Deep Codes]",DeepCodes.Success, " Serverside initialized.\n") -- EOF