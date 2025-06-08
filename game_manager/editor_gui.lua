local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local util = require("util")

local editor_gui = {

}

function editor_gui:get_scene(actions)
    local scene = Scene:new()

    local platform_button = Button:new(Vec2:new(-400, 260), 330, 60, "plataforma", actions.platform)
    local pivot_button = Button:new(Vec2:new(0, 260), 330, 60, "pivô", actions.pivot)
    local slingshot_button = Button:new(Vec2:new(400, 260), 330, 60, "estilingue", actions.slingshot)
    local wall_button = Button:new(Vec2:new(0, 360), 330, 60, "parede", actions.wall)

    scene:add(platform_button)
    scene:add(pivot_button)
    scene:add(slingshot_button)
    scene:add(wall_button)
    scene.camera_scale = 0.75

    return scene
end

return editor_gui