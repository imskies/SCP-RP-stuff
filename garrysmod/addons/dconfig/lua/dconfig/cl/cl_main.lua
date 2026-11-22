
net.Receive("dconfig2_open", function()
    DCONFIG2.Open()
end)

hook.Add("InitPostEntity", "DConfig2RequestDefaultData", function()
    if not DCONFIG2.CanDConfig(LocalPlayer()) then return end

    net.Start("dconfig2_requestDefaultData")
    net.SendToServer()
end)

net.Receive("dconfig2_requestDefaultData", function()
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
	local formattedData = util.JSONToTable(util.Decompress(compressedData))
    for k,v in ipairs(formattedData) do
        RPExtraTeams[k].jobvar = v.jobvar
        RPExtraTeams[k].customCheckString = v.customCheckString
        RPExtraTeams[k].inLuaFile = true
    end
end)

net.Receive("dconfig2_sendPopup", function()
    local msg = net.ReadString()
    local icon = net.ReadString()
    local seconds = net.ReadUInt(8)
    local isError = net.ReadBool()
    DCONFIG2.ShowPopup(msg, icon, seconds, isError)
end)

net.Receive("dconfig2_sendText", function()
    local msg = net.ReadString()
    local theme = DCONFIG2.GetTheme()
    chat.AddText(theme.theme,"[DCONFIG 2] ", color_white, msg)
end)

local blur = Material( "pp/blurscreen" )
function DCONFIG2.BlurMenu( panel, layers, density, alpha )
    -- Its a scientifically proven fact that blur improves a script
    local x, y = panel:LocalToScreen( 0, 0 )

    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( blur )

    for i = 1, 5 do
        blur:SetFloat( "$blur", ( i / 4 ) * 4 )
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
    end
end

function DCONFIG2.PaintScrollBar(sbar)
    local theme = DCONFIG2.GetTheme()
    local barClr = theme.scrollbackground
    local bar = sbar:GetVBar()

    local buttH = 0
    function bar.btnUp:Paint( w, h )
        buttH = h
    end

    function bar:Paint( w, h )
        draw.RoundedBox( 8, w / 2 - w / 2, buttH, w / 2, h - buttH * 2, barClr )
    end

    function bar.btnDown:Paint( w, h )

    end
    function bar.btnGrip:Paint( w, h )
        draw.RoundedBox( 8, w / 2 - w / 2, 0, w / 2, h , theme.scrollfill or theme.theme )
    end


end

DCONFIG2.Sounds = {
    popup = "dconfig/tadah_08.wav",
    fail = "dconfig/error_07.wav",
    open = "dconfig/woosh_02.wav",
    close = "dconfig/woosh_09.wav",
    focus = "dconfig/click_08.wav",
    click = "dconfig/click_07.wav",
    checkbox = "dconfig/click_13.wav",
}

function DCONFIG2.PlaySound(sound)
    if not DCONFIG2.IngameConfig.sounds or not DCONFIG2.Sounds[sound] then return end

    surface.PlaySound(DCONFIG2.Sounds[sound])
end

local memoryCache = {}
net.Receive("dconfig2_requestEntityModel", function(len, ply)
	local length = net.ReadUInt(32)
	local compressedData = net.ReadData(length)
	local requestedModels = util.JSONToTable(util.Decompress(compressedData))
    for className, modelStr in pairs(requestedModels) do
        DCONFIG2.WriteModelToCache(className, modelStr)
        memoryCache[className] = modelStr
    end

end)

local requestModels = {} 
function DCONFIG2.GetEntityModel(className)
    local modelInMemory = memoryCache[className]
    if modelInMemory then
        return modelInMemory
    end 
    local modelStr = DCONFIG2.GetModelFromCache(className)
	if not modelStr then
        requestModels[className] = true
        timer.Create("dconfig2_request_ent_models", 1, 1, function()
            local requestModelData = util.Compress(util.TableToJSON(requestModels))
			local length = requestModelData:len()
            net.Start("dconfig2_requestEntityModel")
            net.WriteUInt(length, 32)
            net.WriteData(requestModelData, length)
            net.SendToServer()
            requestModels = {}
        end)
    end
    return modelStr

end

hook.Add("InitPostEntity", "PrepareModelCache", function()
    local ply = LocalPlayer()
    if not DCONFIG2.CanDConfig(ply) then return end

    for className,v in pairs(scripted_ents.GetList()) do
        DCONFIG2.GetEntityModel(className)
    end
end)

