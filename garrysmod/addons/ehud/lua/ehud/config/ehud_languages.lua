local langs = {
	["en"] = {
		__name__ = "English",
		__code__ = "US", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "Health",
		armor = "Armor",
		hunger = "Hunger",
		agenda_title = "Agenda",
		props = "Props",

		tab_general = "General",
		tab_modules = "Modules",
		tab_plyover = "Above player",

		ammotype_primary = "PRIMARY",
		ammotype_secondary = "SECONDARY",

		deathsc_maintext = "R.I.P",
		deathsc_lived = "You lived",
		deathsc_respawn_phrase = "Press any key to respawn...",
		deathsc_please_wait = "Please wait %d seconds", --%d - addon will replace this with number | time to respawn

		phrase_arrested = "Arrested",
		phrase_wanted = "Wanted",
		phrase_time_left = "Time left",
		phrase_select_players = "Select players", --plural
		phrase_lockdown = "LOCKDOWN \n PLEASE, STAY HOME!", --\n - New line
		phrase_NoAccess = "No access",

		--CrashScreen
		crash_title = "OOOPS...",
		crash_subtitle = "CONNECTION LOST, BUT WE WILL FIX THIS QUICKLY <3",
		crash_reconnect = "RECONNECT",
		crash_auto_reconnect = "Seconds to auto reconnect",
		crash_quit = "QUIT",
		crash_close = "CLOSE THIS MENU",

		--Doors
		phrase_sell = "Sell",
		phrase_buy = "Buy",
		phrase_set_title = "Set title",
		phrase_addowner = "Add owner",
		phrase_remowner = "Remove owner",
		disallow_ownership = "Deny ownership",
		allow_ownership = "Allow ownership",
		edit_door_group = "Edit groups",
		door_canbuy = "Press [F2] to buy this door",
		door_canedit = "Press [F2] to edit this door",
		door_coowners_limit = "And %d players...", -- %d - number of players > limit

		--vc mod
        VC_fuel_Petrol = "Petrol",
		VC_fuel_Diesel = "Diesel",
		VC_fuel_Electricity = "Electricity",
		VC_fuel_Unknown = "Fuel",

		--photon
		Photon_Primary = "Primary",
		Photon_WarningLights = "Warning Lights",
		Photon_Siren = "Siren",
		Photon_Illumination = "Illumination",

		--Config
		s_mainhud_name = "Main HUD",
		s_gunhud_name = "Gun HUD",
		s_arrestedhud_name = "Arrested HUD",
		s_doorshud_name = "Doors HUD",
		s_animspeed_name = "Animation speed",
		s_blur_name = "Blur",
		s_blur_desc = "Enable / Disable blur. Slightly affects fps", --\n - New line
		s_fps_name = "FPS counter",
		s_draw_dist_name = "Draw distance",
		s_draw_dist_desc = "Nicknames / Doors",
		s_drawbg_name = "MainHUD BG",
		s_drawbg_desc = "Does the addon need to draw a background for the main hud",
		s_fpp_name = "FPP HUD",
		s_fpp_desc = "Falco's Prop Protection. You need to reconnect after changing this.",
		s_vignette_name = "Vignette",
		s_vignette_desc = "The strength of the dimming at the edges of the screen",
		s_hitmark_name = "Hitmarker",
        s_hitmark_desc = "When you damage a player, a hit mark will appear on the screen",
        s_plyover_name = "Text over player",
        s_voice_name = "Voice chat",
        s_lockdown_name = "Lockdown",
        s_agenda_name = "Agenda",
        s_dynamic_name = "Dynamical HUD",
        s_deathscreen_name = "Death Screen",
        s_notify_name = "Notifications",
        s_crash_name = "Crash Screen",
        s_crash_desc = "When the server goes down, a crash screen appears",
        s_drawname_name = "Player nicknames",
        s_drawjobs_name = "Player jobs",
        s_drawlicense_name = "Player license",
        s_drawarrested_name = "Arrested visibility",
        s_drawwanted_name = "Wanted visibility",
        s_vehicle_name = "Vehicle HUD",
        s_usekmh_name = "Use KM/H",
        s_usekmh_desc = "Use KM/H instead of MPH",
        s_drawdurability_name = "[VCMod] Durability",
        s_drawdurability_desc = "Draw durability of a car or not",
        s_selector_name = "Weapon selector",
        s_fast_switch_name = "Fast weapon switch",
        s_xp_name = "XP HUD",
	},
	["ru"] = {
		__name__ = "Русский",
		__code__ = "RU", --Языковой код: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "Здоровье",
		armor = "Броня",
		hunger = "Голод",
		agenda_title = "Повестка дня",
		props = "Пропы",

		tab_general = "Главные",
		tab_modules = "Модули",
		tab_plyover = "Над игроком",

		ammotype_primary = "ОСНОВНЫЕ",
		ammotype_secondary = "ВТОРИЧНЫЕ",

		deathsc_maintext = "R.I.P",
		deathsc_lived = "Вы прожили",
		deathsc_respawn_phrase = "Нажмите любую клавишу чтобы возродиться...",
		deathsc_please_wait = "Подождите %d секунд", --%d - addon will replace this with number | time to respawn

		phrase_arrested = "Арестован",
		phrase_wanted = "В розыске",
		phrase_time_left = "Времени осталось",
		phrase_select_players = "Выберите игроков",
		phrase_lockdown = "Комендантский час! \n Пожалуйста, оставайтесь дома!", --\n - New line
		phrase_NoAccess = "Нет доступа",

		--Doors
		phrase_sell = "Продать",
		phrase_buy = "Купить",
		phrase_set_title = "Дать название",
		phrase_addowner = "Добавить владельца",
		phrase_remowner = "Удалить владельца",
		disallow_ownership = "Запретить",
		allow_ownership = "Разрешить",
		edit_door_group = "Изменить группы",
		door_canbuy = "Нажмите [F2] чтобы купить эту дверь",
		door_canedit = "Нажмите [F2] чтобы редактировать эту дверь",
		door_coowners_limit = "И ещё %d игроков...", -- %d - число игроков

		--CrashScreen
		crash_title = "Упс...",
		crash_subtitle = "Потеряно соединение. Мы скоро его восстановим!",
		crash_reconnect = "Переприсоединиться",
		crash_auto_reconnect = "Секунд до автоматического перезахода",
		crash_quit = "Выйти",
		crash_close = "Закрыть это меню",

		--vc mod
        VC_fuel_Petrol = "Бензин",
		VC_fuel_Diesel = "Дизель",
		VC_fuel_Electricity = "Электричество",
		VC_fuel_Unknown = "Топливо",

		--Photon
		Photon_Primary = "Основные",
		Photon_WarningLights = "Проблесковые маячки",
		Photon_Siren = "Сирена",
		Photon_Illumination = "Подсветка",

		--Config
		s_mainhud_name = "Основной HUD",
		s_gunhud_name = "Оружейный HUD",
		s_arrestedhud_name = "HUD Ареста",
		s_doorshud_name = "Дверной HUD",
		s_animspeed_name = "Скорость анимации",
		s_blur_name = "Размытие",
		s_blur_desc = "Включить / Выключить размытие. Немного влияет на фпс",
		s_fps_name = "Счетчик ФПС",
		s_draw_dist_name = "Расстояние прорисовки",
		s_draw_dist_desc = "Никнеймов / Дверей",
		s_drawbg_name = "Фон",
		s_drawbg_desc = "Нужно ли аддону отрисовывать задний фон у главного HUD",
		s_fpp_name = "FPP HUD",
		s_fpp_desc = "Falco's Prop Protection. Нужен перезаход на сервер.",
		s_vignette_name = "Виньетка",
		s_vignette_desc = "Сила затемнения по краям экрана",
		s_hitmark_name = "Индикатор попадания",
        s_hitmark_desc = "При попадании по игроку, на экране появится перекрестие",
        s_plyover_name = "Текст над игроком",
        s_voice_name = "Голосовой чат",
        s_lockdown_name = "Комендантский час",
        s_agenda_name = "Повестка дня",
        s_dynamic_name = "Динамический HUD",
        s_deathscreen_name = "Экран смерти",
        s_notify_name = "Уведомления",
        s_crash_name = "HUD Сетевого сбоя",
        s_crash_desc = "При внезапном сетевом сбое, появляется специальное меню о неисправности",
        s_drawname_name = "Никнейм",
        s_drawjobs_name = "Работа",
        s_drawlicense_name = "Лицензия",
        s_drawarrested_name = "Аррест",
        s_drawwanted_name = "Розыск",
        s_vehicle_name = "HUD Машины",
        s_usekmh_name = "Использовать Км/Ч",
        s_usekmh_desc = "Использовать Км/Ч вместо М/Ч",
        s_drawdurability_name = "[VCMod] Прочность",
        s_drawdurability_desc = "Отображать прочность машины или нет",
        s_selector_name = "Выбор оружия",
        s_fast_switch_name = "Быстрая смена оружия",
        s_xp_name = "XP HUD",

	},
	--translation by https://www.gmodstore.com/users/kbrpluma
	["de"] = {
		__name__ = "Deutsch",
		__code__ = "DE", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
 
		health = "Gesundheit",
		armor = "Rüstung",
		hunger = "Hunger",
		agenda_title = "Agenda",
		props = "Props",
 
		tab_general = "Allgemein",
		tab_modules = "Module",
		tab_plyover = "Overhead",
 
		ammotype_primary = "PRIMÄR",
		ammotype_secondary = "SEKUNDÄR",
 
		deathsc_maintext = "R.I.P",
		deathsc_lived = "Lebenszeit:",
		deathsc_respawn_phrase = "Drücke eine Taste um zu respawnen...",
		deathsc_please_wait = "Bitte warte %d Sekunden", --%d - addon will replace this with number | time to respawn
 
		phrase_arrested = "Verhaftet",
		phrase_wanted = "Gesucht",
		phrase_time_left = "Übrige Zeit",
		phrase_select_players = "Spieler auswählen", --plural
		phrase_lockdown = "LOCKDOWN \n BITTE, BLEIBT ZUHAUSE!", --\n - New line
		phrase_NoAccess = "Kein Zugriff",
 
		--CrashScreen
		crash_title = "OOOPS...",
		crash_subtitle = "VERBINDUNG VERLOREN! KEINE SORGE, WIR KÜMMERN UNS DARUM! <3",
		crash_reconnect = "NEUVERBINDEN",
		crash_auto_reconnect = "Sekunden bis zur Neuverbindung",
		crash_quit = "VERLASSEN",
		crash_close = "MENÜ SCHLIESSEN",
 
		--Doors
		phrase_sell = "Verkaufen",
		phrase_buy = "Kaufen",
		phrase_set_title = "Titel setzen",
		phrase_addowner = "Besitzer hinzufügen",
		phrase_remowner = "Besiter entfernen",
		disallow_ownership = "Kaufen verbieten",
		allow_ownership = "Kaufen erlauben",
		edit_door_group = "Türgruppen bearbeiten",
		door_canbuy = "Drücke [F2] um die Tür zu kaufen",
		door_canedit = "Drücke [F2] um die Tür zu bearbeiten",
		door_coowners_limit = "Und %d Spieler...", -- %d - number of players > limit
 
		--vc mod
        VC_fuel_Petrol = "Benzin",
		VC_fuel_Diesel = "Diesel",
		VC_fuel_Electricity = "Strom",
		VC_fuel_Unknown = "Kraftstoff",
 
		--photon
		Photon_Primary = "Primär",
		Photon_WarningLights = "Warnblinker",
		Photon_Siren = "Sirene",
		Photon_Illumination = "Illumination",
 
		--Config
		s_mainhud_name = "Main HUD",
		s_gunhud_name = "Waffen HUD",
		s_arrestedhud_name = "Verhaftungs HUD",
		s_doorshud_name = "Türen HUD",
		s_animspeed_name = "Animationsgeschwindigkeit",
		s_blur_name = "Unschärfe",
		s_blur_desc = "Aktiviere / Deaktiviere Unschärfe. Beeinträchtigt leicht die FPS.", --\n - New line
		s_fps_name = "FPS Anzeige",
		s_draw_dist_name = "Distanz anzeigen",
		s_draw_dist_desc = "Spitznamen / Türen",
		s_drawbg_name = "MainHUD Hintergrund",
		s_drawbg_desc = "Soll das Addon einen Hintergrund für das HUD anzeigen",
		s_fpp_name = "FPP HUD",
		s_fpp_desc = "Falco's Prop Protection. Du musst dich nach Änderung neuverbinden.",
		s_vignette_name = "Vignette",
		s_vignette_desc = "Die Stärke der Vignette am Bildschirmrand.",
		s_hitmark_name = "Hitmarker",
        s_hitmark_desc = "Wenn du einen Spieler triffst, wird ein Hitmarker angezeigt",
        s_plyover_name = "Text über dem Spieler",
        s_voice_name = "Voice chat",
        s_lockdown_name = "Lockdown",
        s_agenda_name = "Agenda",
        s_dynamic_name = "Dynamisches HUD",
        s_deathscreen_name = "Death Screen",
        s_notify_name = "Benachrichtigungen",
        s_crash_name = "Crash Screen",
        s_crash_desc = "Wenn der Server abstürzt wird ein Crashscreen angezeigt",
        s_drawname_name = "Spitznamen",
        s_drawjobs_name = "Berufe",
        s_drawlicense_name = "Lizenz",
        s_drawarrested_name = "Verhaftet (Sehbar)",
        s_drawwanted_name = "Gesucht (Sehbar)",
        s_vehicle_name = "Fahrzeug HUD",
        s_usekmh_name = "Benutze KM/H",
        s_usekmh_desc = "Benute KM/H anstelle von MPH",
        s_drawdurability_name = "[VCMod] Gesundheit",
        s_drawdurability_desc = "Fahrzeug Gesundheit anzeigen oder nicht anzeigen",
        s_fast_switch_name = "Schneller Wechsel der Waffen",
        s_selector_name = "Auswahl der Waffen",
        s_xp_name = "XP HUD",
	},
	--translation by https://www.gmodstore.com/users/76561198363331907
	["cn"] = {
		__name__ = "简体中文",
		__code__ = "CN", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "血量",
		armor = "护甲",
		hunger = "饥饿",
		agenda_title = "议程",
		props = "物品",

		tab_general = "一般",
		tab_modules = "模块",
		tab_plyover = "以上",
		
		ammotype_primary = "主",
		ammotype_secondary = "次",

		deathsc_maintext = "R.I.P",
		deathsc_lived = "你存活了",
		deathsc_respawn_phrase = "按任意键重生...",
		deathsc_please_wait = "请等待 %d 秒", --%d - addon will replace this with number | time to respawn

		phrase_arrested = "被逮捕",
		phrase_wanted = "被通缉",
		phrase_time_left = "剩余时间",
		phrase_select_players = "选择玩家", --plural
		phrase_lockdown = "城 市 戒 严\n 请呆在家里!", --\n - New line
		phrase_NoAccess = "无法访问",

		--CrashScreen
		crash_title = "喔...",
		crash_subtitle = "连接丢失, 但是很快会好起来的 <3",
		crash_reconnect = "重新连接",
		crash_auto_reconnect = "自动重连倒计时",
		crash_quit = "退出",
		crash_close = "关闭此页面",

		--Doors
		phrase_sell = "出售",
		phrase_buy = "购买",
		phrase_set_title = "设置标题",
		phrase_addowner = "添加拥有者",
		phrase_remowner = "移除拥有者",
		disallow_ownership = "禁止所有权",
		allow_ownership = "允许所有权",
		edit_door_group = "编辑组访问",
		door_canbuy = "按 [F2] 购买此门",
		door_canedit = "按 [F2] 编辑此门",
		door_coowners_limit = "与另外 %d 位玩家...", -- %d - number of players > limit

		--vc mod
        VC_fuel_Petrol = "汽油",
		VC_fuel_Diesel = "柴油",
		VC_fuel_Electricity = "电量",
		VC_fuel_Unknown = "燃油",

		--photon
		Photon_Primary = "主要",
		Photon_WarningLights = "警灯",
		Photon_Siren = "警笛",
		Photon_Illumination = "照明",

		--Config
		s_mainhud_name = "主 HUD",
		s_gunhud_name = "枪械 HUD",
		s_arrestedhud_name = "被逮捕 HUD",
		s_doorshud_name = "门 HUD",
		s_animspeed_name = "动画速度",
		s_blur_name = "Blur",
		s_blur_desc = "开启 / 关闭 blur. 略微影响帧数.",
		s_fps_name = "FPS 计数器",
		s_draw_dist_name = "显示距离",
		s_draw_dist_desc = "昵称 / 门",
		s_drawbg_name = "主 HUD 背景",
		s_drawbg_desc = "该插件是否需要为主 HUD 绘制背景",
		s_fpp_name = "FPP HUD",
		s_fpp_desc = "Falco's Prop Protection. 你需要重新连接以应用设置.",
		s_vignette_name = "Vignette",
		s_vignette_desc = "屏幕边缘的调光强度",
		s_hitmark_name = "命中标记",
        s_hitmark_desc = "当你伤害一个玩家时, 屏幕上会出现一个命中标记.",
        s_plyover_name = "玩家上方文本",
        s_voice_name = "语音聊天",
        s_lockdown_name = "戒严",
        s_agenda_name = "议程",
        s_dynamic_name = "动态 HUD",
        s_deathscreen_name = "死亡画面",
        s_notify_name = "通知",
        s_crash_name = "崩溃画面",
        s_crash_desc = "当服务器发生故障时, 会出现一个崩溃画面",
        s_drawname_name = "玩家昵称",
        s_drawjobs_name = "玩家职业",
        s_drawlicense_name = "玩家执照",
        s_drawarrested_name = "显示被逮捕",
        s_drawwanted_name = "显示被通缉",
        s_vehicle_name = "车辆 HUD",
        s_usekmh_name = "使用 KM/H",
        s_usekmh_desc = "使用 KM/H 代替 MPH",
        s_drawdurability_name = "[VCMod] 耐久",
        s_drawdurability_desc = "是否显示车辆的耐久",
        s_fast_switch_name = "快速更换武器",
        s_selector_name = "武器的选择",
        s_xp_name = "XP HUD",
	},
	--translation by https://www.gmodstore.com/users/76561198093244860
	["dk"] = {
		__name__ = "Danish",
		__code__ = "DK", --Sprog kode: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "Liv",
		armor = "Armor",
		hunger = "Sult",
		agenda_title = "Dagsorden",
		props = "Props",

		tab_general = "General",
		tab_modules = "Moduler",
		tab_plyover = "Over spiller",

		ammotype_primary = "PRIMÆR",
		ammotype_secondary = "SEKUNDÆR",

		deathsc_maintext = "R.I.P",
		deathsc_lived = "Du levede",
		deathsc_respawn_phrase = "Tryk på en knap for at respawn...",
		deathsc_please_wait = "Vent venligst %d sekunder", --%d - addonet vil erstatte dette med nummer | tid til respawn

		phrase_arrested = "Arresteret",
		phrase_wanted = "Eftersøgt",
		phrase_time_left = "Tid tilbage",
		phrase_select_players = "Vælg spillere", --plural
		phrase_lockdown = "NEDLUKNING \n VENLIGST BLIV HJEMME!", --\n - Ny linje
		phrase_NoAccess = "Ingen adgang",

		--CrashScreen
		crash_title = "UUUPS...",
		crash_subtitle = "MISTEDE FORBINDELSEN. VIL BLIVE FIKSET HURTIGT IGEN <3",
		crash_reconnect = "GENFORBIND",
		crash_auto_reconnect = "Sekunder til automatisk genforbindelse",
		crash_quit = "AFSLUT",
		crash_close = "LUK DENNE MENU",

		--Doors
		phrase_sell = "Sælg",
		phrase_buy = "Køb",
		phrase_set_title = "Indstil titel",
		phrase_addowner = "Tilføj ejer",
		phrase_remowner = "Fjern ejer",
		disallow_ownership = "Nægt ejerskab",
		allow_ownership = "Tillad ejerskab",
		edit_door_group = "Rediger grupper",
		door_canbuy = "Tryk på [F2] for at købe denne dør",
		door_canedit = "Tryk på [F2] for at redigere denne dør",
		door_coowners_limit = "Og %d spillere...", -- %d - antal spillere > grænse

		--vc mod
        VC_fuel_Petrol = "Benzin",
		VC_fuel_Diesel = "Diesel", 
		VC_fuel_Electricity = "Elektricitet",
		VC_fuel_Unknown = "Brændstof",

		--photon
		Photon_Primary = "Primær",
		Photon_WarningLights = "Advarselslys",
		Photon_Siren = "Sirene",
		Photon_Illumination = "Belysning",

		--Config
		s_mainhud_name = "Hoved HUD",
		s_gunhud_name = "Våben HUD",
		s_arrestedhud_name = "Arresteret HUD",
		s_doorshud_name = "Døre HUD",
		s_animspeed_name = "Animations Hastighed",
		s_blur_name = "Slør",
		s_blur_desc = "Aktiver / Deaktiver slør. Påvirker en smule på fps", --\n - Ny linje
		s_fps_name = "FPS tæller",
		s_draw_dist_name = "Tegn afstand",
		s_draw_dist_desc = "Navne / Døre",
		s_drawbg_name = "HovedHUD BG",
		s_drawbg_desc = "Behøver addonet at tegne en baggrund for hoved HUD",
		s_fpp_name = "FPP HUD",
		s_fpp_desc = "Falco's Prop Protection. Du skal oprette forbindelse igen efter at have ændret dette.",
		s_vignette_name = "Vignette",
		s_vignette_desc = "Styrken af dæmpningen i kanterne af skærmen",
		s_hitmark_name = "Hitmarker",
        s_hitmark_desc = "Når du skader en spiller, vises et hitmarker på skærmen",
        s_plyover_name = "Tekst over spiller",
        s_voice_name = "Voice chat",
        s_lockdown_name = "Nedlukning",
        s_agenda_name = "Dagsorden",
        s_dynamic_name = "Dynamisk HUD",
        s_deathscreen_name = "Dødsskærm",
        s_notify_name = "Meddelelser",
        s_crash_name = "Crash Skærm",
        s_crash_desc = "Når serveren går ned, vises en crash skærm",
        s_drawname_name = "Spiller navn",
        s_drawjobs_name = "Spiller job",
        s_drawlicense_name = "Spiller licens",
        s_drawarrested_name = "Arresteret synlighed",
        s_drawwanted_name = "Eftersøgt synlighed",
        s_vehicle_name = "Køretøj HUD",
        s_usekmh_name = "Brug KM/T",
        s_usekmh_desc = "Brug KM/T i stedet for MPH",
        s_drawdurability_name = "[VCMod] Holdbarhed",
        s_drawdurability_desc = "Tegn holdbarhed af en bil eller ej",
        s_fast_switch_name = "Hurtigt skift af våben",
        s_selector_name = "Valg af våben",
        s_xp_name = "XP HUD",
	},
	--translation by https://www.gmodstore.com/users/76561198198168751
	["fr"] = {
		__name__ = "French",
		__code__ = "FR", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "Vie",
		armor = "Armure",
		hunger = "Faim",
		agenda_title = "Agenda",
		props = "Props",

		tab_general = "General",
		tab_modules = "Modules",
		tab_plyover = "Au dessus du joueur",

		ammotype_primary = "PRIMAIRE",
		ammotype_secondary = "SECONDAIRE",

		deathsc_maintext = "R.I.P",
		deathsc_lived = "Vous avez vécu",
		deathsc_respawn_phrase = "Appuyez sur n'importe quelle touche pour réapparaître...",
		deathsc_please_wait = "Veuillez attendre %d secondes",

		phrase_arrested = "Arrêté",
		phrase_wanted = "Recherché",
		phrase_time_left = "Temps restant",
		phrase_select_players = "Sélectionnez les joueurs", --plural
		phrase_lockdown = "CONFINEMENT \n S'IL VOUS PLAÎT, RESTEZ CHEZ VOUS!", --\n - New line
		phrase_NoAccess = "Pas accès",

		--CrashScreen
		crash_title = "OOOPS...",
		crash_subtitle = "CONNEXION PERDUE, MAIS NOUS RÉPARONS CELA RAPIDEMENT <3",
		crash_reconnect = "SE RECONNECTER",
		crash_auto_reconnect = "Secondes pour se reconnecter automatiquement",
		crash_quit = "QUITTER",
		crash_close = "FERMER CE MENU",

		--Doors
		phrase_sell = "Vendre",
		phrase_buy = "Acheter",
		phrase_set_title = "Définir le titre",
		phrase_addowner = "Ajouter un propriétaire",
		phrase_remowner = "Supprimer le propriétaire",
		disallow_ownership = "Refuser la propriété",
		allow_ownership = "Autoriser la propriété",
		edit_door_group = "Modifier les groupes",
		door_canbuy = "Presse [F2] pour acheter cette porte",
		door_canedit = "Presse [F2] pour modifier cette porte",
		door_coowners_limit = "Et %d players...", -- %d - number of players > limit

		--vc mod
        VC_fuel_Petrol = "Petrole",
		VC_fuel_Diesel = "Diesel",
		VC_fuel_Electricity = "Electricité",
		VC_fuel_Unknown = "Essence",

		--photon
		Photon_Primary = "Primaire",
		Photon_WarningLights = "Feux de détresse",
		Photon_Siren = "Sirène",
		Photon_Illumination = "Illumination",

		--Config
		s_mainhud_name = "HUD Principal",
		s_gunhud_name = "HUD Armes",
		s_arrestedhud_name = "HUD arrêté",
		s_doorshud_name = "HUD sur les portes",
		s_animspeed_name = "La vitesse d'animation",
		s_blur_name = "Flou",
		s_blur_desc = "Activer / désactiver le flou. Affecte légèrement les fps", --\n - New line
		s_fps_name = "Compteur FPS",
		s_draw_dist_name = "Distance de tirage",
		s_draw_dist_desc = "Surnoms / Portes",
		s_drawbg_name = "Arrière plan du HUD Principal",
		s_drawbg_desc = "L'addon doit-il dessiner un arrière-plan pour le hud principal",
		s_fpp_name = "FPP HUD",
		s_fpp_desc = "Falco's Prop Protection. Vous devez vous reconnecter après avoir changé cela.",
		s_vignette_name = "Vignette",
		s_vignette_desc = "La force de la gradation sur les bords de l'écran",
		s_hitmark_name = "Hitmarker",
        s_hitmark_desc = "Lorsque vous endommagez un joueur, une marque de coup apparaîtra à l'écran",
        s_plyover_name = "Texte sur le joueur",
        s_voice_name = "Chat vocal",
        s_lockdown_name = "Confinement",
        s_agenda_name = "Agenda",
        s_dynamic_name = "Dynamical HUD",
        s_deathscreen_name = "Écran de la mort",
        s_notify_name = "Notifications",
        s_crash_name = "Écran de crash",
        s_crash_desc = "Lorsque le serveur crash, un écran de crash apparaît",
        s_drawname_name = "Surnoms des joueurs",
        s_drawjobs_name = "Métier du joueur",   
        s_drawlicense_name = "Player license", -- ??
        s_drawarrested_name = "Arrested visibilité", -- ??
        s_drawwanted_name = "Wanted visibilité", -- ??
        s_vehicle_name = "HUD Véhicule", 
        s_usekmh_name = "Utiliser KM/H",
        s_usekmh_desc = "Utiliser KM/H plutôt que MPH",
        s_drawdurability_name = "[VCMod] Durabilité",
        s_drawdurability_desc = "Dessiner la durabilité d'une voiture ou non",
        s_fast_switch_name = "Changement rapide d'armes",
        s_selector_name = "Choix des armes",
        s_xp_name = "XP HUD",
	},

	--translation by https://www.gmodstore.com/users/76561199213364106
	["cz"] = {
		__name__ = "Czech",
		__code__ = "CZ", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "Zdraví",
		armor = "Zbroj",
		hunger = "Hlad",
		agenda_title = "Agenda",
		props = "Propy",

		tab_general = "Hlavní",
		tab_modules = "Moduly",
		tab_plyover = "Nad přehrávačem",

		ammotype_primary = "Hlavní",
		ammotype_secondary = "Další typ",

		deathsc_maintext = "R.I.P",
		deathsc_lived = "žil",
		deathsc_respawn_phrase = "Kliknutím na libovolné tlačítko se znovu objeví...",
		deathsc_please_wait = "Prosím, čekejte %d sekund", --%d - addon will replace this with number | time to respawn

		phrase_arrested = "Zatčen",
		phrase_wanted = "Hledaný",
		phrase_time_left = "Zbývající čas",
		phrase_select_players = "Vyberte hráče", --plural
		phrase_lockdown = "LOCKDOWN \n PROSÍM ZŮSTAŇTE DOMA!", --\n - New line
		phrase_NoAccess = "Nedostatek přístupu",

		--CrashScreen
		crash_title = "OOOPS...",
		crash_subtitle = "SPOJENÍ ZTRACENO, ALE RYCHLE OPRAVÍME ( ͡° ͜ʖ ͡°)",
		crash_reconnect = "ZNOVU PŘIPOJIT",
		crash_auto_reconnect = "Vteřiny na opětovné připojení",
		crash_quit = "OPUSTIT",
		crash_close = "ZAVŘETE TOTO MENU",

		--Doors
		phrase_sell = "Prodat",
		phrase_buy = "Koupit",
		phrase_set_title = "Nastavte název",
		phrase_addowner = "Přidat vlastníka",
		phrase_remowner = "Odebrat vlastníka",
		disallow_ownership = "Zamknout dveře",
		allow_ownership = "Odemkněte dveře",
		edit_door_group = "Upravit skupiny",
		door_canbuy = "Kliknutím na [F2] zakoupíte tyto dveře",
		door_canedit = "Klikněte na [F2] pro úpravu těchto dveří",
		door_coowners_limit = "%d hráčů k dispozici...", -- %d - number of players > limit

		--vc mod
        VC_fuel_Petrol = "Benzín",
		VC_fuel_Diesel = "Disel",
		VC_fuel_Electricity = "Elektřina",
		VC_fuel_Unknown = "Palivo",

		--photon
		Photon_Primary = "Základní",
		Photon_WarningLights = "Výstražná světla",
		Photon_Siren = "Sirény",
		Photon_Illumination = "Osvětlení",

		--Config
		s_mainhud_name = "Hlavní HUD",
		s_gunhud_name = "HUD zbraní",
		s_arrestedhud_name = "Zatčení HUD",
		s_doorshud_name = "Dveře HUD",
		s_animspeed_name = "Rychlost animace",
		s_blur_name = "Rozmazání",
		s_blur_desc = "Povolení/zakázání rozostření. Mírně ovlivňuje fps", --\n - New line
		s_fps_name = "Počítadlo FPS",
		s_draw_dist_name = "Vzdálenost kreslení",
		s_draw_dist_desc = "Pseudonymy / Dveře",
		s_drawbg_name = "MainHUD BG",
		s_drawbg_desc = "Musí skript nakreslit pozadí pro hlavní hud",
		s_fpp_name = "Rozhraní FPP",
		s_fpp_desc = "Falco's Prop Protection. Po změně se musíte znovu připojit.",
		s_vignette_name = "Winieta",
		s_vignette_desc = "Síla stmívání na okrajích obrazovky",
		s_hitmark_name = "Značka zásahu",
        s_hitmark_desc = "Když hráče zraníte, na obrazovce se objeví značka zásahu.",
        s_plyover_name = "Text nad hráč",
        s_voice_name = "Hlasový chat",
        s_lockdown_name = "Lockdown",
        s_agenda_name = "Agenda",
        s_dynamic_name = "Dynamický HUD",
        s_deathscreen_name = "Obrazovka smrti",
        s_notify_name = "Oznámení",
        s_crash_name = "Obrazovka selhání",
        s_crash_desc = "Při selhání serveru se zobrazí obrazovka selhání.",
        s_drawname_name = "Přezdívka hráče",
        s_drawjobs_name = "Práce hráče",
        s_drawlicense_name = "Hráčské licence",
        s_drawarrested_name = "Viditelnost zatčení",
        s_drawwanted_name = "Viditelnost vyhledávání",
        s_vehicle_name = "HUD vozidla",
        s_usekmh_name = "Použijte KM/H",
        s_usekmh_desc = "Použijte KM/H místo MPH",
        s_drawdurability_name = "[VCMod] Životnost",
        s_drawdurability_desc = "Životnost výstavního vozu nebo ne",
        s_fast_switch_name = "Rychlá výměna zbraně",
        s_fast_switch_name = "Výběr zbraní",
        s_xp_name = "XP HUD",
	},
	--translation by https://www.gmodstore.com/users/76561199213364106
	["pl"] = {
		__name__ = "Polish",
		__code__ = "PL", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "Zdrowie",
		armor = "Pancerz",
		hunger = "Głód",
		agenda_title = "Agenda",
		props = "Propy",

		tab_general = "Główne",
		tab_modules = "Moduły",
		tab_plyover = "Powyżej gracza",

		ammotype_primary = "Główna",
		ammotype_secondary = "Dodatkowa",

		deathsc_maintext = "R.I.P",
		deathsc_lived = "Żyłeś",
		deathsc_respawn_phrase = "Kliknij dowolny przycisk by się odrodzić...",
		deathsc_please_wait = "Proszę poczekaj %d sekund", --%d - addon will replace this with number | time to respawn

		phrase_arrested = "Aresztowany",
		phrase_wanted = "Poszukiwany",
		phrase_time_left = "Pozostały czas",
		phrase_select_players = "Wybierz gracza", --plural
		phrase_lockdown = "LOCKDOWN \n PROSZĘ, ZOSTAĆ W DOMU!", --\n - New line
		phrase_NoAccess = "Brak dostępu",

		--CrashScreen
		crash_title = "OOOPS...",
		crash_subtitle = "UTRACONO POŁĄCZENIE, ALE SZYBKO TO NAPRAWIMY ( ͡° ͜ʖ ͡°)",
		crash_reconnect = "POŁĄCZ PONOWNIE",
		crash_auto_reconnect = "Sekundy do ponownego połączenia",
		crash_quit = "PORZUĆ",
		crash_close = "ZAMKNIJ TO MENU",

		--Doors
		phrase_sell = "Sprzedaj",
		phrase_buy = "Zakup",
		phrase_set_title = "Ustaw nazwę",
		phrase_addowner = "Dodaj właściciela",
		phrase_remowner = "Usuń właściciela",
		disallow_ownership = "Zablokuj zakup drzwi",
		allow_ownership = "Odblokuj zakup drzwi",
		edit_door_group = "Edytuj grupy",
		door_canbuy = "Kliknij [F2] aby kupić te drzwi",
		door_canedit = "Kliknij [F2] aby edytować te drzwi",
		door_coowners_limit = "Dostępne %d graczy...", -- %d - number of players > limit

		--vc mod
        VC_fuel_Petrol = "Benzyna",
		VC_fuel_Diesel = "Disel",
		VC_fuel_Electricity = "Prąd",
		VC_fuel_Unknown = "Paliwo",

		--photon
		Photon_Primary = "Podstawowe",
		Photon_WarningLights = "Światła ostrzegawcze",
		Photon_Siren = "Syreny",
		Photon_Illumination = "Oświetlenie",

		--Config
		s_mainhud_name = "Główny HUD",
		s_gunhud_name = "HUD Broni",
		s_arrestedhud_name = "HUD Aresztowań",
		s_doorshud_name = "HUD Drzwi",
		s_animspeed_name = "Prędkość animacji",
		s_blur_name = "Rozmycie",
		s_blur_desc = "Włącz / wyłącz rozmycie. Nieznacznie wpływa na fps", --\n - New line
		s_fps_name = "Licznik FPS",
		s_draw_dist_name = "Odległość rysowania",
		s_draw_dist_desc = "Pseudonimy / Drzwi",
		s_drawbg_name = "MainHUD BG",
		s_drawbg_desc = "Czy skrypt musi rysować tło dla głównego hudu",
		s_fpp_name = "Interfejs FPP",
		s_fpp_desc = "Falco's Prop Protection. Po zmianie musisz ponownie się połączyć.",
		s_vignette_name = "Winieta",
		s_vignette_desc = "Siła przyciemnienia na krawędziach ekranu",
		s_hitmark_name = "Znacznik trafień",
        s_hitmark_desc = "Kiedy zranisz gracza, na ekranie pojawi się znak trafienia",
        s_plyover_name = "Tekst nad graczem",
        s_voice_name = "Czat głosowy",
        s_lockdown_name = "Lockdown",
        s_agenda_name = "Agenda",
        s_dynamic_name = "Dynamiczny HUD",
        s_deathscreen_name = "Ekran śmierci",
        s_notify_name = "Powiadomienia",
        s_crash_name = "Ekran awarii",
        s_crash_desc = "Gdy serwer ulegnie awarii, pojawi się ekran awarii",
        s_drawname_name = "Pseudonim graczy",
        s_drawjobs_name = "Prace gracza",
        s_drawlicense_name = "Licencje gracza",
        s_drawarrested_name = "Widoczność aresztowania",
        s_drawwanted_name = "Widoczność poszukiwania",
        s_vehicle_name = "HUD Pojazdu",
        s_usekmh_name = "Użyj KM/H",
        s_usekmh_desc = "Użyj KM/H zamiast MPH",
        s_drawdurability_name = "[VCMod] Trwałość",
        s_drawdurability_desc = "Pokaż trwałość samochodu lub nie",
        s_fast_switch_name = "Szybka zmiana broni",
        s_selector_name = "Wybór broni",
        s_xp_name = "XP HUD",
	},
	--translation by https://www.gmodstore.com/users/Goran
	["es"] = {
		__name__ = "Español",
		__code__ = "ES", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "Salud",
		armor = "Armadura",
		hunger = "Hambre",
		agenda_title = "Agenda",
		props = "Props",

		tab_general = "General",
		tab_modules = "Módulos",
		tab_plyover = "Sobre el jugador",

		ammotype_primary = "PRIMARIA",
		ammotype_secondary = "SECUNDARIA",

		deathsc_maintext = "R.I.P",
		deathsc_lived = "Has vivido",
		deathsc_respawn_phrase = "Presiona cualquier tecla para reaparecer...",
		deathsc_please_wait = "Por favor espera %d segundos", --%d - addon will replace this with number | time to respawn

		phrase_arrested = "Arrestado",
		phrase_wanted = "Buscado",
		phrase_time_left = "Tiempo restante",
		phrase_select_players = "Seleccionar jugadores", --plural
		phrase_lockdown = "¡TOQUE DE QUEDA! \n ¡POR FAVOR, VE A CASA!", --\n - New line
		phrase_NoAccess = "Sin acceso",

		--CrashScreen
		crash_title = "UPS...",
		crash_subtitle = "CONEXIÓN PERDIDA, PERO SERÁ SOLUCIONADO EN BREVES <3",
		crash_reconnect = "RECONECTAR",
		crash_auto_reconnect = "Segundos para reconectar",
		crash_quit = "SALIR",
		crash_close = "CERRAR MENÚ",

		--Doors
		phrase_sell = "Vender",
		phrase_buy = "Comprar",
		phrase_set_title = "Establecer título",
		phrase_addowner = "Añadir propietario",
		phrase_remowner = "Remover propietario",
		disallow_ownership = "No permitir compra",
		allow_ownership = "Permitir compra",
		edit_door_group = "Editar grupos",
		door_canbuy = "Presiona [F2] para comprar esta puerta",
		door_canedit = "Presiona [F2] para editar esta puerta",
		door_coowners_limit = "Y %d jugadores...", -- %d - number of players > limit

		--vc mod
    	VC_fuel_Petrol = "Petróleo",
		VC_fuel_Diesel = "Diesel",
		VC_fuel_Electricity = "Electricidad",
		VC_fuel_Unknown = "Combustible",

		--photon
		Photon_Primary = "Primaria",
		Photon_WarningLights = "LucesDeAdvertencia",
		Photon_Siren = "Sirena",
		Photon_Illumination = "Iluminación",

		--Config
		s_mainhud_name = "HUD Principal",
		s_gunhud_name = "HUD para Armas",
		s_arrestedhud_name = "HUD de Arresto",
		s_doorshud_name = "HUD de las Puertas",
		s_animspeed_name = "Velocidad de animación",
		s_blur_name = "Difuminado",
		s_blur_desc = "Habilitar/Deshabilitar difuminado. Afecta levemente a los FPS", --\n - New line
		s_fps_name = "Contador de FPS",
		s_draw_dist_name = "Distancia de dibujado",
		s_draw_dist_desc = "Nombres/Puertas",
		s_drawbg_name = "Fondo del HUD",
		s_drawbg_desc = "¿Debe el addon dibujar un fondo para el HUD principal?",
		s_fpp_name = "HUD de FPP",
		s_fpp_desc = "Falco's Prop Protection. Debes reconectarte luego de cambiar esto.",
		s_vignette_name = "Viñetas",
		s_vignette_desc = "La fuerza de atenuación en los bordes de la pantalla",
		s_hitmark_name = "Hitmarker",
        s_hitmark_desc = "Cuando dañas a un jugador, una cruz aparecerá en el centro de la pantalla",
        s_plyover_name = "Texto sobre jugadores",
        s_voice_name = "Chat de voz",
        s_lockdown_name = "Toque de Queda",
        s_agenda_name = "Agenda",
        s_dynamic_name = "HUD Dinámico",
        s_deathscreen_name = "Pantalla de Muerte",
        s_notify_name = "Notificaciones",
        s_crash_name = "Pantalla de Crasheo",
        s_crash_desc = "Cuando el servidor se cae, aparecerá una pantalla informativa",
        s_drawname_name = "Nombres de jugadores",
        s_drawjobs_name = "Trabajos de jugadores",
        s_drawlicense_name = "Licencia",
        s_drawarrested_name = "Visibilidad de arrestado",
        s_drawwanted_name = "Visibilidad de buscado",
        s_vehicle_name = "HUD de Vehículos",
        s_usekmh_name = "Utilizar KM/H",
        s_usekmh_desc = "Utilizar KM/H en lugar de MPH",
        s_drawdurability_name = "[VCMod] Durabilidad",
        s_drawdurability_desc = "Elige si dibujar la durabilidad de un vehículo o no",
        s_fast_switch_name = "Cambio rápido de armas",
        s_selector_name = "Elección de armas",
        s_xp_name = "XP HUD",
	},
	--translation by https://www.gmodstore.com/users/illusion
	["tr"] = {
		__name__ = "Türkçe",
		__code__ = "TR", --Language code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

		health = "Sağlık",
		armor = "Zırh",
		hunger = "Açlık",
		agenda_title = "Ajanda",
		props = "Prop",

		tab_general = "Genel",
		tab_modules = "Modüller",
		tab_plyover = "Oyuncu Kafasındaki",

		ammotype_primary = "BİRİNCİL",
		ammotype_secondary = "İKİNCİL",

		deathsc_maintext = "ÖLÜ",
		deathsc_lived = "Yaşadın",
		deathsc_respawn_phrase = "Yeniden canlanmak için bir tuşa bas...",
		deathsc_please_wait = "Lütfen %d saniye bekleyin", --%d - addon will replace this with number | time to respawn

		phrase_arrested = "Tutuklandı",
		phrase_wanted = "Aranıyor",
		phrase_time_left = "Kalan Süre",
		phrase_select_players = "Oyuncu Seç", --plural
		phrase_lockdown = "SOKAĞA ÇIKMA YASĞAI \n LÜTFEN, EVDE KALINIZ!", --\n - New line
		phrase_NoAccess = "Yetkin yok",

		--CrashScreen
		crash_title = "OOOPS...",
		crash_subtitle = "BAĞLANTI KESİLDİ, KONTROL EDİYORUZ BİR YERE AYRILMAYIN <3",
		crash_reconnect = "TEKRAR BAĞLAN",
		crash_auto_reconnect = "Otomatik bağlanmaya kalan süre",
		crash_quit = "ÇIK",
		crash_close = "BU MENÜYÜ KAPAT",

		--Doors
		phrase_sell = "Sat",
		phrase_buy = "Satın Al",
		phrase_set_title = "Başlığı Ayarla",
		phrase_addowner = "Sahip Ekle",
		phrase_remowner = "Sahip Çıkar",
		disallow_ownership = "Sahipliği Reddet",
		allow_ownership = "Sahipliği Onayla",
		edit_door_group = "Grupları Düzenle",
		door_canbuy = "Kapıyı almak için [F2] basabilirsin",
		door_canedit = "Kapıyı düzenlemek için [F2] basabilirsin",
		door_coowners_limit = "ve %d oyuncu...", -- %d - number of players > limit

		--vc mod
        VC_fuel_Petrol = "Petrol",
		VC_fuel_Diesel = "Dizel",
		VC_fuel_Electricity = "Elektrik",
		VC_fuel_Unknown = "Yakıt",

		--photon
		Photon_Primary = "Birincil",
		Photon_WarningLights = "Uyarı Işığı",
		Photon_Siren = "Siren",
		Photon_Illumination = "Aydınlatma",

		--Config
		s_mainhud_name = "Ana HUD",
		s_gunhud_name = "Silah HUD",
		s_arrestedhud_name = "Tutuklanma HUD",
		s_doorshud_name = "Kapı HUD",
		s_animspeed_name = "Animasyon hızı",
		s_blur_name = "Blur",
		s_blur_desc = "Aktif / Deaktif blur. FPS üzerinde etkisi var", --\n - New line
		s_fps_name = "FPS sayacı",
		s_draw_dist_name = "Görme mesafesi",
		s_draw_dist_desc = "İsimler / Kapılar",
		s_drawbg_name = "AnaHUD Arkaplan",
		s_drawbg_desc = "Eklentinin ana hud için bir arkaplan çizmesi gerekiyor mu",
		s_fpp_name = "FPP HUD",
		s_fpp_desc = "Falco's Prop Protection. Bunu değişirseniz çık gir yapmanız gerekir.",
		s_vignette_name = "Karartma",
		s_vignette_desc = "Ekranın kenarlarındaki karartmanın gücü",
		s_hitmark_name = "Hitmarker",
        s_hitmark_desc = "Bir oyuncuya hasar verdiğinizde, ekranda bir isabet işareti görünür.",
        s_plyover_name = "Oyuncu üstündeki yazı",
        s_voice_name = "Ses Göstergesi",
        s_lockdown_name = "Sokağa Çıkma Yasağı",
        s_agenda_name = "Ajanda",
        s_dynamic_name = "Dinamik HUD",
        s_deathscreen_name = "Ölüm Ekranı",
        s_notify_name = "Bildirimler",
        s_crash_name = "Çökme Ekranı",
        s_crash_desc = "Sunucu çöktüğünde, bir ekran görüntülenir",
        s_drawname_name = "Oyuncu isimleri",
        s_drawjobs_name = "Oyuncu meslekleri",
        s_drawlicense_name = "Oyuncu lisansı",
        s_drawarrested_name = "Tutuklama görünürlüğü",
        s_drawwanted_name = "Aranma görünürlüğü",
        s_vehicle_name = "Araç HUD",
        s_usekmh_name = "KM/H kullan",
        s_usekmh_desc = "MPH yerine KM/H kullanılır",
        s_drawdurability_name = "[VCMod] Dayanıklık",
        s_drawdurability_desc = "Bir arabanın dayanıklılığını gösterir/göstermez",
        s_selector_name = "Silah Seçim",
        s_fast_switch_name = "Hızlı silah değişimi",
        s_xp_name = "XP HUD",
	},
}

ehud.addon:RegisterLanguages(langs)

ehud.addon:SetDefaultLanguage("en") --that will be default language