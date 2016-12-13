props = require 'props'
helpers = require 'helpers'
impl = require 'love_wrapper'

local function parse(element, parent)
    element.__layer = impl.create_layer()
    element.position = { x = parent.position.x, y = parent.position.y }
    -- Pre handlers
    for _, handler in pairs(props.pre) do
        handler(element, parent)
    end
    -- Childs
    for _, v in ipairs(element) do
        helpers.expect_table("subelement", v)
        parse(v, element)
    end
    -- Post handlers
    for _, handler in pairs(props.post) do
        handler(element, parent)
    end
    -- Draw childs on current layer
    for _, v in ipairs(element) do
        impl.draw_layer_on_layer(element.__layer, v.__layer)
    end
end

local function render(view)
    local w, h = impl.get_screen_size()
    local layer = impl.create_layer()
    local view_copy = helpers.deepcopy(view)
    parse(view_copy,
        {
            position = { x = 1, y = 1},
            width = w, height = h,
            color = 0xFFFFFFFF,
            background = 0x00000000,
        }
    )
    return view_copy
end

local function draw(view)
    local c = love.graphics.newCanvas(800, 600)
    love.graphics.setCanvas(c)
    love.graphics.setColor(250,0,0, 255)
    love.graphics.rectangle("fill", 1,1, 100, 100)
    love.graphics.setCanvas()
        local c2 = love.graphics.newCanvas(800, 600)
        love.graphics.setCanvas(c2)
        love.graphics.setColor(0,0,250, 255)
        love.graphics.rectangle("fill", 1,1, 50, 50)
        love.graphics.setCanvas()
    love.graphics.setCanvas(c)
    love.graphics.draw(c2)
    love.graphics.setCanvas()
    love.graphics.setColor(255,255,255, 255)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(c)
    impl.draw_layer_on_layer(nil, view.__layer)
    --local clr = {love.graphics.getColor()}
    --love.graphics.setColor(255, 255, 255, 255)
    --love.graphics.setBlendMode("alpha", "premultiplied")
    --love.graphics.draw(data.canvas)
    --love.graphics.setColor(clr[1], clr[2], clr[3], clr[4])
end

local function mousemoved(view)
end

return { render = render, draw = draw, mousemoved = mousemoved }