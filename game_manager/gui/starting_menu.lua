local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")

return function(actions)
    local scene = Scene:new()

    local title = TextBox:new(Vec2:new(0, 0 - 170), 400, 400, "gummi vs dogos")
    local start_button = Button:new(Vec2:new(0, -40), 400, 80, "campanha", actions.campaign)
    local my_levels_button = Button:new(Vec2:new(0, 0 + 70), 400, 80, "meus níveis", actions.my_levels)
    local exit_button = Button:new(Vec2:new(0, 0 + 180), 400, 80, "sair", actions.quit)

    scene:add(start_button)
    scene:add(my_levels_button)
    scene:add(exit_button)
    scene:add(title)

    return scene
end