local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local util = require("util")

local done_editing = {

}

function done_editing:get_scene(actions)
    local scene = Scene:new()

    local done_button = Button:new(Vec2:new(0, 0), 330, 60, "diddy", actions.done)

    scene:add(done_button)

    scene.camera_scale = 0.75

    return scene
end

return done_editing