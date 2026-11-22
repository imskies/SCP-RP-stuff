local skin = {}
skin.name = "Blackout"
skin.colors = {}
skin.colors.main = {
	bg = Color(39, 42, 49,220),
	accent = Color(252, 56, 79),

	health = Color(255, 210, 210),
	armor = Color(210, 210, 255),
	hunger = Color(255, 255, 210),

	text = Color(235,235,255),
	text_gray = Color(190,190,200),

	money_text = Color(180, 255, 230),
}

skin.colors.doors = {
	bg = Color(13,13,13,200),

	nickname = Color(255,255,255),
	coowner = Color(200,200,240),
	title = Color(255, 57, 57),
}

skin.colors.vehicle = {
	bg = Color(50,50,50,200),
	bg_speed = Color(250,250,255),
	bg_lines = Color(155,155,155),
	text = Color(255,255,255),
	text_secondary = Color(200,200,200),
	line = Color(255,255,255),
}

skin.colors.notify = {
	bg = Color(13,13,13,200),

	generic = Color(255, 255, 255),
	error = Color(252, 56, 79),
	undo = Color(252, 56, 79),
	hint = Color(18, 149, 241),
	cleanup = Color(18, 149, 241),
}

skin.colors.deathscreen = {
	bg = Color(13,13,13,254),
	text = Color(255,100,110),
	text2 = Color(235,235,255),
}

skin.colors.ammo = {
	bg = Color(0,0,55,200),
	normal = Color(255, 255, 255),
	medium = Color(255, 121, 0),
	low = Color(252, 56, 79),
	text = Color(255,255,255),
}

ehud.addon:RegisterSkin("blackout", skin)
--RegisterSkin(<uid>,<skin table>)

ehud.addon:SetDefaultSkin("blackout")