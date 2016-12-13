require 'luabit.bit'

local helpers = {}

function helpers.parse_size(val, whole)
    if val == nil then
        return nil
    elseif type(val) == type(0) then
        return val
    elseif type(val) == type("") then
        if not string.sub(val, -1, -1) == "%" then
            error("not valid size: " .. val)
        end
        local num = tonumber(string.sub(val, 1, -2))
        if num == nil then
            error("not valid size: " .. val)
        end
        return (whole / 100) * num
    else
        error("number expected, got: " .. type(val))
    end
end

function helpers.parse_color(val)
    local r = bit.brshift(bit.band(val, 0xFF000000), 24)
    local g = bit.brshift(bit.band(val, 0x00FF0000), 16)
    local b = bit.brshift(bit.band(val, 0x0000FF00), 8)
    local a = bit.band(val, 0x000000FF)
    return r, g, b ,a
end

function helpers.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[helpers.deepcopy(orig_key)] = helpers.deepcopy(orig_value)
        end
        setmetatable(copy, helpers.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function expect_type(name, val, exp)
    return type(val) == type(exp) or error(string.format("[%s] '%s' expected, got '%s'", name, type(exp), type(val)))
end

function helpers.expect_string(name, val)
    expect_type(name, val, "")
end

function helpers.expect_number(name, val)
    expect_type(name, val, 0)
end

function helpers.expect_table(name, val)
    expect_type(name, val, {})
end

function helpers.expect_size(name, val, size)
    helpers.expect_table(name, val, {})
    if #val ~= size then
        error(string.format("[%s] %d elements expected, got '%d'", name, size, #val))
    end
end

return helpers