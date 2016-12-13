local impl = {}

function impl.get_screen_size()
    local w, h = love.window.getMode()
    return w, h
end

function impl.create_layer()
    return love.graphics.newCanvas(impl.get_screen_size())
end

local function use_canvas(canvas)
    love.graphics.setCanvas(canvas)
end

local function clear_canvas()
    love.graphics.setCanvas()
end

function impl.draw_rect(layer, x, y, w, h, color)
    use_canvas(layer)
    love.graphics.setColor(color[1], color[2], color[3], color[4])
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(0,0,0,0)
    clear_canvas()
end

function impl.get_string_size(str, font)
    local native_font = love.graphics.newFont(font.size)
    return native_font:getWidth(str), native_font:getHeight(str)
end

function impl.print(layer, str, font, x, y, dx, dy)
    use_canvas(layer)
    local native_font = love.graphics.newFont(font.size)
    love.graphics.setFont(native_font)
    love.graphics.setColor(font.r, font.g, font.b, font.a)
    love.graphics.print(str, x, y, 0, 1, 1, dx, dy)
    clear_canvas()
end

function impl.draw_layer_on_layer(parent, child)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    if parent then
        use_canvas(parent)
    end
    love.graphics.draw(child)
    if parent then
        clear_canvas()
    end
end

return impl