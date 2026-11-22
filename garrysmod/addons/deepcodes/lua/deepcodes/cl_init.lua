local DeepCodes = DeepCodes
-------------------------------
local CachedCodes = {}

for code,_ in pairs(DeepCodes.Codes) do
    CachedCodes[code] = Material("deepcodes/code_"..code..".png")
end

PrintTable(CachedCodes)

DeepCodes.Container = Material("deepcodes/background.png")
-------------------------------

surface.CreateFont("DeepCodes.Regular", {
    font = "Courier New",
    extended = false,
    weight = 600,
    size = 23
})

surface.CreateFont("DeepCodes.DBlock", {
    font = "Courier New",
    extended = false,
    weight = 600,
    size = 18
})

surface.CreateFont("DeepCodes.Time", {
    font = "Courier New",
    extended = false,
    weight = 200,
    size = 14
})

DeepCodes.code = "Green"
DeepCodes.DBlock = DeepCodes.DBlockCodes["freetime"]

local Size = 200 / 4.5
local scrw,scrh = ScrW() , ScrH()

hook.Add("OnScreenSizeChanged", "DeepCodes.ChangeScreenVals", function()
    scrw,scrh = ScrW() , ScrH()
end )

hook.Add("HUDPaint", "DeepCodes.HUD", function()
    surface.SetDrawColor(color_white)
    surface.SetMaterial(CachedCodes[string.lower(DeepCodes.code)])
    surface.DrawTexturedRect(15, 10, Size, Size)

    surface.SetFont("DeepCodes.Regular")
    surface.SetTextPos(85, 27)

    surface.SetTextColor(color_white)
    surface.DrawText("Code: ")
    
    surface.SetTextColor(DeepCodes.Codes[string.lower(DeepCodes.code)])
    surface.DrawText(" "..DeepCodes.code)

    if DeepCodes.LastCodeChange > 0 then
        surface.SetFont("DeepCodes.Time")
        surface.SetTextPos(85, 44)

        surface.SetTextColor(color_white)
        local time = CurTime() - DeepCodes.LastCodeChange
        local hours = math.floor(math.fmod(time, 86400) / 3600)
        local minutes = math.floor(math.fmod(time,3600) / 60)
        local seconds = math.floor(math.fmod(time,60))
        if hours >= 1 then
            surface.DrawText("Last code change: " .. Format("%02d:%02d:%02d", hours, minutes, seconds))
        else
            surface.DrawText("Last code change: " .. Format("%02d:%02d", minutes, seconds))
        end
    end

end )

hook.Add("HUDPaint", "DeepCodes.DBlock", function()
    surface.SetDrawColor(color_white)

    surface.SetFont("DeepCodes.DBlock")
    surface.SetTextPos(85, 59)

    surface.SetTextColor(color_white)
    surface.DrawText("D-Block: ")
    
    surface.SetTextColor(DeepCodes.DBlock[2])
    surface.DrawText(" "..DeepCodes.DBlock[1])

    if DeepCodes.LastDBlockChange > 0 then
        surface.SetFont("DeepCodes.Time")
        surface.SetTextPos(85, 73)

        surface.SetTextColor(color_white)
        local time = CurTime() - DeepCodes.LastDBlockChange
        local hours = math.floor(math.fmod(time, 86400) / 3600)
        local minutes = math.floor(math.fmod(time,3600) / 60)
        local seconds = math.floor(math.fmod(time,60))
        if hours >= 1 then
            surface.DrawText("Last code change: " .. Format("%02d:%02d:%02d", hours, minutes, seconds))
        else
            surface.DrawText("Last code change: " .. Format("%02d:%02d", minutes, seconds))
        end
    end

end )