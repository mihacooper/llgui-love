package.path = package.path .. ";./src/?.lua"
gui = require 'src.gui'

local button_style = {
    width = 100,
    height = 30,
    margin = { 15, 15 },
    anchor = "left-relate:top",
    background = 0xFAFDFFFF,
    font = { color = 0x0A0D0FFF, size = 14 },
    border = {color = 0x0A0D0FFF, 0, 2, 2, 0},
    OnFocus = {
        border = {color = 0x9A9D9FFF, 2, 0, 0, 2} 
    },
}
local html = {
    background = 0xF0F0F0FF,
    {
        width = "90%",
        height = "90%",
        minimum = { 400, 400 },
        anchor = "center:center",
        background = 0xA0A0DFFF,
        {
            style = button_style,
            text = "HOME",
        },
        {
            style = button_style,
            text = "ABOUT",
        },
        {
            style = button_style,
            text = "GAMES",
        },
        {
            width = '80%',
            height = '90%',
            margin = { 0, 0 },
            anchor = "center:bottom-relate",
            background = 0x00000025,
            font = { color = 0xF8F8F8FF, size = 20 },
            text = {
                "This is",
                "Multi line text",
                "Really muse_canvasulti line!",
                "No, I'm serious! It's MULTI LINE, LOOK!"
            },
        }
    }
}

function love.update(dt)
    menu = gui.render(html)
end

function love.mousepressed( x, y, mb )
end

function love.mousemoved( x, y, dx, dy, istouch )
    gui.mousemoved(menu)
end

function love.keypressed(k)
    if k == "escape" then
        love.event.quit(0)
    end
end

function love.load()
    love.window.setMode(800, 800)--, {resizable = true, fullscreentype = "desktop"})
end

function love.draw()
    gui.draw(menu)
end
