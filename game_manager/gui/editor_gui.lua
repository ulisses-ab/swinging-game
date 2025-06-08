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
    local wall_button = Button:new(Vec2:new(200, 360), 330, 60, "parede", actions.wall)
    local enemy_button = Button:new(Vec2:new(-200, 360), 330, 60, "inimigo", actions.enemy)

    local play_button = Button:new(Vec2:new(250, -300), 200, 100, "Testar", actions.play)
    local done_button = Button:new(Vec2:new(500, -300), 200, 100, "Pronto", actions.done)

    scene:add(platform_button)
    scene:add(pivot_button)
    scene:add(slingshot_button)
    scene:add(wall_button)
    scene:add(enemy_button)
    scene:add(play_button)
    scene:add(done_button)
    scene.camera_scale = 0.75

    return scene
end

return editor_gui