local function tableToKVArray(table, done)
    local new = {}
    done = done or {}

    for k, v in pairs(table) do
        if done[v] then
            goto skip 
        end
        if istable(v) then
            new[k] = tableToKVArray(v, done)
            done[v] = v
        else
            new[k] = v 
        end
        ::skip::
    end
    return new
end

local writeTable

local types = {
    ["number"] = {1, function(v) net.WriteInt(v, 32) end},
    ["string"] = {2, net.WriteString},
    ["table"] = {3, DCONFIG2.writeTable},
    ["bool"] = {4, net.WriteBool},
}

local function writeType(value)
    local dat = types[type(value)]
    if not dat then
        net.WriteUInt(0, 8)
        return
    end

    net.WriteUInt(dat[1], 8)
    dat[2](value)
end

function DCONFIG2.writeTable(table)
    local values = tableToKVArray(table)

    net.WriteUInt(#values, 16)
    for k, v in ipairs(values) do
        writeType(k)
        writeType(v)
    end
end
