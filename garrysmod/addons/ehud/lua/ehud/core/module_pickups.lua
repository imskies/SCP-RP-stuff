ehud.pickups = ehud.pickups or {
    ammo = {},
    item = {},
    weapon = {},
    panels = {},
}

local function invalidateLayout()
    local panels = ehud.pickups["panels"]

    local panel
    local startPos = esclib.scrh*0.5
    local totalh = 0

    for k,v in ipairs(panels) do
        panel = panels[k]

        if not IsValid(panel) then
            table.remove(panels,k)
            invalidateLayout()
            return
        end

        if (#panels > 8) then
            table.remove(panels,k)
            panel:Close()
            invalidateLayout()
            return
        end

        totalh = totalh + panel:GetTall() + 5

        panel:MoveTo(esclib.scrw - panel:GetWide()+1,startPos - totalh, 0.1)
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

-------------------
/// AMMO PICKUP ///
-------------------
local function AmmoPickup(self,name,amount)
    local bg = ehud.bg
    local type = "ammo"

    local clr = ehud.addon:GetColors()

    if ehud.pickups[type][name] then
        local tbl = ehud.pickups[type][name]
        if IsValid(tbl["panel"]) then
            tbl["panel"]:UpdateAmount(name,amount)
            return
        end
        ehud.pickups[type][name] = nil
    end

    ehud.pickups[type][name] = {}
    local tbl = ehud.pickups[type][name]
    local pick_panel = vgui.Create("DPanel",bg)
    pick_panel.amount = amount
    local ammo1_type = game.GetAmmoID( name ) or 0
    local ammo_icon = ehud.Materials["ammo_normal.png"]
    pick_panel.total = (LocalPlayer():GetAmmoCount(ammo1_type)) + amount
    tbl["panel"] = pick_panel

    function pick_panel:Close()
        self.closing = true
        self:MoveTo(bg:GetWide(),self:GetY(),0.1,0,-1,function()
            ehud.pickups[type][name] = nil
            if IsValid(self) then self:Remove() end
            invalidateLayout()
        end)
    end

    function pick_panel:Think(w,h)
        if (CurTime() > self.TimeLeft) and (not self.closing) then
            self:Close()
            return
        end
    end

    if ammo1_type == 7 then
        ammo_icon = ehud.Materials["ammo_buckshot.png"]
    elseif (ammo1_type == 3) or (ammo1_type == 4) or (ammo1_type == 12) then
        ammo_icon = ehud.Materials["ammo_pistol.png"]
    elseif (ammo1_type == 8) or (ammo1_type == 10) or (ammo1_type == 11) then
        ammo_icon = ehud.Materials["ammo_explosive.png"]
    elseif (ammo1_type == 1) or (ammo1_type == 2) or (ammo1_type == 14) or (ammo1_type == 13) then
        ammo_icon = ehud.Materials["ammo_normal.png"]
    end

    pick_panel.text = string.format("%s  [%d/%d]", name, pick_panel.amount, pick_panel.total)
    local font = "es_ehud_20_500"
    local tw,th = esclib.util:TextSize(pick_panel.text, font)
    local iconsize = th*0.5
    function pick_panel:Paint(w,h)
        esclib.draw:MaterialCentered(iconsize+6, h*0.5+1, iconsize, clr.default.black, ammo_icon)
        esclib.draw:MaterialCentered(iconsize+5, h*0.5, iconsize, clr.default.white, ammo_icon)

        esclib.draw:ShadowText(self.text,font,w-5,h*0.5,clr.main.text,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end
    pick_panel:SetSize(tw+iconsize*2+20,th+4)
    pick_panel:SetPos(bg:GetWide(), bg:GetTall()*0.5)
    pick_panel.TimeLeft = CurTime()+3

    function pick_panel:UpdateAmount(name,new)
        self.amount = self.amount + new
        self.total = (LocalPlayer():GetAmmoCount(game.GetAmmoID( name )) or 0) + new
        self.TimeLeft = CurTime()+3

        self.text = string.format("%s  [%d/%d]", name, pick_panel.amount, pick_panel.total)
        local font = "es_ehud_20_500"
        local tw,th = esclib.util:TextSize(self.text, font)
        local iconsize = th*0.5
        pick_panel:SetSize(tw+iconsize*2+20,th+4)

        invalidateLayout()
    end

    table.insert(ehud.pickups["panels"],pick_panel)
    invalidateLayout()
    ehud.pickups.last = pick_panel
end


------------------
/// GUN PICKUP ///
------------------
local function GunPickup(self,weapon)
    local bg = ehud.bg
    local type = "ammo"

    local name
    if weapon.GetPrintName and isfunction(weapon.GetPrintName) then
        name = weapon:GetPrintName()
    end

    name = internal_try_translate(name or weapon.PrintName or "...") or "..."

    local clr = ehud.addon:GetColors()

    if ehud.pickups[type][name] then
        local tbl = ehud.pickups[type][name]
        if IsValid(tbl["panel"]) then
            tbl["panel"]:UpdateAmount()
            return
        end
        ehud.pickups[type][name] = nil
    end

    ehud.pickups[type][name] = {}
    local tbl = ehud.pickups[type][name]
    local pick_panel = vgui.Create("DPanel",bg)
    tbl["panel"] = pick_panel
    pick_panel.TimeLeft = CurTime()+3

    function pick_panel:Close()
        self.closing = true
        self:MoveTo(bg:GetWide(),self:GetY(),0.1,0,-1,function()
            ehud.pickups[type][name] = nil
            if IsValid(self) then self:Remove() end
            invalidateLayout()
        end)
    end

    function pick_panel:Think(w,h)
        if (CurTime() > self.TimeLeft) and (not self.closing) then
            self:Close()
            return
        end
    end

    local text = string.format("%s", name)
    local font = "es_ehud_30_500"
    local tw,th = esclib.util:TextSize(text, font)
    local iconsize = th*0.5
    function pick_panel:Paint(w,h)
        esclib.draw:MaterialCentered(iconsize+6, h*0.5+1, iconsize, clr.default.black, ehud.Materials["gun.png"])
        esclib.draw:MaterialCentered(iconsize+5, h*0.5, iconsize, clr.default.white, ehud.Materials["gun.png"])

        esclib.draw:ShadowText(text,font,w-5,h*0.5,clr.main.text,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end
    pick_panel:SetSize(tw+iconsize*2+20,th+4)
    pick_panel:SetPos(bg:GetWide(), bg:GetTall()*0.5)

    function pick_panel:UpdateAmount()
        self.TimeLeft = CurTime()+3
        invalidateLayout()
    end

    table.insert(ehud.pickups["panels"],pick_panel)
    invalidateLayout()
    ehud.pickups.last = pick_panel
end

-------------------
/// ITEM PICKUP ///
-------------------
local function ItemPickup(self,name)
local bg = ehud.bg
    local type = "item"

    local name = language.GetPhrase(name) or name

    local clr = ehud.addon:GetColors()

    if ehud.pickups[type][name] then
        local tbl = ehud.pickups[type][name]
        if IsValid(tbl["panel"]) then
            tbl["panel"]:UpdateAmount()
            return
        end
        ehud.pickups[type][name] = nil
    end

    ehud.pickups[type][name] = {}
    local tbl = ehud.pickups[type][name]
    local pick_panel = vgui.Create("DPanel",bg)
    tbl["panel"] = pick_panel
    pick_panel.TimeLeft = CurTime()+3

    function pick_panel:Close()
        self.closing = true
        self:MoveTo(bg:GetWide(),self:GetY(),0.1,0,-1,function()
            ehud.pickups[type][name] = nil
            if IsValid(self) then self:Remove() end
            invalidateLayout()
        end)
    end

    function pick_panel:Think(w,h)
        if (CurTime() > self.TimeLeft) and (not self.closing) then
            self:Close()
            return
        end
    end

    local text = string.format("%s", name)
    local font = "es_ehud_20_500"
    local tw,th = esclib.util:TextSize(text, font)
    local iconsize = th*0.5
    function pick_panel:Paint(w,h)
        esclib.draw:MaterialCentered(iconsize+6, h*0.5+1, iconsize, clr.default.black, ehud.Materials["list.png"])
        esclib.draw:MaterialCentered(iconsize+5, h*0.5, iconsize, clr.default.white, ehud.Materials["list.png"])

        esclib.draw:ShadowText(text,font,w-5,h*0.5,clr.main.text,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    end
    pick_panel:SetSize(tw+iconsize*2+20,th+4)
    pick_panel:SetPos(bg:GetWide(), bg:GetTall()*0.5)

    function pick_panel:UpdateAmount()
        self.TimeLeft = CurTime()+3
        invalidateLayout()
    end

    table.insert(ehud.pickups["panels"],pick_panel)
    invalidateLayout()
    ehud.pickups.last = pick_panel
end

--LUA REFRESH
local gm = GM or GAMEMODE
if gm then
    gm.HUDAmmoPickedUp = AmmoPickup
    gm.HUDWeaponPickedUp = GunPickup
    gm.HUDItemPickedUp = ItemPickup
end


hook.Add("OnGamemodeLoaded","ehud.pickup_gamemode_listener",function()
    local gm = GM or GAMEMODE
    gm.HUDAmmoPickedUp = AmmoPickup
    gm.HUDWeaponPickedUp = GunPickup
    gm.HUDItemPickedUp = ItemPickup
end)