helpers = require "helpers"
impl = require 'love_wrapper'

local function prop_style(element, parent)
    for prop, val in pairs(element.style or {}) do
        if type(prop) ~= type(0) and element[prop] == nil then
            element[prop] = val
        end
    end
end

local function prop_width(element, parent)
    local val = element.width or parent.width
    element.width = helpers.parse_size(val, parent.width)
end

local function prop_height(element, parent)
    local val = element.height or parent.height
    element.height = helpers.parse_size(val, parent.height)
end

local function prop_minimum(element, parent)
    if element.minimum then
        helpers.expect_size("minimum", element.minimum, 2)
        element.width = math.max(element.width, element.minimum[1])
        element.height = math.max(element.height, element.minimum[1])
    end
end

local function prop_margin(element, parent)
    local val = element.margin or {0, 0}
    helpers.expect_table("margin", val)
    if #val ~= 2 then
        error("margin: two number expected")
    end
    element.margin = { x = helpers.parse_size(val[1], parent.width), y = helpers.parse_size(val[2], parent.height)}
    element.position.x = element.position.x + element.margin.x
    element.position.y = element.position.y + element.margin.y
end

local function prop_anchor(element, parent)
    if not element.anchor then
        return
    end
    parent.__anchor = parent.__anchor or {}
    helpers.expect_string("anchor", element.anchor)
    local delim = string.find(element.anchor, ":")
    local x = (
        {
            ["left"] = 0,
            ["right"] = parent.width - element.width,
            ["center"] = parent.width / 2 - element.width / 2,
            ["left-relate"] = function()
                local l = parent.__anchor.left or 0
                parent.__anchor.left = l + element.width + element.margin.x
                return l
            end,
            ["right-relate"] = function()
                local r = (parent.__anchor.right or parent.width) - element.width
                parent.__anchor.right = r + element.margin.x
                return r
            end,
        }
    )[string.sub(element.anchor, 1, delim - 1)]
    if type(x) == type(function()end) then
        x = x()
    end
    local y = (
        {   ["top"] = 0,
            ["bottom"] = parent.height - element.height,
            ["center"] = parent.height / 2 - element.height / 2,
            ["top-relate"] = function()
                local t = parent.__anchor.top or 0
                parent.__anchor.top = t + element.height + element.margin.y
                return t
            end,
            ["bottom-relate"] = function()
                local b = (parent.__anchor.bottom or parent.height) - element.height
                parent.__anchor.bottom = b + element.margin.y
                return b
            end,
        }
    )[string.sub(element.anchor, delim + 1, -1)]
    if type(y) == type(function()end) then
        y = y()
    end
    if x == nil or y == nil then
        error("invalid anchor: " .. tostring(element.anchor))
    end
    element.position.x = element.position.x + x
    element.position.y = element.position.y + y
end

local function prop_background(element, parent)
    local r, g, b, a = helpers.parse_color(element.background or 0x00000000)
    if a ~= 0 then
        impl.draw_rect(element.__layer, element.position.x, element.position.y, element.width, element.height, {r, g, b, a})
    end
end

local function prop_font(element, parent)
    if not element.font then
        return
    end
    helpers.expect_table("font", element.font)

    local r, g, b, a = helpers.parse_color(element.font.color or 0xFFFFFFFF)
    element.__font = {
        size = tonumber(element.font.size or 14),
        r = r, g = g, b = b, a = a
    }
end

local function prop_text(element, parent)
    if element.text == nil then
        return
    end

    local loc_font = { size = 10, r, g, b, a = 255, 255, 255, 255 }
    if element.__font then
        loc_font.size = element.__font.size
        loc_font.r, loc_font.g, loc_font.b, loc_font.a =
                element.__font.r, element.__font.g, element.__font.b, element.__font.a
    end

    if type(element.text) == type("") then
        local str_w, str_h = impl.get_string_size(element.text, loc_font)
        impl.print(element.__layer, element.text, loc_font, element.position.x + element.width / 2,
                element.position.y + element.height / 2, str_w / 2, str_h / 2)
    elseif type({}) then
        if #element.text == 0 then
            return
        end
        local _, strh = impl.get_string_size(element.text[1], loc_font)
        local marh = strh * 0.2
        local text_size = { x = 0, y = strh * #element.text + marh * (#element.text - 1)}
        for _, str in ipairs(element.text) do
            local str_w, _ = impl.get_string_size(str, loc_font)
            text_size.x = math.max(text_size.x, str_w)
        end
        for n, str in ipairs(element.text) do
            impl.print(element.__layer, str, loc_font, element.position.x + element.width / 2,
                element.position.y + element.height / 2, text_size.x / 2,
                    text_size.y / 2 - (strh + marh) * (n - 1)
            )
        end
    else
        error("[text] expected 'table' or 'text', got: " .. type(element.text))
    end
    love.graphics.setColor(0,0,0,0)
end

local function prop_border(element, parent)
    if element.border == nil then
        return
    end

    helpers.expect_table("border", element.border)
    local color = { helpers.parse_color(element.border.color or 0xFFFFFFFF) }
    if element.border[1] then
        helpers.expect_number("border[1]", element.border[1])
        impl.draw_rect(element.__layer, element.position.x, element.position.y, element.width, element.border[1], color)
    end
    if element.border[2] then
        helpers.expect_number("border[2]", element.border[2])
        impl.draw_rect(element.__layer, element.position.x + element.width - element.border[2], element.position.y,
                element.border[2], element.height, color)
    end
    if element.border[3] then
        helpers.expect_number("border[3]", element.border[3])
        impl.draw_rect(element.__layer, element.position.x, element.position.y + element.height - element.border[3],
                element.width, element.border[3], color)
    end
    if element.border[4] then
        helpers.expect_number("border[4]", element.border[4])
        impl.draw_rect(element.__layer, element.position.x, element.position.y,
                element.border[4], element.height, color)
    end
end

return {
    pre = {
        prop_style, prop_width, prop_height, prop_minimum, prop_margin, prop_anchor, prop_background, prop_font, prop_text, prop_border
    },
    post = {
    },
}