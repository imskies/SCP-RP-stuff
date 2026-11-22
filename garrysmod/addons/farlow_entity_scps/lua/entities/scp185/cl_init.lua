-- cl_init.lua (frame size 280x520)
include("shared.lua")

if CLIENT then
    -- Fonts
    surface.CreateFont("SCP185_Display", { font = "Courier New", size = 28, weight = 800, antialias = true })
    surface.CreateFont("SCP185_Button", { font = "Courier New", size = 16, weight = 700, antialias = true })
    surface.CreateFont("SCP185_Title", { font = "Arial", size = 18, weight = 900, antialias = true })

    local RADIO_SOUND_VALID = "ambient/levels/citadel/strange_talk4.wav"
    local RADIO_SOUND_INVALID = "ambient/levels/citadel/weapon_disintegrate1.wav"

    -- Optional lightweight preview table (leave empty or add a few entries)
    local historicalCodes = {
["1700"] = "Radio transmission: European powers adjust borders after the War of the Spanish Succession begins to simmer.",
["1701"] = "Radio transmission: War of the Spanish Succession escalates across Europe.",
["1702"] = "Radio transmission: Major naval engagements occur as alliances shift.",
["1703"] = "Radio transmission: Great Storm devastates parts of northern Europe.",
["1704"] = "Radio transmission: Allied forces win key battles in the Low Countries.",
["1705"] = "Radio transmission: Political realignments continue across continental courts.",
["1706"] = "Radio transmission: Siege warfare and territorial disputes dominate the continent.",
["1707"] = "Radio transmission: Acts of Union unite England and Scotland into Great Britain.",
["1708"] = "Radio transmission: Military campaigns continue across Europe.",
["1709"] = "Radio transmission: Harsh winter and famine affect large regions of Europe.",
["1710"] = "Radio transmission: Dynastic conflicts and shifting alliances persist.",
["1711"] = "Radio transmission: Peace negotiations begin to take shape among warring states.",
["1712"] = "Radio transmission: Political intrigue and succession issues influence diplomacy.",
["1713"] = "Radio transmission: Treaties redraw borders and end major continental conflicts.",
["1714"] = "Radio transmission: New monarchs ascend and treaties reshape Europe.",
["1715"] = "Radio transmission: Regional uprisings and succession disputes continue.",
["1716"] = "Radio transmission: Military reforms and border skirmishes occur.",
["1717"] = "Radio transmission: Maritime trade expands; piracy remains a concern.",
["1718"] = "Radio transmission: Naval battles and anti‑piracy efforts intensify.",
["1719"] = "Radio transmission: Cultural and scientific exchanges increase across Europe.",
["1720"] = "Radio transmission: Economic bubbles and financial crises affect markets.",
["1721"] = "Radio transmission: Treaties stabilize some regions after years of conflict.",
["1722"] = "Radio transmission: Exploration and colonial expansion continue overseas.",
["1723"] = "Radio transmission: Royal courts consolidate power and influence.",
["1724"] = "Radio transmission: Regional conflicts flare in parts of Europe and Asia.",
["1725"] = "Radio transmission: Advances in navigation and trade routes progress.",
["1726"] = "Radio transmission: Diplomatic marriages and alliances shift power balances.",
["1727"] = "Radio transmission: Scientific inquiry and salons grow in prominence.",
["1728"] = "Radio transmission: Trade and cultural exchange expand between continents.",
["1729"] = "Radio transmission: Local uprisings and economic unrest occur in several regions.",
["1730"] = "Radio transmission: Colonial competition intensifies among European powers.",
["1731"] = "Radio transmission: Agricultural and industrial practices slowly evolve.",
["1732"] = "Radio transmission: Political maneuvering continues in royal courts.",
["1733"] = "Radio transmission: Maritime commerce and shipbuilding advance.",
["1734"] = "Radio transmission: Regional wars and border disputes persist.",
["1735"] = "Radio transmission: Scientific societies and learned academies grow.",
["1736"] = "Radio transmission: Trade routes expand into new territories.",
["1737"] = "Radio transmission: Cultural movements and artistic patronage flourish.",
["1738"] = "Radio transmission: Local conflicts and power struggles continue.",
["1739"] = "Radio transmission: War breaks out in parts of Europe and colonies.",
["1740"] = "Radio transmission: Succession crises and continental wars reshape borders.",
["1741"] = "Radio transmission: Military campaigns and sieges mark the year.",
["1742"] = "Radio transmission: Alliances shift as battles continue across regions.",
["1743"] = "Radio transmission: Naval engagements and colonial skirmishes occur.",
["1744"] = "Radio transmission: Diplomatic efforts attempt to curb widespread conflict.",
["1745"] = "Radio transmission: Rebellions and uprisings challenge established rule.",
["1746"] = "Radio transmission: Treaties and settlements slowly restore order.",
["1747"] = "Radio transmission: Trade and exploration resume in calmer seas.",
["1748"] = "Radio transmission: Peace treaties redraw maps and end major wars.",
["1749"] = "Radio transmission: Economic recovery and cultural revival begin.",
["1750"] = "Radio transmission: Enlightenment ideas spread through salons and print.",
["1751"] = "Radio transmission: Scientific and philosophical discourse gains momentum.",
["1752"] = "Radio transmission: Calendar reforms and administrative changes implemented.",
["1753"] = "Radio transmission: Botanical and scientific expeditions catalog new species.",
["1754"] = "Radio transmission: Colonial tensions foreshadow larger conflicts.",
["1755"] = "Radio transmission: Major earthquake and urban disasters prompt rebuilding.",
["1756"] = "Radio transmission: Global conflict erupts as colonial powers clash.",
["1757"] = "Radio transmission: Large battles and territorial shifts occur worldwide.",
["1758"] = "Radio transmission: Military campaigns continue across continents.",
["1759"] = "Radio transmission: Cultural achievements and scientific advances noted.",
["1760"] = "Radio transmission: Dynastic politics and colonial administration evolve.",
["1761"] = "Radio transmission: Naval power and trade dominance remain central.",
["1762"] = "Radio transmission: Political reforms and palace intrigues shape policy.",
["1763"] = "Radio transmission: Treaties conclude major wars and redistribute colonies.",
["1764"] = "Radio transmission: Economic and social reforms begin in several states.",
["1765"] = "Radio transmission: Colonial unrest grows in response to taxation policies.",
["1766"] = "Radio transmission: Legal reforms and public debate increase civic awareness.",
["1767"] = "Radio transmission: Trade and industrial techniques slowly modernize.",
["1768"] = "Radio transmission: Exploration and scientific voyages set out to sea.",
["1769"] = "Radio transmission: Technological innovations begin to influence industry.",
["1770"] = "Radio transmission: Political tensions and protests rise in urban centers.",
["1771"] = "Radio transmission: Cultural and intellectual movements gain followers.",
["1772"] = "Radio transmission: Partitions and territorial deals reshape regions.",
["1773"] = "Radio transmission: Public unrest and protests challenge colonial rule.",
["1774"] = "Radio transmission: Political assemblies and calls for reform increase.",
["1775"] = "Radio transmission: Armed conflict begins in North America.",
["1776"] = "Radio transmission: Declaration of independence proclaimed by American colonies.",
["1777"] = "Radio transmission: Revolutionary battles and alliances form.",
["1778"] = "Radio transmission: International support shifts the balance of conflict.",
["1779"] = "Radio transmission: Campaigns and sieges continue across theaters of war.",
["1780"] = "Radio transmission: Naval battles and privateering affect trade routes.",
["1781"] = "Radio transmission: Decisive military engagements influence independence movements.",
["1782"] = "Radio transmission: Negotiations and peace talks begin to take shape.",
["1783"] = "Radio transmission: Treaties formalize independence and redraw maps.",
["1784"] = "Radio transmission: New governments and constitutions are drafted.",
["1785"] = "Radio transmission: Economic rebuilding and trade normalization proceed.",
["1786"] = "Radio transmission: Political reform and public debate continue.",
["1787"] = "Radio transmission: Constitutional conventions and legal frameworks form.",
["1788"] = "Radio transmission: Ratification processes and political consolidation occur.",
["1789"] = "Radio transmission: Revolution erupts and monarchies face upheaval.",
["1790"] = "Radio transmission: Political turmoil and reform movements spread.",
["1791"] = "Radio transmission: New rights and declarations influence governance.",
["1792"] = "Radio transmission: War and internal conflict mark the year.",
["1793"] = "Radio transmission: Political purges and radical changes reshape nations.",
["1794"] = "Radio transmission: Counterrevolutionary efforts and stabilization attempts occur.",
["1795"] = "Radio transmission: New constitutions and treaties attempt to restore order.",
["1796"] = "Radio transmission: Military campaigns and leadership changes continue.",
["1797"] = "Radio transmission: Naval power and trade disputes remain central.",
["1798"] = "Radio transmission: Regional conflicts and colonial struggles persist.",
["1799"] = "Radio transmission: Political coups and leadership shifts alter the landscape.",
["1800"] = "Radio transmission: New century begins amid political and social change.",
["1801"] = "Radio transmission: Diplomatic realignments and treaties shape Europe.",
["1802"] = "Radio transmission: Short-lived peace and reorganization follow major wars.",
["1803"] = "Radio transmission: Renewed conflict erupts across the continent.",
["1804"] = "Radio transmission: Empires and new regimes consolidate power.",
["1805"] = "Radio transmission: Major naval and land battles define the era.",
["1806"] = "Radio transmission: Political restructuring and dissolutions occur.",
["1807"] = "Radio transmission: Trade embargoes and maritime law impact commerce.",
["1808"] = "Radio transmission: National uprisings and resistance movements grow.",
["1809"] = "Radio transmission: Political reforms and leadership changes continue.",
["1810"] = "Radio transmission: Independence movements gain momentum in colonies.",
["1811"] = "Radio transmission: Military campaigns and revolts shape regional politics.",
["1812"] = "Radio transmission: Large‑scale wars and invasions mark the year.",
["1813"] = "Radio transmission: Coalition forces push back invading armies.",
["1814"] = "Radio transmission: Treaties and congresses attempt to restore balance.",
["1815"] = "Radio transmission: Decisive battles and final settlements redraw Europe.",
["1816"] = "Radio transmission: Climate anomalies and economic hardship follow wars.",
["1817"] = "Radio transmission: Political restoration and conservative order take hold.",
["1818"] = "Radio transmission: Cultural exchange and industrial beginnings continue.",
["1819"] = "Radio transmission: Social unrest and reform movements emerge.",
["1820"] = "Radio transmission: Independence and constitutional changes occur worldwide.",
["1821"] = "Radio transmission: Revolutionary movements and new states form.",
["1822"] = "Radio transmission: National consolidation and diplomatic recognition proceed.",
["1823"] = "Radio transmission: Doctrines and foreign policy shape hemispheric relations.",
["1824"] = "Radio transmission: Political contests and elections influence governance.",
["1825"] = "Radio transmission: Industrial and transport innovations begin to spread.",
["1826"] = "Radio transmission: Cultural and scientific societies expand influence.",
["1827"] = "Radio transmission: Naval and land conflicts continue in regional theaters.",
["1828"] = "Radio transmission: Political reform and modernization efforts increase.",
["1829"] = "Radio transmission: Infrastructure projects and rail beginnings emerge.",
["1830"] = "Radio transmission: Revolutions and uprisings reshape several nations.",
["1831"] = "Radio transmission: Social reform and public health movements grow.",
["1832"] = "Radio transmission: Political reform acts and public debate intensify.",
["1833"] = "Radio transmission: Industrialization accelerates in urban centers.",
["1834"] = "Radio transmission: Labor movements and social change begin to organize.",
["1835"] = "Radio transmission: Scientific exploration and mapping expand knowledge.",
["1836"] = "Radio transmission: Independence and territorial conflicts continue.",
["1837"] = "Radio transmission: New monarchs and political transitions occur.",
["1838"] = "Radio transmission: Social reform and educational initiatives spread.",
["1839"] = "Radio transmission: Technological innovations in transport and communication emerge.",
["1840"] = "Radio transmission: Colonial expansion and trade intensify.",
["1841"] = "Radio transmission: Political consolidation and economic growth continue.",
["1842"] = "Radio transmission: Treaties and trade agreements reshape commerce.",
["1843"] = "Radio transmission: Cultural movements and literary works gain prominence.",
["1844"] = "Radio transmission: Telegraphy and early communication technologies develop.",
["1845"] = "Radio transmission: Famine and migration affect large populations.",
["1846"] = "Radio transmission: Wars and territorial disputes mark the year.",
["1847"] = "Radio transmission: Medical and scientific advances begin to take hold.",
["1848"] = "Radio transmission: Revolutions and calls for liberal reform sweep Europe.",
["1849"] = "Radio transmission: Political exiles and reform movements continue.",
["1850"] = "Radio transmission: Industrial expansion and urbanization accelerate.",
["1851"] = "Radio transmission: International exhibitions showcase technological progress.",
["1852"] = "Radio transmission: Political consolidation and social change proceed.",
["1853"] = "Radio transmission: Regional wars and imperial conflicts begin.",
["1854"] = "Radio transmission: Military campaigns and sieges affect populations.",
["1855"] = "Radio transmission: Public health and sanitation become public concerns.",
["1856"] = "Radio transmission: Treaties and settlements attempt to end hostilities.",
["1857"] = "Radio transmission: Economic crises and social unrest emerge.",
["1858"] = "Radio transmission: Communication and transport networks expand.",
["1859"] = "Radio transmission: Scientific theories and discoveries challenge old ideas.",
["1860"] = "Radio transmission: Political tensions and civil conflicts rise in several regions.",
["1861"] = "Radio transmission: Large‑scale civil war begins in North America.",
["1862"] = "Radio transmission: Major battles and conscription shape wartime society.",
["1863"] = "Radio transmission: Turning points in conflict and emancipation movements occur.",
["1864"] = "Radio transmission: Military campaigns and sieges continue across theaters.",
["1865"] = "Radio transmission: Major conflicts end and reconstruction begins.",
["1866"] = "Radio transmission: National unifications and wars reshape Europe.",
["1867"] = "Radio transmission: Political unions and reforms alter governance structures.",
["1868"] = "Radio transmission: Social and political reforms spread in Asia and Europe.",
["1869"] = "Radio transmission: Major infrastructure projects connect continents.",
["1870"] = "Radio transmission: Large‑scale wars and sieges mark the year.",
["1871"] = "Radio transmission: New nation‑states and political orders emerge.",
["1872"] = "Radio transmission: Industrial growth and urban expansion continue.",
["1873"] = "Radio transmission: Economic downturns and market panics affect trade.",
["1874"] = "Radio transmission: Cultural and scientific institutions expand influence.",
["1875"] = "Radio transmission: Colonial administration and exploration persist.",
["1876"] = "Radio transmission: Technological demonstrations and inventions attract attention.",
["1877"] = "Radio transmission: Communication networks and telegraphy improve.",
["1878"] = "Radio transmission: Diplomatic conferences and treaties attempt to stabilize regions.",
["1879"] = "Radio transmission: Electrical and industrial innovations accelerate.",
["1880"] = "Radio transmission: Urbanization and social reform movements grow.",
["1881"] = "Radio transmission: Political assassinations and upheavals shock nations.",
["1882"] = "Radio transmission: Alliances and colonial agreements shape foreign policy.",
["1883"] = "Radio transmission: Natural disasters and volcanic eruptions cause devastation.",
["1884"] = "Radio transmission: International conferences divide colonial territories.",
["1885"] = "Radio transmission: Industrial exhibitions and scientific progress continue.",
["1886"] = "Radio transmission: Labor movements and social unrest increase.",
["1887"] = "Radio transmission: Technological advances influence daily life.",
["1888"] = "Radio transmission: Urban crime and social anxieties capture headlines.",
["1889"] = "Radio transmission: Political revolutions and new republics form.",
["1890"] = "Radio transmission: Expansion of rail and industry reshapes economies.",
["1891"] = "Radio transmission: Social reform and labor organization gain traction.",
["1892"] = "Radio transmission: Political movements and strikes challenge elites.",
["1893"] = "Radio transmission: Economic crises and market collapses unsettle nations.",
["1894"] = "Radio transmission: Regional conflicts and colonial tensions persist.",
["1895"] = "Radio transmission: Scientific breakthroughs and public exhibitions draw crowds.",
["1896"] = "Radio transmission: Olympic revival and international sporting events begin.",
["1897"] = "Radio transmission: Technological demonstrations and cultural shifts continue.",
["1898"] = "Radio transmission: Conflicts overseas alter colonial possessions and influence.",
["1899"] = "Radio transmission: Turn-of-century anxieties and optimism mingle in public discourse.",
["1900"] = "Radio transmission: The world enters a new century.",
["1901"] = "Radio transmission: Theodore Roosevelt becomes US president.",
["1902"] = "Radio transmission: The first Teddy bear is produced.",
["1903"] = "Radio transmission: The Wright brothers achieve first powered flight.",
["1904"] = "Radio transmission: Russo-Japanese War begins.",
["1905"] = "Radio transmission: Einstein publishes the theory of special relativity.",
["1906"] = "Radio transmission: Devastating San Francisco earthquake strikes.",
["1907"] = "Radio transmission: The first commercial radio transmission is made.",
["1908"] = "Radio transmission: Tunguska Event flattens Siberian forest.",
["1909"] = "Radio transmission: Ernest Shackleton begins Antarctic expedition.",
["1910"] = "Radio transmission: Halley's Comet makes its return.",
["1911"] = "Radio transmission: Roald Amundsen reaches the South Pole.",
["1912"] = "Radio transmission: RMS Titanic sinks after striking an iceberg.",
["1913"] = "Radio transmission: The Federal Reserve System is created in the US.",
["1914"] = "Radio transmission: World War I begins.",
["1915"] = "Radio transmission: Sinking of the Lusitania escalates tensions.",
["1916"] = "Radio transmission: Battle of the Somme begins in World War I.",
["1917"] = "Radio transmission: Russian Revolution topples the monarchy.",
["1918"] = "Radio transmission: World War I ends with armistice.",
["1919"] = "Radio transmission: Treaty of Versailles officially ends WWI.",
["1920"] = "Radio transmission: League of Nations founded.",
["1921"] = "Radio transmission: Albert Einstein wins Nobel Prize in Physics.",
["1922"] = "Radio transmission: Discovery of Tutankhamun's tomb in Egypt.",
["1923"] = "Radio transmission: Hyperinflation crisis in Germany.",
["1924"] = "Radio transmission: First Winter Olympics held in Chamonix, France.",
["1925"] = "Radio transmission: Scopes Trial debates evolution in Tennessee.",
["1926"] = "Radio transmission: First liquid-fueled rocket launched by Robert Goddard.",
["1927"] = "Radio transmission: Charles Lindbergh completes first solo transatlantic flight.",
["1928"] = "Radio transmission: Discovery of penicillin by Alexander Fleming.",
["1929"] = "Radio transmission: Stock Market crashes, Great Depression begins.",
["1930"] = "Radio transmission: Pluto is discovered as the ninth planet.",
["1931"] = "Radio transmission: Empire State Building completed in New York.",
["1932"] = "Radio transmission: Franklin D. Roosevelt elected US president.",
["1933"] = "Radio transmission: Adolf Hitler becomes Chancellor of Germany.",
["1934"] = "Radio transmission: First Long March begins in China.",
["1935"] = "Radio transmission: Social Security Act passed in the US.",
["1936"] = "Radio transmission: Berlin Olympics showcase international competition.",
["1937"] = "Radio transmission: Hindenburg disaster occurs in New Jersey.",
["1938"] = "Radio transmission: Orson Welles' 'War of the Worlds' broadcast causes panic.",
["1939"] = "Radio transmission: Neville Chamberlain declares war on Germany.",
["1940"] = "Radio transmission: Battle of Britain begins.",
["1941"] = "Radio transmission: Attack on Pearl Harbor draws US into WWII.",
["1942"] = "Radio transmission: Battle of Stalingrad commences.",
["1943"] = "Radio transmission: Allied forces push into Italy.",
["1944"] = "Radio transmission: D-Day invasion begins Normandy campaign.",
["1945"] = "Radio transmission: World War II ends, victory for Allies.",
["1946"] = "Radio transmission: UN holds its first General Assembly.",
["1947"] = "Radio transmission: Jackie Robinson breaks MLB color barrier.",
["1948"] = "Radio transmission: Berlin Airlift begins to supply West Berlin.",
["1949"] = "Radio transmission: NATO alliance founded.",
["1950"] = "Radio transmission: Korean War begins.",
["1951"] = "Radio transmission: First color TV broadcasts in the US.",
["1952"] = "Radio transmission: Hydrogen bomb successfully tested.",
["1953"] = "Radio transmission: DNA structure discovered by Watson and Crick.",
["1954"] = "Radio transmission: Brown v. Board of Education ends segregation in schools.",
["1955"] = "Radio transmission: Rosa Parks refuses to give up her seat.",
["1956"] = "Radio transmission: Suez Crisis begins in Egypt.",
["1957"] = "Radio transmission: Launch of Sputnik 1, first artificial satellite.",
["1958"] = "Radio transmission: NASA established in the United States.",
["1959"] = "Radio transmission: Fidel Castro comes to power in Cuba.",
["1960"] = "Radio transmission: First televised presidential debates take place.",
["1961"] = "Radio transmission: Yuri Gagarin becomes first human in space.",
["1962"] = "Radio transmission: Cuban Missile Crisis threatens nuclear war.",
["1963"] = "Radio transmission: President John F. Kennedy assassinated.",
["1964"] = "Radio transmission: Civil Rights Act signed in the US.",
["1965"] = "Radio transmission: Vietnam War escalates with US combat troops.",
["1966"] = "Radio transmission: Cultural Revolution begins in China.",
["1967"] = "Radio transmission: First successful human heart transplant.",
["1968"] = "Radio transmission: Apollo 8 orbits the Moon.",
["1969"] = "Radio transmission: Apollo 11 lands on the Moon.",
["1970"] = "Radio transmission: Beatles break up, end of an era in music.",
["1971"] = "Radio transmission: Intel releases the first microprocessor.",
["1972"] = "Radio transmission: Watergate scandal begins to unfold.",
["1973"] = "Radio transmission: OPEC oil embargo causes energy crisis.",
["1974"] = "Radio transmission: Nixon resigns over Watergate scandal.",
["1975"] = "Radio transmission: Vietnam War ends with Saigon captured.",
["1976"] = "Radio transmission: Apple Computer founded by Steve Jobs and Steve Wozniak.",
["1977"] = "Radio transmission: Star Wars released in theaters.",
["1978"] = "Radio transmission: First test tube baby born.",
["1979"] = "Radio transmission: Margaret Thatcher becomes UK Prime Minister.",
["1980"] = "Radio transmission: Mount St. Helens erupts in Washington.",
["1981"] = "Radio transmission: First space shuttle launch: Columbia.",
["1982"] = "Radio transmission: Falklands War begins.",
["1983"] = "Radio transmission: Internet domain name system (DNS) is implemented.",
["1984"] = "Radio transmission: Apple releases Macintosh computer.",
["1985"] = "Radio transmission: Live Aid concert raises global awareness.",
["1986"] = "Radio transmission: Chernobyl nuclear disaster occurs.",
["1987"] = "Radio transmission: World population reaches 5 billion.",
["1988"] = "Radio transmission: Pan Am Flight 103 bombing occurs.",
["1989"] = "Radio transmission: Berlin Wall falls, symbolizing the end of Cold War.",
["1990"] = "Radio transmission: Nelson Mandela released from prison.",
["1991"] = "Radio transmission: Gulf War begins.",
["1992"] = "Radio transmission: Barcelona hosts the Summer Olympics.",
["1993"] = "Radio transmission: World Wide Web becomes public.",
["1994"] = "Radio transmission: Nelson Mandela becomes South African president.",
["1995"] = "Radio transmission: Oklahoma City bombing occurs.",
["1996"] = "Radio transmission: Dolly the sheep cloned successfully.",
["1997"] = "Radio transmission: Princess Diana dies in car crash.",
["1998"] = "Radio transmission: Google founded.",
["1999"] = "Radio transmission: Y2K fears grip the world.",
["2000"] = "Radio transmission: Millennium celebrations worldwide.",
["2001"] = "Radio transmission: Terrorist attacks in the USA (9/11).",
["2002"] = "Radio transmission: Euro currency introduced.",
["2003"] = "Radio transmission: Iraq War begins.",
["2004"] = "Radio transmission: Facebook founded by Mark Zuckerberg.",
["2005"] = "Radio transmission: Hurricane Katrina hits the US.",
["2006"] = "Radio transmission: Twitter founded.",
["2007"] = "Radio transmission: iPhone released by Apple.",
["2008"] = "Radio transmission: Global financial crisis hits.",
["2009"] = "Radio transmission: Barack Obama inaugurated as US President.",
["2010"] = "Radio transmission: Haiti earthquake devastates nation.",
["2011"] = "Radio transmission: Osama bin Laden killed in Pakistan.",
["2012"] = "Radio transmission: Mayan calendar prophecy passes uneventfully.",
["2013"] = "Radio transmission: Edward Snowden leaks NSA documents.",
["2014"] = "Radio transmission: Ebola outbreak in West Africa.",
["2015"] = "Radio transmission: Paris Climate Agreement signed.",
["2016"] = "Radio transmission: Brexit referendum passes in UK.",
["2017"] = "Radio transmission: Total solar eclipse visible across US.",
["2018"] = "Radio transmission: Thailand cave rescue succeeds.",
["2019"] = "Radio transmission: Notre-Dame fire in Paris.",
["2020"] = "Radio transmission: COVID-19 pandemic spreads worldwide.",
["2021"] = "Radio transmission: NASA lands rover Perseverance on Mars.",
["2022"] = "Radio transmission: James Webb Space Telescope sends first images.",
["2023"] = "Radio transmission: AI and robotics breakthroughs gain global attention.",
["2024"] = "Radio transmission: World prepares for 2024 Summer Olympics.",
["2025"] = "Radio transmission: Global technology summit announces breakthrough AI.",
["2026"] = "Radio transmission: International accords signed to regulate advanced AI governance."
    }

    local function playSound(valid)
        if valid then surface.PlaySound(RADIO_SOUND_VALID) else surface.PlaySound(RADIO_SOUND_INVALID) end
    end

    local function showChatMessage(msg, valid)
        if valid then
            chat.AddText(Color(0,200,0), "[SCP-185] " .. msg)
        else
            chat.AddText(Color(200,0,0), "[SCP-185] " .. msg)
        end
    end

    net.Receive("SCP185_OpenKeypad", function()
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end

        -- Fixed size requested by user
        local frameW, frameH = 280, 520
        local frame = vgui.Create("DFrame")
        frame:SetSize(frameW, frameH)
        frame:Center()
        frame:SetTitle("")
        frame:MakePopup()
        frame:ShowCloseButton(false)
        frame:SetDraggable(true)
        frame:SetKeyboardInputEnabled(true)
        frame:SetDeleteOnClose(true)

        -- Paint
        frame.Paint = function(self, w, h)
            surface.SetDrawColor(12,12,12,240); surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(140,20,20,160); surface.DrawRect(0,0,w,6)
            surface.SetDrawColor(28,28,28,255); surface.DrawRect(0,6,w,44)
            draw.SimpleText("█ SCP-185 █", "SCP185_Title", 12, 12, Color(220,220,220), TEXT_ALIGN_LEFT)
            draw.SimpleText("⚠", "SCP185_Title", w - 36, 12, Color(220,80,80), TEXT_ALIGN_CENTER)
            surface.SetDrawColor(30,30,30,255); surface.DrawRect(12,64,w-24,64)
            surface.SetDrawColor(0,120,0,40); surface.DrawOutlinedRect(12,64,w-24,64)
        end

        local codeValue = ""
        local maxDigits = 4

        local display = vgui.Create("DLabel", frame)
        display:SetFont("SCP185_Display")
        display:SetSize(frameW - 40, 64)
        display:SetPos(20, 64)
        display:SetContentAlignment(5)
        display:SetTextColor(Color(0,255,0))
        display:SetText("----")
        display.Think = function(self)
            if codeValue == "" then self:SetText("----") else self:SetText(codeValue) end
        end

        local hint = vgui.Create("DLabel", frame)
        hint:SetFont("SCP185_Button")
        hint:SetPos(20, 136)
        hint:SetTextColor(Color(180,180,180))
        hint:SetText("Enter a four-digit year (1700–2026). Server authoritative.")

        -- Button sizing (fits 4 rows comfortably within 280x520)
        local spacing = 8
        local btnSize = 56
        local startX = (frameW - (btnSize * 3 + spacing * 2)) / 2
        local startY = 176
        local x, y = startX, startY

        local function CreateKeyButton(text, px, py, w, h, clickFunc)
            local btn = vgui.Create("DButton", frame)
            btn:SetText(text); btn:SetFont("SCP185_Button"); btn:SetTextColor(Color(220,220,220))
            btn:SetSize(w, h); btn:SetPos(px, py)
            btn.Paint = function(self, w, h)
                local bg = self:IsDown() and Color(28,28,28) or (self:IsHovered() and Color(64,64,64) or Color(44,44,44))
                surface.SetDrawColor(bg); surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(80,80,80); surface.DrawOutlinedRect(0,0,w,h,1)
            end
            btn.DoClick = clickFunc
            return btn
        end

        -- 1..9 grid
        for i = 1, 9 do
            CreateKeyButton(tostring(i), x, y, btnSize, btnSize, function()
                if #codeValue < maxDigits then codeValue = codeValue .. tostring(i) end
            end)
            x = x + btnSize + spacing
            if i % 3 == 0 then y = y + btnSize + spacing; x = startX end
        end

        -- fourth row: Clear, 0, Enter
        local bottomY = y
        local clearX = startX
        local zeroX = startX + btnSize + spacing
        local enterX = startX + (btnSize + spacing) * 2

        CreateKeyButton("Clear", clearX, bottomY, btnSize, btnSize, function() codeValue = "" end)
        CreateKeyButton("0", zeroX, bottomY, btnSize, btnSize, function() if #codeValue < maxDigits then codeValue = codeValue .. "0" end end)
        CreateKeyButton("Enter", enterX, bottomY, btnSize, btnSize, function()
            if codeValue == "" then return end
            local trimmed = tostring(codeValue):Trim()
            -- optional client preview
            local localMsg = historicalCodes[trimmed]
            if localMsg then showChatMessage(localMsg, true); playSound(true) end
            net.Start("SCP185_SubmitCode"); net.WriteString(trimmed); net.WriteEntity(ent); net.SendToServer()
            codeValue = ""; frame:Close()
        end)

        -- bottom Close (positioned lower to match increased height)
        local closeBtn = vgui.Create("DButton", frame)
        closeBtn:SetText("Close"); closeBtn:SetFont("SCP185_Button"); closeBtn:SetTextColor(Color(220,220,220))
        closeBtn:SetSize(84, 32); closeBtn:SetPos((frameW - 84) / 2, bottomY + btnSize + 28)
        closeBtn.Paint = function(self, w, h)
            local bg = self:IsDown() and Color(28,28,28) or (self:IsHovered() and Color(64,20,20) or Color(44,20,20))
            surface.SetDrawColor(bg); surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(80,80,80); surface.DrawOutlinedRect(0,0,w,h,1)
        end
        closeBtn.DoClick = function() codeValue = ""; frame:Close() end

        -- Keyboard: numbers, backspace -> CLEAR, enter
        frame.OnKeyCode = function(self, code)
            if code >= KEY_0 and code <= KEY_9 then
                local num = tostring(code - KEY_0)
                if #codeValue < maxDigits then codeValue = codeValue .. num end
            elseif code == KEY_BACKSPACE then
                codeValue = "" -- backspace acts as clear
            elseif code == KEY_ENTER or code == KEY_PAD_ENTER then
                if codeValue ~= "" then
                    local trimmed = tostring(codeValue):Trim()
                    net.Start("SCP185_SubmitCode"); net.WriteString(trimmed); net.WriteEntity(ent); net.SendToServer()
                    codeValue = ""; self:Close()
                end
            end
        end
    end)

    -- Server response handler
    net.Receive("SCP185_ChatMessage", function()
        local msg = net.ReadString()
        if not msg then return end
        local invalid = string.find(msg, "Static noise") or string.find(msg, "No records") or string.find(msg, "Invalid")
        showChatMessage(msg, not invalid)
        playSound(not invalid)
    end)
end