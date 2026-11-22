
DCONFIG2.FontSizes = {}
local function CreateFont(size)
	local fontName = "DCONFIG2_" .. size .. CurTime()
	DCONFIG2.FontSizes[size] = true
	size = math.Round( size / 1080 * ScrH())
	surface.CreateFont(fontName, {
		font = "Roboto",
		size = size,
		weight = 600,
		strikeout = false,
		outline = false,
		shadow = false,
		outline = false,
	})
	return fontName
end

function DCONFIG2.Font(size)
	if not DCONFIG2.FontSizes[size] then
		DCONFIG2.FontSizes[size] = CreateFont(size)
	end
	return DCONFIG2.FontSizes[size]
end

DCONFIG2.ScrW = ScrW()
DCONFIG2.ScrH = ScrH()

hook.Add("OnScreenSizeChanged", "DCONFIG2.ResolutionChanged", function()
	if IsValid(DCONFIG2.ScreenPanel) then
		DCONFIG2.ScreenPanel:Remove()
		DCONFIG2.Open()
	end
	DCONFIG2.FontSizes = {}
	DCONFIG2.ScrW = ScrW()
	DCONFIG2.ScrH = ScrH()
	print("Rebuilding DConfig2 Fonts")
end)
