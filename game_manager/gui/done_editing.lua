local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local util = require("util")
local InputReader = require("game_objects.InputReader")

local done_editing = {

}

function done_editing:get_scene(actions)
    local scene = Scene:new()

    local insert_title = TextBox:new(Vec2:new(0, -100), 800, 400, "insira um nome para o nível:")
    local title = TextBox:new(Vec2:new(0, 50), 1200, 60, "", {borders = true, margin = 10})
    local quit_button = Button:new(Vec2:new(-480, -250), 80, 80, "←", actions.quit)
    local done_button = Button:new(Vec2:new(0, 200), 330, 60, "pronto", function() actions.done(title.text) end)

    local input_text = ""

    local function update_text()
        title.text = input_text
    end

    local input_reader = InputReader:new(function(t)
        if #input_text >= 40 then return end
        input_text = input_text .. t
        update_text()
    end)

    local backspace_timer = 0
    local BACKSPACE_INTERVAL = 0.3

    scene.keypressed = function(self, key)
        Scene.keypressed(self, key)

        backspace_timer = 0

        if key == "backspace" then
            input_text = input_text:sub(1, -2)
            backspace_timer = 0
            update_text()
            return
        end
    end

    local deleted_timer = 0
    local DELETING_INTERVAL = 0.018

    scene.update = function(self, dt)
        Scene.update(self, dt)

        backspace_timer = backspace_timer + dt
        deleted_timer = deleted_timer + dt

        if 
            backspace_timer > BACKSPACE_INTERVAL and 
            util.input:is_down("backspace") and
            deleted_timer > DELETING_INTERVAL and
            #input_text >= 1
        then
            deleted_timer = 0
            input_text = input_text:sub(1, -2)
            update_text()
        end
    end

    scene:add(done_button)
    scene:add(quit_button)
    scene:add(insert_title)
    scene:add(input_reader)
    scene:add(title)

    scene.camera_scale = 0.75

    return scene
end

return done_editing