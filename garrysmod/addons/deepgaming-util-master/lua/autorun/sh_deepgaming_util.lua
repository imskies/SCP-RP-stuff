DGUtil = {}

-- Sneaky inclusion of an automatic addon loader that you can use anywhere
function DGUtil:Load(dir)
    local fil, fol = file.Find(dir .. "/*", "LUA")

    for _,v in ipairs(fol) do
        self:Load(dir .. "/" .. v)
    end

    for _,v in ipairs(fil) do
        print("Loading file " .. v .. "...")
        if v:StartWith("sv") then
            if SERVER then include(dir .. "/" .. v) end
            continue
        elseif SERVER then
            AddCSLuaFile(dir .. "/" .. v)
        end

        if v:StartWith("cl") then
            if CLIENT then include(dir .. "/" .. v) end
            continue
        end

        include(dir .. "/" .. v)
    end
end

DGUtil:Load("dgutil")