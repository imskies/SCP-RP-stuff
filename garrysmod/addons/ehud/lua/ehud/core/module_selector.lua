local OldSwitch = nil 

local function on()
  local ply = LocalPlayer()
  local bg = ehud.bg
  local ISTTT = false

  --TTT support
  if WSWITCH then
    local blank = function() return false end

    if not OldSwitch then
      OldSwitch = WSWITCH.Enable
    end
    WSWITCH.Enable = blank --rewrite to blank function to disable default TTT
    ISTTT = true
  end

  if not IsValid(ehud.bg) then return end
  local clr = ehud.addon:GetColors()

  --internal vars
  local weapon_chache = {}
  local slots_count = 0
  local next_time = 0
  local change_breakout_time = 0
  local last_weapon = nil
  local selected_weapon = nil --work only when fast_change is false
  local selected_slot = nil
  local selected_slot_pos = nil

  --changable vars
  local fast_change = ehud.addon:GetVar("fast_switch")
  local cycled = true
  local show_time = 1.5 -- in seconds

  local function gm_GetWeaponSlot(weapon)
    if not IsValid(weapon) then return 4 end
    return (weapon:GetSlot() or 3)+1
  end

  local function gm_GetWeaponSlotPos(weapon)
    if not IsValid(weapon) then return 101 end
    return (weapon:GetSlotPos() or 100)+1
  end

  local function internal_GetWeaponsSlotPos(weapon) 
    if table.IsEmpty(weapon_chache) then return 0 end
    local slot = gm_GetWeaponSlot(weapon)
    if not weapon_chache[slot] then return end
    for k,v in pairs(weapon_chache[slot]) do
      if v == weapon then
        return k
      end
    end
  end

  local function internal_WeaponSort(a,b)
    return gm_GetWeaponSlotPos(a) < gm_GetWeaponSlotPos(b)
  end

  local function InvalidateWeapons()
    local weps = ply:GetWeapons()
    if not istable(weps) then return end
    if #weps <= 1 then return end

    table.Empty(weapon_chache)

    slots_count = 0
    for k,weapon in ipairs(weps) do
      local slot = gm_GetWeaponSlot(weapon)
      if not weapon_chache[slot] then 
        weapon_chache[slot] = {}
        slots_count = slots_count + 1
      end
      table.insert(weapon_chache[slot], weapon)

      table.sort( weapon_chache[slot], internal_WeaponSort ) --sort by it slot pos
    end
  end

  local function internal_GetCycledSlot(slot,gain)
    local n = 1
    local table_keys = {}
    local current_slot = 1
    for k,_ in pairs(weapon_chache) do
      table_keys[n] = k
      if k == slot then current_slot = n end
      n = n + 1
    end

    local gained_slot = current_slot + gain
    if gained_slot < 1 then
      gained_slot = #table_keys
    elseif gained_slot > #table_keys then
      gained_slot = 1
    end

    return table_keys[gained_slot]
  end

  local function CycleWeapons(weapon, gain, disable_invalidate, slot_cycled, tab_cycled)
    if not disable_invalidate then InvalidateWeapons() end
    local ct = CurTime()

    local next_pos = (internal_GetWeaponsSlotPos(weapon) or 1)+gain
    local slot = gm_GetWeaponSlot(weapon) or 1

    if not weapon_chache[slot] then weapon_chache[slot] = {} end

    if slot_cycled then
      if next_pos > #weapon_chache[slot] then
        if tab_cycled then slot = internal_GetCycledSlot(slot, 1) end
        next_pos = 1
      elseif next_pos < 1 then
        if tab_cycled then slot = internal_GetCycledSlot(slot, -1) end
        next_pos = #weapon_chache[slot]
      end
    end

    local weap = weapon_chache[slot][next_pos]
    if not IsValid(weap) then return end

    last_weapon = ply:GetActiveWeapon()

    if fast_change then
      input.SelectWeapon(weap) --change weapon
    end

    selected_weapon = weap
    selected_slot = slot
    selected_slot_pos = next_pos

    next_time = ct + show_time
    surface.PlaySound("ambient/water/rain_drip1.wav")

  end

  --Controls
  local function OnKeybind(ply, bind, pressed)
    if(not pressed) then return end
    if (not ply:Alive()) then return end
    if (#(ply:GetWeapons() or {})) <= 1 then return end

    if ply:InVehicle() then
      if ply.GetAllowWeaponsInVehicle then
        if not ply:GetAllowWeaponsInVehicle() then
          return
        end
      end
    end

    local ct = CurTime()

    if (next_time < CurTime()) and (input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT)) then return end

    local wep = ply:GetActiveWeapon()

    if not fast_change then
      if IsValid(selected_weapon) then
        wep = selected_weapon
      end
    end

    if (bind == 'invnext') then
      CycleWeapons(wep,1,false,true, cycled)
    elseif (bind == 'invprev') then
      CycleWeapons(wep,-1,false,true, cycled)
    elseif (string.sub(bind, 1, 4) == 'slot') then

      local slot = tonumber(string.sub(bind, -1))
      if ehud.TTT && RADIO.Show then return end
    
      local current_slot = gm_GetWeaponSlot(wep)
      InvalidateWeapons() --update weapon list
      if (not weapon_chache[slot]) then
        next_time = ct + show_time
        return 
      end
      if (current_slot ~= slot) then --if not in current tab then change to first weapon
        CycleWeapons(weapon_chache[slot][1], 0, true)
      else
        if next_time < ct then --if not opened
          CycleWeapons(weapon_chache[slot][1], 0, true)
        else
          CycleWeapons(wep, 1, true, true) --if in current tab\
        end
      end
    elseif (bind == "+attack") and (not fast_change) then
      if IsValid(selected_weapon) then
        input.SelectWeapon(selected_weapon)
        next_time = 0
        return true
      end
    elseif (bind == "lastinv") then
      if IsValid(last_weapon) then
        input.SelectWeapon(last_weapon)
        last_weapon = wep
      end
    end
  end

  --TTT name support
  local function internal_try_translate(name) 
    local TryTranslation = false
    if LANG then
      TryTranslation = LANG.TryTranslation
    end
    if isfunction(TryTranslation) then
      return TryTranslation(name)
    end
    return name
  end


  if IsValid(bg.selector) then 
    bg.selector:Remove()
  end

  ----------------------
  /// PAINT SECTIONS ///
  ----------------------
  local panel = bg:Add("DPanel")
  panel:SetSize(bg:GetWide(),bg:GetTall()-40)
  panel:SetZPos(10)
  panel:NoClipping(true)
  bg.selector = panel

  local max_count = 6
  local scw_ratio = ehud.config.SelectorWidth --(0:1] screen width
  if ISTTT then
    max_count = 9
    scw_ratio = 0.98
  end
  local offset_x = (panel:GetWide() - panel:GetWide()*scw_ratio)*0.5 -- (w - w*0.9)*0.5
  local offset_y = 20
  local tab_height = 30
  local opened_tab_height = tab_height*2
  local jobclr = clr.main.accent
  local lerp_posx = 0
  local lerp_posy = 0


  function panel:Paint(w,h)

    if not ply:Alive() then return end
    if next_time >= CurTime() then

      --TTT HUD
      if ISTTT then
        local current_tab_height = 0
        offset_y = h*0.9
        for tab_id=9,1,-1 do
          local tab = weapon_chache[tab_id]
          if not tab then continue end
          local tab_width = w*0.2
          local posx = w - tab_width - 10


          local posy = offset_y - current_tab_height
          for slot_pos, item in ipairs(tab) do
            if not IsValid(item) then continue end

            if (selected_slot_pos == slot_pos) and (selected_slot == tab_id) then --if selected
                lerp_posx = Lerp(0.3, lerp_posx, posx)
                lerp_posy = Lerp(0.3, lerp_posy, posy)
                ehud:PaintBlur(self,lerp_posx,lerp_posy-opened_tab_height*0.5,tab_width,opened_tab_height)

                surface.SetDrawColor(jobclr.r,jobclr.g,jobclr.b,jobclr.a)
                surface.SetMaterial(ehud.Materials["gradient"])
                surface.DrawTexturedRectRotated(lerp_posx+tab_width*0.5,lerp_posy,opened_tab_height,tab_width-1,90)

                draw.RoundedBox(0,lerp_posx,lerp_posy-opened_tab_height*0.5,tab_width,opened_tab_height,clr.main.bg)
                draw.RoundedBox(0,lerp_posx,lerp_posy+opened_tab_height*0.5-3,tab_width,3, jobclr)

                local name = internal_try_translate(item:GetPrintName() or item.PrintName or "...")
                local text_cut = esclib.util:TextCut(name or "","es_ehud_20_500", tab_width-40,'...')
                draw.SimpleText(text_cut, "es_ehud_20_500", lerp_posx+30,lerp_posy-2, clr.main.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                current_tab_height = current_tab_height + opened_tab_height + 5

                esclib.draw:ShadowText(tab_id,"es_ehud_20_500",posx+5,lerp_posy,clr.main.text,TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
              else
                draw.RoundedBox(0,posx,posy,tab_width,tab_height,clr.main.bg)
                local name = internal_try_translate(item:GetPrintName() or item.PrintName or "...")
                local text_cut = esclib.util:TextCut(name or "","es_ehud_16_500", tab_width-40,'...')
                draw.SimpleText(text_cut, "es_ehud_16_500", posx+30,posy+tab_height*0.5, clr.main.text_gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                current_tab_height = current_tab_height + tab_height + 5

                esclib.draw:ShadowText(tab_id,"es_ehud_20_500",posx+5,posy+5,clr.main.text)
              end
          end
        end

      --NORMAL DARKRP HUD
      else

        for tab_id=1,max_count do
          local tab_width = (panel:GetWide()*scw_ratio) / max_count
          local tab = weapon_chache[tab_id]

          local posx = offset_x+(tab_width+5)*(tab_id-1)

          if tab then
            local current_tab_height = offset_y-5
            for slot_pos, item in ipairs(tab) do
              if not IsValid(item) then continue end
              local posy = current_tab_height+5
              if (selected_slot_pos == slot_pos) and (selected_slot == tab_id) then --if selected
                lerp_posx = Lerp(0.3, lerp_posx, posx)
                lerp_posy = Lerp(0.3, lerp_posy, posy)
                ehud:PaintBlur(self,lerp_posx,lerp_posy,tab_width,opened_tab_height)

                surface.SetDrawColor(jobclr.r,jobclr.g,jobclr.b,jobclr.a)
                surface.SetMaterial(ehud.Materials["gradient"])
                surface.DrawTexturedRectRotated(lerp_posx+tab_width*0.5,lerp_posy+opened_tab_height*0.5,opened_tab_height,tab_width-1,90)

                draw.RoundedBox(0,lerp_posx,lerp_posy,tab_width,opened_tab_height,clr.main.bg)
                draw.RoundedBox(0,lerp_posx,lerp_posy+opened_tab_height-3,tab_width,3, jobclr)


                local name = internal_try_translate(item:GetPrintName() or item.PrintName or "...")
                local text_cut = esclib.util:TextCut(name or "","es_ehud_20_500", tab_width-40,'...')
                draw.SimpleText(text_cut, "es_ehud_20_500", lerp_posx+20,lerp_posy+20, clr.main.text)
                current_tab_height = current_tab_height + opened_tab_height + 5

                --Instruction draw
                local class_name = item:GetClass()
                if class_name then
                  local swep_table = weapons.Get(class_name)
                  if not swep_table then
                    continue
                  end

                  if not swep_table.Instructions then
                    continue
                  end

                  if swep_table.Instructions == "" then
                    continue
                  end

                  local hx = w*0.5
                  local ofy = h*0.05

                  local multiline = esclib.text:Multiline(swep_table.Instructions,"es_ehud_n_18_500",maxwidth)

                  draw.RoundedBox(8,hx-multiline.width*0.5-10,h-multiline.height-10-ofy, multiline.width+20, multiline.height+20, clr.main.bg)

                  esclib.text:DrawMultiline(multiline,hx,h-multiline.height-ofy,clr.main.text,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)

                  esclib.draw:ShadowText(name,"es_ehud_20_500", hx, h-multiline.height-ofy-2, clr.main.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                end
              else --if not selected currently
                draw.RoundedBox(0,posx,posy,tab_width,tab_height,clr.main.bg)
                local name = internal_try_translate(item:GetPrintName() or item.PrintName or "...")
                local text_cut = esclib.util:TextCut(name or "","es_ehud_16_500", tab_width-40,'...')
                draw.SimpleText(text_cut, "es_ehud_16_500", posx+30,posy+tab_height*0.5, clr.main.text_gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                current_tab_height = current_tab_height + tab_height + 5
              end
            end
          end

          --tab counter
          esclib.draw:ShadowText(tab_id,"es_ehud_18_500",posx+5,offset_y+6,clr.main.text)
        end -- if not TTT
      end


      -- draw.RoundedBox(0,posx,0,w,h,clr.main.bg)
      -- draw.SimpleText(selected_weapon:GetPrintName(),"es_ehud_30_500",posx,5,clr.main.text)
    else
      if selected_weapon ~= nil then
        selected_weapon = nil
        selected_slot = nil
        selected_slot_pos = nil
      end
    end
  end

  hook.Add("ehud.xp_should_draw", "ehud.xp_hide_on_selector", function()
    if (next_time >= CurTime()) and (ehud.config.XPBarPosition == "top") then
      return true
    end
  end)

  hook.Add('PlayerBindPress', 'ehud.selector.bind', OnKeybind)

  --disable default
  hook.Add('HUDShouldDraw', 'ehud.defaultselector.disable', function(name) if name == 'CHudWeaponSelection' then return false end end)
end

local function off()
  hook.Remove('PlayerBindPress', 'ehud.selector.bind')
  hook.Remove('HUDShouldDraw', 'ehud.defaultselector.disable')

  if OldSwitch then
    if WSWITCH then
      WSWITCH.Enable = OldSwitch
      OldSwitch = nil
    end
  end
end

local function custom_check()
  return ehud.addon:GetVar("module_selector_hud")
end

ehud:Module("selector",on,off,custom_check)
