local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local util = require("util")
local InputReader = require("game_objects.InputReader")
local utf8 = require("utf8")

return function(actions, default_name)
    local scene = Scene:new()

    local ask_if_substitute

    local insert_title = TextBox:new(Vec2:new(0, -100), 800, 400, "insira um nome para o nível:")
    local title = TextBox:new(Vec2:new(0, 50), 1200, 60, "", {borders = true, margin = 10})
    local quit_button = Button:new(Vec2:new(-480, -250), 80, 80, "←", actions.quit)
    local done_button = Button:new(Vec2:new(0, 200), 330, 60, "pronto", function() 
        if love.filesystem.read("my_levels/"..title.text) then
            ask_if_substitute()
        else
            actions.done(title.text, true)
        end
    end)

    title.text = default_name or ""

    local input_reader = InputReader:new(function(t)
        if not utf8.len(t) then return end
        if #title.text >= 40 then return end
        title.text = title.text .. t
    end)

    local backspace_timer = 0
    local BACKSPACE_INTERVAL = 0.3

    scene.keypressed = function(self, key)
        Scene.keypressed(self, key)

        backspace_timer = 0

        if key == "backspace" then
            title.text = util.remove_last_character(title.text)
            backspace_timer = 0
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
            #title.text >= 1
        then
            deleted_timer = 0
            title.text = util.remove_last_character(title.text)
        end
    end

    scene:add(done_button)
    scene:add(quit_button)
    scene:add(insert_title)
    scene:add(input_reader)
    scene:add(title)

    scene.camera_scale = 0.75

    local global_scene = Scene:new()
    global_scene:add(scene)

    local substitute_active = false

    local unask_if_substitute

    local ask_if_substitute_scene = Scene:new()

    local text_substitute = TextBox:new(Vec2:new(0, -50), 1000, 100, "um nível com este nome já existe. deseja substituí-lo?")
    local no_substitute = Button:new(Vec2:new(200, 100), 300, 80, "não substituir", function() actions.done(title.text, false) end)
    local yes_substitute = Button:new(Vec2:new(-200, 100), 300, 80, "substituir", function() actions.done(title.text, true) end)
    local back_substitute = Button:new(Vec2:new(-480, -250), 80, 80, "←", function() unask_if_substitute() end)

    ask_if_substitute_scene:add(text_substitute)
    ask_if_substitute_scene:add(yes_substitute)
    ask_if_substitute_scene:add(no_substitute)
    ask_if_substitute_scene:add(back_substitute)

    ask_if_substitute = function()
        global_scene:reset_updatables()
        global_scene:add_updatable(ask_if_substitute_scene)
        substitute_active = true
    end

    unask_if_substitute = function()
        global_scene:reset_updatables()
        global_scene:add_updatable(scene)
        substitute_active = false
    end

    global_scene.draw = function(self)
        scene:draw()

        if substitute_active then
            love.graphics.setColor(0,0,0,0.98)
            util.draw_clear()
            love.graphics.setColor(1,1,1,1)
            ask_if_substitute_scene:draw()
        end 
    end

    return global_scene
end