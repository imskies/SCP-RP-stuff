hook.Add("InitPostEntity", "DeepCodes.RecieveLatestCode", function()
    DeepCodes.joining = true

    net.Start("DeepCodes.RequestCode")
    net.WriteFloat(CurTime())
    net.SendToServer()

end )

net.Receive("DeepCodes.SendCode", function()
    local code = net.ReadString()
    code = string.upper(code[1])..string.sub(code,2,string.len(code)) -- refactored capitalization : chen
    local dbCode = net.ReadString()
    local codeTime = net.ReadFloat()
    local dbCodeTime = net.ReadFloat()

    -- if this ^^^ was causing known bugs and was intentionally in the if statment you can put it back but players get will only code green when they join : chen
    -- VV i also had to remove and DeepCodes.code ~= code to make it work too;
    
    if not DeepCodes.joining && DeepCodes.code ~= code && DeepCodes.code ~= "a-d" && DeepCodes.code ~= "lost" then
        surface.PlaySound("code/code_"..string.lower(code)..".wav") -- plays sound files (duh) : chen
    end
	
    DeepCodes.code = code
    DeepCodes.DBlock = DeepCodes.DBlockCodes[dbCode]
    if codeTime > 0.5 then -- avoiding floating point imprecision problems ie 0.00002
        DeepCodes.LastCodeChange = codeTime
    end
    if dbCodeTime > 0.5 then
        DeepCodes.LastDBlockChange = dbCodeTime
    end
    DeepCodes.joining = false
end )