local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local util = require("util")

local editor_gui = {

}

function editor_gui:get_scene(actions)
    local sw, sh = util.get_dimensions()
    local scene = Scene:new()

    local platform_button = Button:new(Vec2:new(sw / 2 - 400, sh - 200), 330, 60, "plataforma", actions.platform)
    local pivot_button = Button:new(Vec2:new(sw / 2, sh - 200), 330, 60, "pivô", actions.pivot)
    local slingshot_button = Button:new(Vec2:new(sw / 2 + 400, sh - 200), 330, 60, "estilingue", actions.slingshot)

    scene:add(platform_button)
    scene:add(pivot_button)
    scene:add(slingshot_button)

    return scene
end

return editor_gui