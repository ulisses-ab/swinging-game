local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")

local starting_menu = {

}

function starting_menu:get_scene(actions)
    local sw, sh = util.get_dimensions()

    local scene = Scene:new()

    local title = TextBox:new(Vec2:new(sw / 2, sh / 2 - 150), 400, 400, "gummi vs dogos")
    local start_button = Button:new(Vec2:new(sw / 2, sh / 2), 400, 100, "campanha", actions.start)
    local my_levels_button = Button:new(Vec2:new(sw / 2, sh / 2 + 150), 400, 100, "meus níveis", actions.my_levels)

    scene:add(start_button)
    scene:add(my_levels_button)
    scene:add(title)

    return scene
end

return starting_menu