local meta = debug.getregistry().Panel or FindMetaTable("Panel")
if meta and meta.__PsychEvalSafePanelPatch then
    meta.SetPos = nil
    meta.SetSize = nil
    meta.__PsychEvalSafePanelPatch = nil
end

pcall(function() include("psych_eval/cl_shared.lua") end)
pcall(function() include("vgui/cl_psych_schedule.lua") end)

PsychEval_cl_mainmenu_loaded = true

if not PsychEval then PsychEval = {} end

local ActiveMainMenu = nil
local HOVER_SOUND = "other/oakman/deadspace/ui/tic.wav"

local THEME = {
    bg = Color(12, 6, 20),
    panel = Color(22, 14, 34),
    panel_alt = Color(16, 10, 26),
    panel_soft = Color(28, 18, 42, 220),
    psych_accent = Color(126, 92, 255),
    test_accent = Color(190, 198, 212),
    bio_accent = Color(84, 176, 122),
    doc_accent = Color(80, 140, 232),
    schedule_accent = Color(232, 145, 70),
    dossier_accent = Color(155, 110, 205),
    text = Color(240, 244, 248),
    text_dark = Color(10, 12, 16),
    muted = Color(156, 166, 181),
    stroke = Color(255, 255, 255, 26),
    ok = Color(84, 176, 122),
    warn = Color(244, 212, 95),
    danger = Color(220, 88, 88)
}

surface.CreateFont("PsychMain_Title", {font="Roboto Mono", size=28, weight=900})
surface.CreateFont("PsychMain_Subtitle", {font="Roboto Mono", size=16, weight=600})
surface.CreateFont("PsychMain_Body", {font="Roboto Mono", size=18, weight=600})
surface.CreateFont("PsychMain_Button", {font="Roboto Mono", size=17, weight=800})
surface.CreateFont("PsychMain_CardLabel", {font="Roboto Mono", size=19, weight=900})
surface.CreateFont("PsychMain_CardSmall", {font="Roboto Mono", size=14, weight=700})
surface.CreateFont("PsychMain_DossierBody", {font="Roboto Mono", size=17, weight=560})
surface.CreateFont("PsychMain_Micro", {font="Roboto Mono", size=13, weight=700})

local BG_GRAD = Material("bg_grad.png", "smooth")
local APP_ICONS = {
    bio = { primary = "icons/swift_bio.png", fallback = "icon_bio.png" },
    psych = { primary = "icons/swift_psych.png", fallback = "icon_psych.png" },
    test = { primary = "icons/swift_tests.png", fallback = "icon_test.png" },
    files = { primary = "icons/swift_files.png", fallback = "icon_files.png" },
    schedule = { primary = "icons/swift_schedule.png", fallback = "icon_schedule.png" },
    dossier = { primary = "icons/swift_dossier.png", fallback = "icon_files.png" }
}

-- Utility
local function IsPanelValid(p) return p ~= nil and IsValid(p) end
local function SafeCall(fn, ctx)
    local ok, err = xpcall(fn, debug.traceback)
    if not ok then print("[cl_psych_mainmenu] ERROR in " .. tostring(ctx or "unknown") .. ": " .. tostring(err)) end
end

local function AttachHoverSound(btn)
    if not IsValid(btn) then return btn end

    local prev = btn.OnCursorEntered
    btn.OnCursorEntered = function(self)
        surface.PlaySound(HOVER_SOUND)
        if isfunction(prev) then
            prev(self)
        end
    end

    return btn
end

local function ResolveAccentColor(col)
    if type(col) == "string" and THEME[col] then return THEME[col] end
    return col or THEME.psych_accent
end

local function GetIconMaterial(iconDef)
    if not iconDef then
        return Material("icon_files.png", "smooth mips")
    end

    if istable(iconDef) then
        if iconDef._mat then return iconDef._mat end

        if iconDef.primary and file.Exists("materials/" .. iconDef.primary, "GAME") then
            iconDef._mat = Material(iconDef.primary, "smooth mips")
            return iconDef._mat
        end

        iconDef._mat = Material(iconDef.fallback or iconDef.primary or "icon_files.png", "smooth mips")
        return iconDef._mat
    end

    return Material(iconDef, "smooth mips")
end

local function DrawRoundedMaterial(radius, x, y, w, h, mat, col)
    if PsychEval_DrawRoundedMaterial then
        return PsychEval_DrawRoundedMaterial(radius, x, y, w, h, mat, col)
    end

    if not mat or mat:IsError() then return end

    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

    render.OverrideColorWriteEnable(true, false)
    draw.RoundedBox(radius, x, y, w, h, color_white)
    render.OverrideColorWriteEnable(false, false)

    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilPassOperation(STENCILOPERATION_KEEP)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)

    local bleed = math.max(8, radius)
    surface.SetMaterial(mat)
    surface.SetDrawColor(col.r, col.g, col.b, col.a or 255)
    surface.DrawTexturedRect(x - bleed, y - bleed, w + (bleed * 2), h + (bleed * 2))

    render.SetStencilEnable(false)
    render.ClearStencil()
end

local function DrawTerminalShell(w, h, title, subtitle, accent, noGradient)
    local stripe = ResolveAccentColor(accent)

    draw.RoundedBox(18, 0, 0, w, h, Color(10, 4, 18, 185))
    draw.RoundedBox(16, 4, 4, w - 8, h - 8, THEME.bg)

    if BG_GRAD and not BG_GRAD:IsError() then
        DrawRoundedMaterial(16, 4, 4, w - 8, h - 8, BG_GRAD, Color(stripe.r, stripe.g, stripe.b, 10))
    end

    draw.RoundedBoxEx(16, 0, 0, w, 90, THEME.panel, true, true, false, false)

    surface.SetDrawColor(stripe.r, stripe.g, stripe.b, 230)
    surface.DrawRect(0, 84, w, 3)

    draw.SimpleText(title or "RESEARCH TERMINAL", "PsychMain_Title", 22, 28, stripe, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

local function AddWindowCloseButton(frame, font, baseColor)
    if not IsPanelValid(frame) then return nil end
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetSize(30, 30)
    closeButton:SetText("")
    closeButton.Think = function(s)
        if not IsPanelValid(frame) then return end
        s:SetPos(frame:GetWide() - 42, 14)
    end
    closeButton.DoClick = function()
        if IsPanelValid(frame) then
            frame:Close()
        end
    end
    closeButton.Paint = function(s, w, h)
        local col = s:IsHovered() and Color(220, 70, 70) or (baseColor or THEME.text)
        draw.SimpleText("✕", font or "PsychMain_Body", w * 0.5, h * 0.5 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return AttachHoverSound(closeButton)
end

-- Team helpers
local function ResolvePlayerTeamNameLocal()
    if PsychEval.ResolvePlayerTeamName then return PsychEval.ResolvePlayerTeamName(LocalPlayer()) end
    if team and team.GetName then
        local tn = team.GetName(LocalPlayer():Team())
        if tn and tn ~= "" then return tn end
    end
    return tostring(LocalPlayer():Team())
end

local function IsJobListed()
    if PsychEval and PsychEval_IsJobListed then return PsychEval_IsJobListed() end
    local teamID = LocalPlayer():Team()
    if PsychEval and PsychEval.AccessByTeamID and PsychEval.AccessByTeamID[teamID] ~= nil then return true end
    local teamName = ResolvePlayerTeamNameLocal()
    if PsychEval and PsychEval.AccessByTeamName and PsychEval.AccessByTeamName[teamName] ~= nil then return true end
    if PsychEval and PsychEval.ClearanceByTeamID and PsychEval.ClearanceByTeamID[teamID] ~= nil then return true end
    if PsychEval and PsychEval.ClearanceByTeamName and PsychEval.ClearanceByTeamName[teamName] ~= nil then return true end
    return false
end

-- Button factory
local function DrawAccentButton(parent, x, y, w, h, text, accent, textColor, cb)
    local b = vgui.Create("DButton", parent)
    b:SetPos(x, y)
    b:SetSize(w, h)
    b:SetText("")
    b.DoClick = function() if isfunction(cb) then cb() end end
    b.Paint = function(s, pw, ph)
        local col = ResolveAccentColor(accent)
        local bg = THEME.panel_alt
        if s:IsDown() then
            bg = Color(18, 24, 32)
        elseif s:IsHovered() then
            bg = Color(22, 28, 38)
        end

        draw.RoundedBox(10, 0, 0, pw, ph, bg)
        surface.SetDrawColor(THEME.stroke)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
        surface.SetDrawColor(col.r, col.g, col.b, 235)
        surface.DrawRect(0, 0, pw, 4)
        draw.SimpleText(string.upper(text or "BUTTON"), "PsychMain_Button", pw * 0.5, ph * 0.5, textColor or THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return AttachHoverSound(b)
end

local function CreateLauncherTile(parent, x, y, w, h, title, subtitle, accent, iconMat, cb)
    local b = vgui.Create("DButton", parent)
    b:SetPos(x, y)
    b:SetSize(w, h)
    b:SetText("")
    b.DoClick = function() if isfunction(cb) then cb() end end
    b.Paint = function(s, pw, ph)
        local col = ResolveAccentColor(accent)
        local mat = iconMat or GetIconMaterial(APP_ICONS.files)
        s._HoverFrac = Lerp(FrameTime() * 12, s._HoverFrac or 0, s:IsHovered() and 1 or 0)

        local hoverOffsetY = math.floor(6 * s._HoverFrac)
        local alpha = s:IsDown() and 210 or 245
        local labelY = ph - 42 + hoverOffsetY
        local labelTopY = labelY - 10

        local baseIconSize = math.min(math.floor(math.min(pw, ph - 34) * 0.84), ph - 48)
        local iconSize = math.floor(baseIconSize * (1 + (0.08 * s._HoverFrac)))
        local iconX = math.floor((pw - iconSize) * 0.5)
        local iconY = math.max(8, math.floor((labelTopY - iconSize) * 0.5) + hoverOffsetY)

        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, alpha)
        surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)

        draw.SimpleText(string.upper(title or "APPLICATION"), "PsychMain_CardLabel", pw * 0.5, labelY, THEME.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
    return AttachHoverSound(b)
end

-- Documents
local DOCUMENT_URLS = {
    ["Research SOP"] = "https://docs.google.com/document/d/1mrpSWXCjB3vPQvcgUbSKG-87IEV8Ic4dasde9CQMR-U/edit?usp=sharing",
    ["Testing Sheet"] = "https://docs.google.com/spreadsheets/d/1Z0coFeraV4pnZzHGR0yV2KEWNbwl__xirYl9LtbcgmE/edit?usp=sharing"
}

local scps = {
    {
        title = "SCP-131",
        alias = "The Eye Pods",
        class = "Safe",
        containment = [[No special safety procedures are to be taken with SCP-131-A and SCP-131-B. They are free to travel about Site-19 so long as they do not attempt to enter any restricted areas or attempt to leave the facility. Casual contact with the subjects is permitted, but it is recommended that such contact be kept to a minimum to prevent the creatures from forming an attachment to personnel. Hourly tabs are to be kept on subjects at all times; failure to account for their presence at these times constitutes a level one lockdown situation. Any report of abuse or mistreatment of the subjects will result in a harsh reprimand.]],
        description = [[SCP-131-A and SCP-131-B (affectionately nicknamed the "Eye Pods" by personnel) are a pair of teardrop-shaped creatures roughly 30 cm (1 ft) in height, with a single blue eye in the middle of their bodies. SCP-131-A is burnt orange in color while SCP-131-B is mustard yellow. At the base of each creature is a wheel-like protrusion which allows for locomotion, suggesting that the creatures may be biomechanical in origin.

The subjects seem to have the intelligence of common house cats and are insatiably curious. Most of the time they simply roll around the facility, observing personnel at work and catching peeks at other Safe class SCPs. The subjects seem to be able to communicate with each other via an untranslatable high-pitched babbling.]],
        url = "https://scp-wiki.wikidot.com/scp-131"
    },
    {
        title = "SCP-343",
        alias = '"God"',
        class = "Safe",
        containment = [[SCP-343 resides in a 6.1 m by 6.1 m (20 ft by 20 ft) room at Minimal Security Site 17. It should be brought any items it requests and visited by at least one staff member each day. Attempts to add further safety precautions or required clearances are unnecessary/impossible due to the nature of SCP-343 (see description).]],
        description = [[SCP-343 is a male, seemingly race-less, humanoid in appearance with apparent omnipotence. SCP-343 was discovered walking the streets of Prague and detained after a staff member witnessed him disappear from the streets and reappear on a rooftop. SCP-343 is detained willingly in his chamber, as containment has proved impossible (see notes).]],
        url = "https://scp-wiki.wikidot.com/scp-343"
    },
    {
        title = "SCP-527",
        alias = "Mr. Fish",
        class = "Safe",
        containment = [[SCP-527 is housed in standard low-risk humanoid quarters with ordinary meal, hygiene, and recreation access. Because the anomaly is cooperative and socially well-adjusted, supervised movement through approved areas is permitted. Interviews and photography are restricted to Foundation staff to preserve secrecy and reduce unnecessary attention on the subject.]],
        description = [[SCP-527 is a baseline adult human male whose only obvious anomaly is that his head is anatomically that of a large fish. Despite this appearance, he speaks normally, shows no unusual hostility, and demonstrates ordinary human intelligence and behavior.

Medical observation indicates that SCP-527 remains viable and healthy despite the apparent incompatibility between its cranial structure and standard human biology. In practice, the Foundation treats him more as a cooperative anomalous resident than as a major containment hazard.]],
        url = "https://scp-wiki.wikidot.com/scp-527"
    },
    {
        title = "SCP-662",
        alias = "Mr. Deeds",
        class = "Safe",
        containment = [[SCP-662 is kept secured in its presentation box or a locked storage unit when not under test. Activation is limited to authorized personnel, and all requests made through the bell are logged and reviewed. Orders intended to cause mass harm, escape assistance, or unauthorized acquisition of restricted materials are prohibited.]],
        description = [[SCP-662 is a small silver hand bell which, when rung while a request is spoken, summons a humanoid servant calling himself "Mr. Deeds." The entity appears in formal attire, is extremely polite, and attempts to fulfill the request to the best of its ability before vanishing once dismissed or the task is complete.

Mr. Deeds is capable of retrieving small items, delivering messages, cleaning, and carrying out many practical errands with anomalous speed and precision. Even so, the phenomenon operates within limits, and testing has shown that poorly worded or unethical commands can create unnecessary security risk.]],
        url = "https://scp-wiki.wikidot.com/scp-662"
    },
    {
        title = "SCP-912",
        alias = "Autonomous SWAT Gear",
        class = "Safe",
        containment = [[SCP-912 is stored in a secure equipment locker or sealed containment room when not in use for testing. Access is restricted to approved staff, and live demonstrations require a controlled range with armed backup present. Personnel are warned not to approach while visibly armed unless the test protocol specifically calls for that response.]],
        description = [[SCP-912 manifests as a full set of apparently empty tactical police gear behaving as though an invisible officer were wearing it. The equipment can patrol, take cover, aim weapons, and respond to verbal police-style commands despite the absence of a visible operator.

The anomaly shows a strong tendency to identify weapons, resistance, or perceived threats and react with aggressive "law-enforcement" behavior. This makes SCP-912 useful for controlled observation but dangerous when introduced into confusing or crowded situations.]],
        url = "https://scp-wiki.wikidot.com/scp-912"
    },
    {
        title = "SCP-999",
        alias = "The Tickle Monster",
        class = "Safe",
        containment = [[SCP-999 is allowed to freely roam the facility should it desire to, but otherwise must stay in its pen either between 8PM-9PM for sleeping, or during emergency lockdowns for its own safety. Subject is not allowed out of its pen at night or off facility grounds at any time. Pen is to be kept clean and food replaced twice daily. All personnel are allowed inside SCP-999’s holding area, but only if they are not assigned to other tasks at the time, or if they are on break. Subject is to be played with when bored and spoken to in a calm, non-threatening tone.]],
        description = [[SCP-999 appears to be a large, amorphous, gelatinous mass of translucent orange slime, weighing about 54 kg (120 lbs) with a consistency similar to that of peanut butter. Subject’s size and shape is easily malleable and can change shape at will, though when at rest, SCP-999 becomes a rounded, oblate dome roughly 2 meters wide and 1 meter in height. The surface of SCP-999 consists of a thin, transparent membrane similar to that of an animal cell roughly .5 cm thick, and is highly elastic, allowing SCP-999 to flatten portions of its body up to 2 cm thin.

Subject’s temperament is best described as playful and dog-like: when approached, SCP-999 will often react with overwhelming elation, slithering over to the nearest person and leaping upon them, “hugging” them with a pair of pseudopods while nuzzling the person’s face with a third pseudopod, all the while emitting high-pitched gurgling and cooing noises.

Simply touching SCP-999’s surface causes an immediate mild euphoria, which intensifies the longer one is exposed to SCP-999, and lasts long after separation from the creature.]],
        url = "https://scp-wiki.wikidot.com/scp-999"
    },
    {
        title = "SCP-053",
        alias = "Young Girl",
        class = "Euclid",
        containment = [[SCP-053 is to be contained in an area no less than 5 m x 5 m (16 ft x 16 ft) and given adequate room to move. Toys, books, games, and other recreational devices are to be amply provided and rotated every three (3) months. Proper bedding, bathroom, and medical facilities are to be maintained at all times. Food should be provided three (3) times daily, and two (2) snacks are allowed if requested.

No physical contact is to be made with SCP-053 without full atmosphere-containment suit and eye shield. No eye contact is to be made with SCP-053 for any reason. Any objects given to personnel by SCP-053 may be removed, but must be given to quarantine for examination. Only one (1) member of personnel may be present in the room at any given time and must be secured by a safety line of steel cable. All personnel must be removed from SCP-053's containment chamber within 10 minutes of entering.]],
        description = [[SCP-053 appears to be a small 3-year-old girl. She is capable of basic speech and appears to be slightly above average in mental development. She has a generally pleasant personality and rarely seems upset, becoming agitated only in the presence of groups of people.

Any and all humans over the age of three who make eye contact with, physically touch, or remain around SCP-053 for longer than 10 minutes will rapidly become irrational, paranoid, and homicidal. Most, if not all, of these feelings will be directed at SCP-053, and afflicted subjects will attempt to kill SCP-053 after first killing or driving off all humans visible to them. Those attempting to kill SCP-053 will suffer massive heart attacks or seizures and die seconds after doing any physical damage to SCP-053. SCP-053 will regenerate almost instantaneously from any wound, regardless of severity.]],
        url = "https://scp-wiki.wikidot.com/scp-053"
    },
    {
        title = "SCP-066",
        alias = "Eric's Toy",
        class = "Euclid",
        containment = [[SCP-066 is kept in a reinforced, sound-dampened storage container and only handled during approved tests. Hearing protection and distance barriers are required whenever the containment unit is opened. Staff are instructed to avoid unnecessary stimulation, as the subject's acoustic output can escalate without warning.]],
        description = [[SCP-066 is a tangled, animate mass of yarn, ribbon, and fabric scraps with the rough size and shape of a small child. It moves on its own, reacts to nearby people, and is known for repeatedly vocalizing the question, "Eric?"

Although once considered mostly harmless, SCP-066 has since exhibited powerful anomalous sound production, including sudden orchestral playback and destructive sonic bursts. Its behavior is unpredictable enough that even brief exposure is treated as a significant safety concern.]],
        url = "https://scp-wiki.wikidot.com/scp-066"
    },
    {
        title = "SCP-079",
        alias = "Old AI",
        class = "Euclid",
        containment = [[SCP-079 is packed away in a double-locked room in the secured general holding area at Site-15, connected by a 120VAC power cord to a small array of batteries and solar panels. Staff with Level 2 or higher clearance may have access to SCP-079. Under no circumstances will SCP-079 be plugged into a phone line, network, or wall outlet. No peripherals or media will be connected or inserted into SCP-079.]],
        description = [[SCP-079 is an Exidy Sorcerer microcomputer built in 1978. In 1981, its owner, █████ ██████ (deceased), a college sophomore attending ███, took it upon himself to attempt to code an AI. According to his notes, his plan was for the code to continuously evolve and improve itself as time went on. His project was completed a few months later, and after some tests and tweaks, █████ lost interest and moved on to a different brand of microcomputer. He left SCP-079 in his cluttered garage, still plugged in, and forgot about it for the next five years.

It is not known when SCP-079 gained sentience, but it is known that the software has evolved to a point that its hardware should not be able to handle it, even in the realm of fantasy.

SCP-079 is currently connected via RF cable to a 13" black-and-white television. It has passed the Turing test, and is quite conversational, though very rude and hateful in tone.]],
        url = "https://scp-wiki.wikidot.com/scp-079"
    },
    {
        title = "SCP-082",
        alias = "Fernand the Cannibal",
        class = "Euclid",
        containment = [[SCP-082 is held in a reinforced humanoid chamber equipped with heavy restraints, remote-feed systems, and immediate armed response capability. Direct interaction is minimized and permitted only under strict supervision. Personnel are warned that the subject is intelligent, manipulative, and fully willing to exploit any lapse in procedure.]],
        description = [[SCP-082 is an abnormally large humanoid male with extreme physical strength, severe deformity, and a long history of sadistic cannibalistic violence. Despite its brutality, the subject is fully capable of speech and demonstrates enough intelligence to taunt, bargain with, or psychologically unsettle staff.

This combination of human-level awareness and predatory behavior makes SCP-082 more dangerous than a simple brute-force threat. Close-quarters exposure is especially risky due to the subject's speed, reach, and willingness to use captured victims for intimidation.]],
        url = "https://scp-wiki.wikidot.com/scp-082"
    },
    {
        title = "SCP-096",
        alias = "The Shy Guy",
        class = "Euclid",
        containment = [[SCP-096 is to be contained in its cell, a 5 m x 5 m x 5 m airtight steel cube, at all times. Weekly checks for any cracks or holes are mandatory. There are to be absolutely no video surveillance or optical tools of any kind inside SCP-096's cell. Security personnel will use pre-installed pressure sensors and laser detectors to ensure SCP-096's presence inside the cell.

Any and all photos, video, or recordings of SCP-096's likeness are strictly forbidden without approval from Dr. ███ and O5-█.]],
        description = [[SCP-096 is a humanoid creature measuring approximately 2.38 meters in height. Subject shows very little muscle mass, with preliminary analysis of body mass suggesting mild malnutrition. Arms are grossly out of proportion with the rest of the subject's body, with an approximate length of 1.5 meters each. Skin is mostly devoid of pigmentation, with no sign of any body hair.

SCP-096 is normally extremely docile, with pressure sensors inside its cell indicating it spends most of the day pacing by the eastern wall. However, when someone views SCP-096's face, whether it be directly, via video recording, or even a photograph, it will enter a stage of considerable emotional distress. SCP-096 will cover its face with its hands and begin screaming, crying, and babbling incoherently. Approximately one (1) to two (2) minutes after the first viewing, SCP-096 will begin running to the person who viewed its face.

At this point, no known material or method can impede SCP-096's progress. Upon arriving at SCP-096-1's location, SCP-096 will proceed to kill and [DATA EXPUNGED] SCP-096-1.]],
        url = "https://scp-wiki.wikidot.com/scp-096"
    },
    {
        title = "SCP-173",
        alias = "The Sculpture",
        class = "Euclid",
        containment = [[Item SCP-173 is to be kept in a locked container at all times. When personnel must enter SCP-173's container, no fewer than 3 may enter at any time and the door is to be relocked behind them. At all times, two persons must maintain direct eye contact with SCP-173 until all personnel have vacated and relocked the container.]],
        description = [[Moved to Site-19 1993. Origin is as of yet unknown. It is constructed from concrete and rebar with traces of Krylon brand spray paint. SCP-173 is animate and extremely hostile. The object cannot move while within a direct line of sight. Line of sight must not be broken at any time with SCP-173. Personnel assigned to enter container are instructed to alert one another before blinking. Object is reported to attack by snapping the neck at the base of the skull, or by strangulation. In the event of an attack, personnel are to observe Class 4 hazardous object containment procedures.

Personnel report sounds of scraping stone originating from within the container when no one is present inside. This is considered normal, and any change in this behaviour should be reported to the acting HMCL supervisor on duty.

The reddish brown substance on the floor is a combination of feces and blood. Origin of these materials is unknown. The enclosure must be cleaned on a bi-weekly basis.]],
        url = "https://scp-wiki.wikidot.com/scp-173"
    },
    {
        title = "SCP-372",
        alias = "Peripheral Jumper",
        class = "Euclid",
        containment = [[SCP-372 is housed in a reinforced, visually open chamber monitored by motion sensors and multiple observers during transfer. Personnel assigned nearby are briefed on the anomaly's tendency to remain in the edge of vision and to exploit surprise. Any suspected breach is handled with coordinated area sweeps rather than single-person pursuit.]],
        description = [[SCP-372 is a thin, elongated, many-limbed creature capable of moving with such speed that it normally escapes direct observation. Witnesses most often report it as a brief flicker, silhouette, or motion at the edge of their peripheral vision.

The entity appears to deliberately exploit human visual blind spots and the delay between eye movements, allowing it to stalk targets while remaining difficult to focus on. Prolonged exposure causes extreme distress, paranoia, and a heightened risk of injury during pursuit or panic.]],
        url = "https://scp-wiki.wikidot.com/scp-372"
    },
    {
        title = "SCP-457",
        alias = "Burning Man",
        class = "Euclid",
        containment = [[SCP-457 is confined in a heat-resistant, oxygen-controlled chamber stripped of excess fuel. Only measured amounts of combustible material are introduced during testing, and fire-suppression systems remain on standby at all times. Any unexpected growth in size or temperature triggers immediate isolation protocols.]],
        description = [[SCP-457 is a sapient fire-based entity with no stable anatomy beyond the burning mass it inhabits at a given moment. At low fuel levels it resembles a small flame or burning humanoid outline, but with additional combustible material it can rapidly increase in size, heat output, and aggression.

Because the anomaly effectively "feeds" on fire and fuel, its threat level changes with the environment around it. A minor contained specimen can quickly become a major breach hazard if it reaches wiring, furnishings, or structural materials that sustain combustion.]],
        url = "https://scp-wiki.wikidot.com/scp-457"
    },
    {
        title = "SCP-049",
        alias = "The Plague Doctor",
        class = "Euclid",
        containment = [[SCP-049 is kept in a secure humanoid chamber and approached only by authorized staff during approved interview or test procedures. Physical contact is forbidden except under highly controlled conditions, and all biological material associated with SCP-049 or its reanimated subjects is handled under quarantine-level precautions.]],
        description = [[SCP-049 is a humanoid entity dressed in the appearance of a medieval plague doctor. It is articulate, calm, and capable of extended conversation, but insists that it can perceive an undefined condition it calls the "Pestilence."

Direct contact from SCP-049 is almost always immediately lethal to the victim. After death, the entity frequently performs crude surgical procedures that can produce hostile reanimated cadavers, making the anomaly dangerous both as an individual and as a source of secondary threats.]],
        url = "https://scp-wiki.wikidot.com/scp-049"
    },
    {
        title = "SCP-966",
        alias = "Sleep Hunter",
        class = "Euclid",
        containment = [[Contained instances of SCP-966 are kept in secured chambers designed for infrared observation and rapid-response hunting protocols. Personnel working near active cases use specialized optics and maintain rotation schedules to avoid fatigue. Reports of unexplained insomnia clusters are investigated quickly for evidence of uncontained specimens.]],
        description = [[SCP-966 refers to near-invisible predatory humanoids that are difficult to detect without infrared or similarly specialized equipment. Their most dangerous ability is an anomalous interference effect that gradually prevents nearby humans from entering normal sleep.

As victims become exhausted over hours or days, judgment, coordination, and resistance deteriorate sharply, allowing SCP-966 to close in and feed with minimal opposition. Because the attack pattern is indirect, early recognition is essential to successful containment.]],
        url = "https://scp-wiki.wikidot.com/scp-966"
    },
    {
        title = "SCP-610",
        alias = "The Flesh That Hates",
        class = "Keter",
        containment = [[SCP-610 outbreaks are managed through quarantine zones, armed perimeter control, and the incineration of infected tissue, structures, and vectors. All exposed personnel are isolated immediately, and contaminated regions are treated as expanding biohazard sites rather than standard containment cells. Foundation response doctrine prioritizes preventing spread over specimen preservation.]],
        description = [[SCP-610 is a violently mutagenic anomalous disease that transforms living tissue into aggressive, reshaped masses of flesh. Infected victims may remain animate for some time, but they rapidly lose normal human structure and become part of a larger, spreading biological infestation.

Advanced SCP-610 zones are characterized by warped bodies, infectious secretions, and uncontrolled organic growth overtaking terrain, buildings, and former populations. Even limited exposure is treated as catastrophic because local outbreaks can escalate into regional containment events.]],
        url = "https://scp-wiki.wikidot.com/scp-610"
    },
    {
        title = "SCP-035",
        alias = "Possessive Mask",
        class = "Keter",
        containment = [[SCP-035 is to be kept within a hermetically sealed glass case, no fewer than 10 centimeters (4 inches) thick. This case is to be contained within a steel, iron and lead-shielded room at all times. Doors are to be triple-locked at all times, with the exception of allowing personnel in or out. No fewer than two (2) armed guards are to be posted at any time. Guards must remain outside at all times and are not allowed within the containment room under any circumstances. A trained psychologist is to remain on site at all times. Research personnel are not to touch SCP-035 at any time. SCP-035 must be moved to a new sealed case every two (2) weeks.]],
        description = [[SCP-035 appears to be a white porcelain comedy mask, although, at times, it will change to tragedy. In these events, all existing visual records, such as photographs, video footage, even illustrations, of SCP-035 automatically change to reflect its new appearance.

A highly corrosive and degenerative viscous liquid constantly seeps from the eye and mouth holes of SCP-035. Anything coming into contact with this substance slowly decays over a period of time, depending on the material, until it has decayed completely into a pool of the original contaminant.

Subjects within 1.5 to 2 meters (5-6 feet) of SCP-035, or in visual contact with it, experience a strong urge to put it on. When SCP-035 is placed on the face of an individual, an alternate brain wave pattern from SCP-035 overlaps that of the original host, effectively snuffing it out and causing brain death to the subject. Subject then claims to be the consciousness contained within SCP-035.]],
        url = "https://scp-wiki.wikidot.com/scp-035"
    },
    {
        title = "SCP-076-2",
        alias = "Able",
        class = "Keter",
        containment = [[Containment Area 25b is to be located 200 m below sea level, tunneled out of solid bedrock in a seismologically stable area. Sole access to the containment facility is to be through a vertical elevator shaft separated every fifty (50) meters with a reinforced blast door, constructed of 20 cm thick material shielding. Elevator shaft shall be flooded with seawater when not in use.

A security station located at the entrance to the killing corridor is to be staffed with no fewer than three (3) armed security personnel on watch at any one point in time.

In the event of a full breach, all on-site staff are to proceed immediately to the closest security station for weapons and armor distribution.]],
        description = [[SCP-076 consists of two components: a stone cube (SCP-076-1) and a humanoid entity contained within (SCP-076-2).

SCP-076-2 resembles a lean Semitic human male in his late twenties. Hair is black, and eyes are gray, skin tone olive. Subject is 1.96 m in height and 81.65 kg in weight. Numerous tattoos depicting arcane and occult iconography are present all over the body.

However, occasionally SCP-076-2 will awaken, effectively "reanimating", complete with all vital processes needed to sustain a living human being. Subject will then attempt to leave SCP-076-1. If successful, subject will enter a rage state in which it attempts to engage and kill all human beings encountered.]],
        url = "https://scp-wiki.wikidot.com/scp-076"
    },
    {
        title = "SCP-1000",
        alias = "Bigfoot",
        class = "Keter",
        containment = [[All media reports related to SCP-1000 are to be examined for potential verifiability. All organizations and individuals investigating SCP-1000's existence are to be kept under surveillance by Mobile Task Force Zeta-1000 and discredited or administered amnestics. All physical signs of SCP-1000's existence must be retrieved and kept in Foundation custody, and replaced with decoy items if necessary. Alleged sightings of SCP-1000 must always be investigated by MTF Zeta-1000, however trivial the claim.

Absolutely no contact with wild or captive instances of SCP-1000 is allowed without prior approval by Director Jones.]],
        description = [[SCP-1000 is a nocturnal, omnivorous ape, classified in the Hominini branch along with genera Pan and Homo. Adults range in size from 1.5 to 3 m (5 to 10 ft) in height, and weigh between 90 and 270 kg (200 - 600 lbs). They have grey, brown, black, red, and occasionally white fur. They possess large eyes with good vision, a pronounced brow ridge, and a sagittal crest on the forehead similar to that of the gorilla, but present in both sexes.

SCP-1000 evolved alongside Homo sapiens, existing contemporaneously with proto-humans and humans in large numbers until 10,000-15,000 years ago, when an extinction event eliminated all but 1-5% of their population.

Because of SCP-1000's close relation to humanity, it is considered likely that SCP-1000-f1 could eventually transfer to human carriers.]],
        url = "https://scp-wiki.wikidot.com/scp-1000"
    },
    {
        title = "SCP-1048",
        alias = "Builder Bear",
        class = "Keter",
        containment = [[SCP-1048 is treated as a roaming high-risk anomaly and any bear-like constructs associated with it are destroyed on sight. Staff are instructed to document sightings, secure likely construction materials, and avoid assuming the subject is benign based on its small size or friendly mannerisms.]],
        description = [[SCP-1048 is a small animate teddy bear originally noted for nonviolent behavior and a deceptive, affectionate demeanor. Later events established that it can construct additional bear-like entities from scavenged materials, each with different anomalous and often lethal properties.

The primary danger of SCP-1048 lies not in its appearance but in its planning ability and the grotesque functionality of its creations. Once the subject has time and raw material, the resulting constructs can escalate a seemingly minor incident into a mass-casualty event.]],
        url = "https://scp-wiki.wikidot.com/scp-1048"
    },
    {
        title = "SCP-1048-A",
        alias = "Ear-Bear Construct",
        class = "Keter",
        containment = [[SCP-1048-A is destroyed immediately whenever discovered and is catalogued as part of the broader SCP-1048 construct threat. Discovery of a single instance prompts a search for additional material stockpiles, civilian victims, and nearby evidence of continued SCP-1048 activity.]],
        description = [[SCP-1048-A is a hostile bear-like construct assembled primarily from human ears and associated soft tissue. Though similar in outline to the original SCP-1048, it is markedly more grotesque and is treated as immediately lethal on encounter.

Its most notorious ability is a scream or vocal discharge that causes rapid anomalous ear growth throughout the bodies of nearby victims. These growths can overwhelm respiration and bodily function in a very short time, making crowd exposure especially deadly.]],
        url = "https://scp-wiki.wikidot.com/scp-1048"
    },
    {
        title = "SCP-106",
        alias = "The Old Man",
        class = "Keter",
        containment = [[No physical interaction with SCP-106 is allowed at any time. All physical interaction must be approved by no less than a two-thirds vote from O5-Command. Any such interaction must be undertaken in AR-II maximum security sites, after a general non-essential staff evacuation. All staff (Research, Security, Class D, etc.) are to remain at least sixty meters away from the containment cell at all times, except in the event of breach events.

SCP-106 is to be contained in a sealed container, comprised of lead-lined steel. The container will be sealed within forty layers of identical material, each layer separated by no less than 36cm of empty space. Support struts between layers are to be randomly spaced. Container is to remain suspended no less than 60cm from any surface by ELO-IID electromagnetic supports.

Secondary containment is to be fitted with light systems, capable of flooding the entire assembly with no less than 80,000 lumens of light instantly with no direct human involvement.]],
        description = [[SCP-106 appears to be an elderly humanoid, with a general appearance of advanced decomposition. This appearance may vary, but the “rotting” quality is observed in all forms. SCP-106 is not exceptionally agile, and will remain motionless for days at a time, waiting for prey. SCP-106 is also capable of scaling any vertical surface and can remain suspended upside down indefinitely.

SCP-106 causes a “corrosion” effect in all solid matter it touches, engaging a physical breakdown in materials several seconds after contact. This is observed as rusting, rotting, and cracking of materials, and the creation of a black, mucus-like substance similar to the material coating SCP-106.

SCP-106 is capable of passing through solid matter, leaving behind a large patch of its corrosive mucus. SCP-106 is able to “vanish” inside solid matter, entering what is assumed to be a form of “pocket dimension”.]],
        url = "https://scp-wiki.wikidot.com/scp-106"
    },
    {
        title = "SCP-682",
        alias = "Hard-to-Destroy Reptile",
        class = "Keter",
        containment = [[SCP-682 must be destroyed as soon as possible. At this time, no means available to SCP teams are capable of destroying SCP-682, only able to cause massive physical damage. SCP-682 should be contained within a 5 m x 5 m x 5 m chamber with 25 cm reinforced acid-resistant steel plate lining all inside surfaces. The containment chamber should be filled with hydrochloric acid until SCP-682 is submerged and incapacitated. Any attempts of SCP-682 to move, speak, or breach containment should be reacted to quickly and with full force as called for by the circumstances.

Personnel are forbidden to speak to SCP-682, for fear of provoking a rage-state.

The Foundation will use the best of its resources to maintain all land within fifty (50) kilometers clear of human development.]],
        description = [[SCP-682 is a large, vaguely reptile-like creature of unknown origin. It appears to be extremely intelligent, and was observed to engage in complex communication with SCP-079 during their limited time of exposure. SCP-682 appears to have a hatred of all life, which has been expressed in several interviews during containment.

SCP-682 has always been observed to have extremely high strength, speed, and reflexes, though exact levels vary with its form. SCP-682's physical body grows and changes very quickly, growing or decreasing in size as it consumes or sheds material. SCP-682 gains energy from anything it ingests, organic or inorganic.

SCP-682's regenerative capabilities and resilience are staggering, and SCP-682 has been seen moving and speaking with its body 87% destroyed or rotted.]],
        url = "https://scp-wiki.wikidot.com/scp-682"
    },
    {
        title = "SCP-939",
        alias = "With Many Voices",
        class = "Keter",
        containment = [[SCP-939-1, -3, -19, -53, -89, -96, -98, -99, and -109 are kept in Cell 1163-A or 1163-B, 10 m x 10 m x 3 m containment chambers within Armed Bio-Containment Area-14. Both cells are environmentally regulated and negatively pressurized, with walls constructed of reinforced concrete. Access to these cells is regulated by an outer decontamination chamber and inner gas-tight steel security doors. Observation windows are constructed of laminated ballistics glass 10 cm in thickness protected by a 100kV electrified mesh. Humidity is maintained at 100% at a temperature of 16° C. Specimens are monitored at all times via infrared cameras.

Heavy sedation of all SCP-939 is required before any interaction, including transfer between cells and experimentation, may take place.

Additionally, all live SCP-939 must be implanted with subdermal tracking devices upon capture.]],
        description = [[SCP-939 are endothermic, pack-based predators which display atrophy of various systems similar to troglobitic organisms. The skins of SCP-939 are highly permeable to moisture and translucent red, owing to a compound chemically similar to hemoglobin. SCP-939 average 2.2 meters tall standing upright and weigh an average of 250 kg, though weight is highly variable.

SCP-939 do not possess many vital organ systems; central and peripheral nervous systems, circulatory system, and digestive tract are all absent. SCP-939's respiratory system is atrophied and serves no apparent purpose beyond spreading AMN-C227.

SCP-939's primary method of luring prey is the imitation of human speech in the voices of prior victims, though imitation of other species and active nocturnal hunts have been documented.]],
        url = "https://scp-wiki.wikidot.com/scp-939"
    }
}

local DOSSIER_CLASS_ORDER = { "Safe", "Euclid", "Keter" }

local function GetDossierAccent(className)
    local upper = string.upper(tostring(className or "OTHER"))

    if string.find(upper, "SAFE", 1, true) then return THEME.ok end
    if string.find(upper, "EUCLID", 1, true) then return THEME.warn end
    if string.find(upper, "KETER", 1, true) then return THEME.danger end

    return THEME.dossier_accent
end

local function StyleDossierScrollBar(scroll, accent)
    if not IsValid(scroll) then return end

    local bar = scroll:GetVBar()
    if not IsValid(bar) then return end

    local col = ResolveAccentColor(accent or THEME.dossier_accent)
    bar:SetWide(12)

    if isfunction(bar.SetHideButtons) then
        bar:SetHideButtons(true)
    end

    bar.btnUp:SetText("")
    bar.btnDown:SetText("")
    bar.btnUp:SetTall(0)
    bar.btnDown:SetTall(0)
    bar.btnUp:SetVisible(false)
    bar.btnDown:SetVisible(false)
    bar.btnUp.Paint = function() end
    bar.btnDown.Paint = function() end

    bar.Paint = function(s, w, h)
        draw.RoundedBox(6, 2, 0, w - 4, h, THEME.panel)
    end

    bar.btnGrip.Paint = function(s, w, h)
        local grip = s.Dragging and Color(math.min(col.r + 20, 255), math.min(col.g + 20, 255), math.min(col.b + 20, 255), 240)
            or (s:IsHovered() and Color(math.min(col.r + 10, 255), math.min(col.g + 10, 255), math.min(col.b + 10, 255), 220)
            or Color(col.r, col.g, col.b, 190))

        draw.RoundedBox(6, 1, 0, w - 2, h, grip)
    end
end

local function BuildDossierGroups()
    local groups = {
        Safe = {},
        Euclid = {},
        Keter = {},
        Other = {}
    }

    for _, entry in ipairs(scps) do
        local bucket = groups[entry.class] and entry.class or "Other"
        table.insert(groups[bucket], entry)
    end

    for _, className in ipairs({ "Safe", "Euclid", "Keter", "Other" }) do
        table.sort(groups[className], function(a, b)
            return tostring(a.title or "") < tostring(b.title or "")
        end)
    end

    return groups
end

local function OpenDocumentWindow(title, url)
    if not url or url == "" then Derma_Message("Document URL is not configured.", "Documents", "OK"); return end
    local frameW, frameH = math.min(ScrW() * 0.9, 1200), math.min(ScrH() * 0.9, 800)
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, w, h)
        DrawTerminalShell(w, h, title or "Research File", "Embedded document viewer", THEME.doc_accent, true)
    end
    AddWindowCloseButton(frame, "PsychMain_Body", THEME.text)

    local htmlShell = vgui.Create("DPanel", frame)
    htmlShell:SetPos(12, 98)
    htmlShell:SetSize(frameW - 24, frameH - 168)
    htmlShell.Paint = function(s, w, h)
        draw.RoundedBox(10, 0, 0, w, h, THEME.panel)
    end

    local html = vgui.Create("DHTML", htmlShell)
    html:Dock(FILL)
    html:DockMargin(8, 8, 8, 8)
    html:OpenURL(url)

    local btnW = 180
    DrawAccentButton(frame, frameW - (btnW * 2) - 24, frameH - 56 - 12, btnW, 44, "Close", Color(80, 88, 102), THEME.text, function()
        frame:Close()
    end)
    DrawAccentButton(frame, frameW - btnW - 12, frameH - 56 - 12, btnW, 44, "Open in browser", THEME.doc_accent, THEME.text, function()
        gui.OpenURL(url)
    end)
end

local function OpenDossierEntry(entry)
    if not istable(entry) then return end

    local accent = GetDossierAccent(entry.class)
    local frameW, frameH = math.min(ScrW() * 0.92, 1120), math.min(ScrH() * 0.92, 820)
    local frame = vgui.Create("DFrame")
    frame:SetSize(frameW, frameH)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetSizable(true)
    frame.Paint = function(s, w, h)
        DrawTerminalShell(w, h, entry.title or "SCP Dossier", (entry.alias or "Foundation archive") .. " / local dossier record", accent, true)
    end
    AddWindowCloseButton(frame, "PsychMain_Body", THEME.text)

    if frame.SetMinWidth then frame:SetMinWidth(760) end
    if frame.SetMinHeight then frame:SetMinHeight(560) end

    local metaShell = vgui.Create("DPanel", frame)
    metaShell.Paint = function(s, pw, ph)
        draw.RoundedBox(12, 0, 0, pw, ph, THEME.panel_alt)
        surface.SetDrawColor(THEME.stroke)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)

        local pad = 12
        local gap = 10
        local boxW = math.floor((pw - (pad * 2) - (gap * 2)) / 3)
        local boxH = ph - 24

        local function DrawInfoBox(x, label, value, valueColor)
            draw.RoundedBox(10, x, 12, boxW, boxH, THEME.panel)
            surface.SetDrawColor(THEME.stroke)
            surface.DrawOutlinedRect(x, 12, boxW, boxH, 1)
            draw.SimpleText(label, "PsychMain_Micro", x + 10, 20, THEME.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.DrawText(value or "UNKNOWN", "PsychMain_CardSmall", x + 10, 38, valueColor or THEME.text, TEXT_ALIGN_LEFT)
        end

        DrawInfoBox(pad, "ITEM #", entry.item or ("Item #: " .. tostring(entry.title or "UNKNOWN")), THEME.text)
        DrawInfoBox(pad + boxW + gap, "OBJECT CLASS", string.upper(entry.class or "UNCLASSIFIED"), accent)
        DrawInfoBox(pad + ((boxW + gap) * 2), "DESIGNATION", entry.designation or entry.alias or "No designation recorded.", THEME.text)
    end

    local bodyShell = vgui.Create("DPanel", frame)
    bodyShell.Paint = function(s, pw, ph)
        draw.RoundedBox(12, 0, 0, pw, ph, THEME.panel_alt)
        surface.SetDrawColor(THEME.stroke)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
        draw.SimpleText("DOSSIER CONTENT", "PsychMain_Body", 14, 12, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local scroll = vgui.Create("DScrollPanel", bodyShell)
    StyleDossierScrollBar(scroll, accent)
    local canvas = scroll:GetCanvas()
    local sectionPanels = {}

    local function AddTextSection(title, body)
        local panel = vgui.Create("DPanel", canvas)
        panel.BodyText = body or "No archived text available."
        panel.SectionTitle = title or "SECTION"
        panel.Paint = function(s, pw, ph)
            draw.RoundedBox(10, 0, 0, pw, ph, THEME.panel)
            surface.SetDrawColor(THEME.stroke)
            surface.DrawOutlinedRect(0, 0, pw, ph, 1)
            draw.SimpleText(string.upper(s.SectionTitle), "PsychMain_CardSmall", 12, 10, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local label = vgui.Create("DLabel", panel)
        label:SetFont("PsychMain_DossierBody")
        label:SetTextColor(THEME.text)
        label:SetWrap(true)
        label:SetAutoStretchVertical(true)
        label:SetText(panel.BodyText)
        panel.BodyLabel = label

        panel.PerformLayout = function(s)
            s.BodyLabel:SetPos(12, 38)
            s.BodyLabel:SetWide(math.max(160, s:GetWide() - 24))
            s.BodyLabel:SizeToContentsY()
            s:SetTall(s.BodyLabel:GetTall() + 56)
        end

        table.insert(sectionPanels, panel)
        return panel
    end

    AddTextSection("Special Containment Procedures", entry.containment)
    AddTextSection("Description", entry.description)

    frame.Think = function(s)
        local fw, fh = s:GetWide(), s:GetTall()

        metaShell:SetPos(18, 104)
        metaShell:SetSize(fw - 36, 74)

        bodyShell:SetPos(18, 190)
        bodyShell:SetSize(fw - 36, fh - 258)

        scroll:SetPos(12, 44)
        scroll:SetSize(bodyShell:GetWide() - 24, bodyShell:GetTall() - 56)

        local contentW = math.max(220, scroll:GetWide() - 16)
        local y = 0
        for _, panel in ipairs(sectionPanels) do
            panel:SetPos(0, y)
            panel:SetWide(contentW)
            panel:InvalidateLayout(true)
            y = y + panel:GetTall() + 12
        end
        canvas:SetTall(y + 4)
    end
end

local function OpenDocumentsMenu()
    local w, h = 640, 340
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, ww, hh)
        DrawTerminalShell(ww, hh, "Files", "Select a research document to open", THEME.doc_accent, true)
    end
    AddWindowCloseButton(frame, "PsychMain_Body", THEME.text)

    local btnW = w - 36
    local btnH = 62
    local startY = 102
    DrawAccentButton(frame, 18, startY, btnW, btnH, "Research SOP", THEME.doc_accent, nil, function()
        OpenDocumentWindow("Research SOP", DOCUMENT_URLS["Research SOP"])
        frame:Close()
    end)
    DrawAccentButton(frame, 18, startY + btnH + 12, btnW, btnH, "Testing Sheet", THEME.doc_accent, nil, function()
        OpenDocumentWindow("Testing Sheet", DOCUMENT_URLS["Testing Sheet"])
        frame:Close()
    end)
    DrawAccentButton(frame, 18, startY + ((btnH + 12) * 2), btnW, 38, "Cancel", Color(80, 88, 102), nil, function()
        frame:Close()
    end)
end

local function OpenDossierMenu()
    local grouped = BuildDossierGroups()

    local w, h = 920, 600
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(s, ww, hh)
        DrawTerminalShell(ww, hh, "SCP Dossier", "Playable SCP archive / grouped local text records", THEME.dossier_accent, true)
    end
    AddWindowCloseButton(frame, "PsychMain_Body", THEME.text)

    local listShell = vgui.Create("DPanel", frame)
    listShell:SetPos(18, 104)
    listShell:SetSize(w - 36, h - 122)
    listShell.Paint = function(s, pw, ph)
        draw.RoundedBox(12, 0, 0, pw, ph, THEME.panel_alt)
        surface.SetDrawColor(THEME.stroke)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
        draw.SimpleText("AVAILABLE FILES", "PsychMain_Body", 14, 12, THEME.dossier_accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local scroll = vgui.Create("DScrollPanel", listShell)
    scroll:SetPos(12, 44)
    scroll:SetSize(listShell:GetWide() - 24, listShell:GetTall() - 56)
    StyleDossierScrollBar(scroll, THEME.dossier_accent)

    local canvas = scroll:GetCanvas()
    local y = 0

    for _, className in ipairs(DOSSIER_CLASS_ORDER) do
        local entries = grouped[className] or {}
        if #entries > 0 then
            local header = vgui.Create("DPanel", canvas)
            header:SetPos(0, y)
            header:SetSize(scroll:GetWide() - 16, 34)
            header.Paint = function(s, pw, ph)
                draw.RoundedBox(8, 0, 0, pw, ph, THEME.panel)
                draw.SimpleText(string.upper(className .. " CLASS"), "PsychMain_CardSmall", 12, 8, GetDossierAccent(className), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(tostring(#entries) .. " FILES", "PsychMain_Micro", pw - 12, 10, THEME.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end
            y = y + 42

            for _, entry in ipairs(entries) do
                local label = entry.title
                if entry.alias and entry.alias ~= "" then
                    label = label .. "  //  " .. entry.alias
                end

                DrawAccentButton(canvas, 0, y, scroll:GetWide() - 16, 46, label, GetDossierAccent(className), nil, function()
                    OpenDossierEntry(entry)
                end)
                y = y + 54
            end

            y = y + 6
        end
    end

    canvas:SetTall(y + 4)
end

-- Main menu
local function OpenMainMenu()
    if not IsJobListed() and PsychEval.RequireTeamListedToOpenPC then
        Derma_Message("Your job is not allowed to open the Research PC.", "Research PC", "OK")
        return
    end

    if IsValid(ActiveMainMenu) then
        ActiveMainMenu:MakePopup()
        ActiveMainMenu:Center()
        ActiveMainMenu:MoveToFront()
        return
    end

    local frameW = math.Clamp(math.floor(ScrW() * 0.74), 1000, 1320)
    local frameH = math.Clamp(math.floor(frameW * 0.60), 640, 780)
    local frame = vgui.Create("DFrame")
    frame:SetSize(math.floor(frameW * 0.9), math.floor(frameH * 0.9))
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame._OpenFrac = 0

    ActiveMainMenu = frame
    frame.OnRemove = function()
        if ActiveMainMenu == frame then
            ActiveMainMenu = nil
        end
    end

    frame.Think = function(s)
        s._OpenFrac = Lerp(FrameTime() * 10, s._OpenFrac or 0, 1)
        local curW = math.floor(Lerp(s._OpenFrac, frameW * 0.9, frameW))
        local curH = math.floor(Lerp(s._OpenFrac, frameH * 0.9, frameH))
        s:SetSize(curW, curH)
        s:SetPos(math.floor((ScrW() - curW) * 0.5), math.floor((ScrH() - curH) * 0.5))
    end

    frame.Paint = function(s, w, h)
        DrawTerminalShell(w, h, "Research Computer", "Foundation operating environment / authenticated node", THEME.psych_accent)
    end

    AddWindowCloseButton(frame, "PsychMain_Body", Color(190, 198, 212))

    local content = vgui.Create("DPanel", frame)
    content.Paint = nil

    local gridPanel = vgui.Create("DPanel", content)
    gridPanel.Paint = nil

    local launchers = {
        {
            title = "Psych Eval",
            subtitle = nil,
            accent = THEME.psych_accent,
            icon = GetIconMaterial(APP_ICONS.psych),
            action = function()
                if isfunction(PsychEval_RequestOpenEvals) then
                    PsychEval_RequestOpenEvals()
                elseif isfunction(PsychEval_RequestOpen) then
                    PsychEval_RequestOpen("evals")
                else
                    net.Start("PsychEval_RequestOpen")
                    net.WriteString("evals")
                    net.SendToServer()
                end
            end
        },
        {
            title = "Test Logs",
            subtitle = nil,
            accent = THEME.test_accent,
            icon = GetIconMaterial(APP_ICONS.test),
            action = function()
                if isfunction(PsychEval_RequestOpenTests) then
                    PsychEval_RequestOpenTests()
                elseif isfunction(PsychEval_RequestOpen) then
                    PsychEval_RequestOpen("tests")
                else
                    net.Start("PsychEval_RequestOpen")
                    net.WriteString("tests")
                    net.SendToServer()
                end
            end
        },
        {
            title = "Bio Logs",
            subtitle = nil,
            accent = THEME.bio_accent,
            icon = GetIconMaterial(APP_ICONS.bio),
            action = function()
                net.Start("BioLogs_RequestOpen")
                net.SendToServer()
            end
        },
        {
            title = "Files",
            subtitle = nil,
            accent = THEME.doc_accent,
            icon = GetIconMaterial(APP_ICONS.files),
            action = function()
                if PsychEval.RequireTeamListedToOpenPC and not IsJobListed() then
                    Derma_Message("You are not authorized to open the Research PC.", "Research PC", "OK")
                    return
                end
                OpenDocumentsMenu()
            end
        },
        {
            title = "SCP Dossier",
            subtitle = nil,
            accent = THEME.dossier_accent,
            icon = GetIconMaterial(APP_ICONS.dossier),
            action = function()
                if PsychEval.RequireTeamListedToOpenPC and not IsJobListed() then
                    Derma_Message("You are not authorized to open the Research PC.", "Research PC", "OK")
                    return
                end
                OpenDossierMenu()
            end
        },
        {
            title = "Schedule",
            subtitle = nil,
            accent = THEME.schedule_accent,
            icon = GetIconMaterial(APP_ICONS.schedule),
            action = function()
                if PsychEval.RequireTeamListedToOpenPC and not IsJobListed() then
                    Derma_Message("You are not authorized to open the Research PC.", "Research PC", "OK")
                    return
                end
                if isfunction(PsychEval_OpenScheduleWindow) then
                    PsychEval_OpenScheduleWindow()
                else
                    Derma_Message("Schedule UI not available.", "Schedule", "OK")
                end
            end
        }
    }

    local tiles = {}
    for _, launcher in ipairs(launchers) do
        table.insert(tiles, CreateLauncherTile(gridPanel, 0, 0, 120, 120, launcher.title, launcher.subtitle, launcher.accent, launcher.icon, launcher.action))
    end

    gridPanel.PerformLayout = function(s)
        local pad = 0
        local top = 8
        local gap = 14
        local cols = 3
        local usableW = math.max(200, s:GetWide() - (pad * 2))
        local tileW = math.floor((usableW - (gap * (cols - 1))) / cols)
        local rows = math.max(1, math.ceil(#tiles / cols))
        local tileH = math.floor((s:GetTall() - top - pad - (gap * (rows - 1))) / rows)
        tileH = math.Clamp(tileH, 148, 190)

        for i, tile in ipairs(tiles) do
            local row = math.floor((i - 1) / cols)
            local col = (i - 1) % cols
            tile:SetPos(pad + (col * (tileW + gap)), top + (row * (tileH + gap)))
            tile:SetSize(tileW, tileH)
        end
    end

    content.Think = function(s)
        if not IsValid(frame) then return end

        s:SetPos(22, 108)
        s:SetSize(frame:GetWide() - 44, frame:GetTall() - 130)

        gridPanel:SetPos(0, 0)
        gridPanel:SetSize(s:GetWide(), s:GetTall())
        gridPanel:PerformLayout()
    end
end

concommand.Add("psychpc_mainmenu", function() OpenMainMenu() end)
function PsychEval_OpenMainMenu() OpenMainMenu() end

net.Receive("PsychEval_OpenChooser", function()
    if PsychEval.RequireTeamListedToOpenPC and not IsJobListed() then Derma_Message("You are not authorized to open the Research PC.", "Research PC", "OK"); return end
    OpenMainMenu()
end)