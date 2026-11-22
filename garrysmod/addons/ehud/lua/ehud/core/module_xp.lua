--Style for https://github.com/uen/Leveling-System
-- or for https://github.com/GlorifiedPig/GlorifiedLeveling


local function on()
  hook.Remove("HUDPaint", "manolis:MVLevels:HUDPaintA") --remove original paint
  hook.Remove( "HUDPaint", "GlorifiedLeveling.HUD.HUDPaint") --remove original paint

  local bg = ehud.bg
  if not IsValid(bg) then return end
  local clr = ehud.addon:GetColors()
  local ply = LocalPlayer()

  bg.exp_panel = bg:Add("DPanel")
  local panel = bg.exp_panel
  panel:SetSize(bg:GetWide()*0.5, 22)

  if ehud.config.XPBarPosition == "top" then
    panel:SetY(10)
  elseif ehud.config.XPBarPosition == "bottom" then
    panel:SetY(bg:GetTall() - panel:GetTall() - 10)
  end

  panel:CenterHorizontal()


  local OldXP = 0
  local jobclr = table.Copy(clr.main.accent)
  jobclr.a = 50
  function panel:Paint(w,h)

    local PlayerLevel = 1
    local PlayerXP = 1
    if LevelSystemConfiguration then
      PlayerLevel = ply:getDarkRPVar("level")
      PlayerXP = ply:getDarkRPVar("xp")
    elseif GlorifiedLeveling then
      PlayerLevel = GlorifiedLeveling.GetPlayerLevel() or 1
      PlayerXP = GlorifiedLeveling.GetPlayerXP() or 1
    end
    if (not PlayerLevel) or (not PlayerXP) then return end

    if hook.Run("ehud.xp_should_draw") then return end
    
    local percent = 1

    if LevelSystemConfiguration then
      percent = ((PlayerXP or 0)/(((10+(((PlayerLevel or 1)*((PlayerLevel or 1)+1)*90))))*LevelSystemConfiguration.XPMult))--get percent
    elseif GlorifiedLeveling then
      percent = ((PlayerXP or 0)/(((10+(((PlayerLevel or 1)*((PlayerLevel or 1)+1)*90))))))
    end
    
    OldXP = Lerp(8*FrameTime(),OldXP,percent)
    local percent2 = math.Clamp(math.Round(percent*100),0,99)

    if GlorifiedLeveling or LevelSystemConfiguration.EnableBar then
      draw.RoundedBox(6,0,0,w,h,clr.main.bg)
      draw.RoundedBox(4,2,2,w*OldXP-4,h-4,jobclr)
    end

    if GlorifiedLeveling or LevelSystemConfiguration.BarText then
      esclib.draw:ShadowText("LVL "..PlayerLevel,"es_ehud_16_500",10,h*0.5-1,clr.main.text, TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER, 1)
      local added_text = ""
      if GlorifiedLeveling then
        added_text = string.format(" (x%d)", GlorifiedLeveling.Config.MULTIPLIER_AMOUNT_CUSTOMFUNC( ply ))
      end

      esclib.draw:ShadowText( string.format("%d EXP - %d%%%s",PlayerXP,percent2, added_text),"es_ehud_16_500",w-10,h*0.5-1,clr.main.text, TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER, 1)
    end

  end

end

local function off()
  --nothing to do
end

local function custom_check()
  return (LevelSystemConfiguration or GlorifiedLeveling) and (DarkRP ~= nil) and (ehud.addon:GetVar("module_xp_hud"))
end

ehud:Module("xp_override",on,off,custom_check)

-- GlorifiedLeveling
