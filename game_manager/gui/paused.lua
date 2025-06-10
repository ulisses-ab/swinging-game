local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")

local paused = {

}

function paused:get_scene(actions)
    local sw, sh = util.get_dimensions()

    local scene = Scene:new()

    local title = TextBox:new(Vec2:new(0, -150), 400, 60, "Pausado")
    local continue_button = Button:new(Vec2:new(0, -50), 400, 60, "Continuar", actions.continue)
    local quit_button = Button:new(Vec2:new(0, 50), 400, 60, "Sair", actions.quit)

    scene:add(continue_button)
    scene:add(quit_button)
    scene:add(title)

    return scene
end

return paused