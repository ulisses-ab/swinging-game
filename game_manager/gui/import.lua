local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local GameObject = require("game_objects.GameObject")
local InputReader = require("game_objects.InputReader")
local utf8 = require("utf8")

return function(actions)
    local scene = Scene:new()

    local code_font = love.graphics.newFont("assets/fonts/default.ttf", 15)

    local quit_button = Button:new(Vec2:new(-430, -280), 60, 60, "←", actions.quit)
    local instruction = TextBox:new(Vec2:new(0, -220), 1000, 60, "insira aqui o código do nível:")
    local code_box = TextBox:new(Vec2:new(0, 20), 800, 360, "", {justify = "top", align = "left", padding = 15}, code_font)
    local border_box = TextBox:new(Vec2:new(0, 20), 800, 360, "", {borders = true, padding = 15})

    local done_button = Button:new(Vec2:new(310, 290), 180, 70, "OK", function()
        actions.done(code_box.text)
    end)

    local clear_button = Button:new(Vec2:new(-110, 290), 180, 70, "limpar", function()
        code_box.text = ""
    end)

    local paste_button = Button:new(Vec2:new(-310, 290), 180, 70, "colar", function()
        if not utf8.len(love.system.getClipboardText()) then return end
        code_box.text = code_box.text .. love.system.getClipboardText()
    end)

    local input_reader = InputReader:new(function(t)
        if not utf8.len(t) then return end
        code_box.text = code_box.text .. t
    end)

    local backspace_timer = 0
    local BACKSPACE_INTERVAL = 0.3

    scene.keypressed = function(self, key)
        if key == "v" and util.input:is_down("lctrl") then
            if not utf8.len(love.system.getClipboardText()) then return end
            code_box.text = code_box.text .. love.system.getClipboardText()
        end

        backspace_timer = 0

        if key == "backspace" then
            code_box.text = util.remove_last_character(code_box.text)
            return
        end
    end

    local deleted_timer = 0
    local DELETING_INTERVAL = 0.018

    local alert_timer = 0
    local ALERT_DURATION = 3
    scene.alert = function(self)
        alert_timer = ALERT_DURATION
    end

    local alert = TextBox:new(Vec2:new(0, 150), 800, 80, "código inválido", {
        padding = 30,
        margin = 10,
        background_color = {
            r = 0, g = 0, b = 0, a = 1
        },
        borders = true
    })
    alert.z = 2

    scene:add(alert)

    scene.update = function(self, dt)
        Scene.update(self, dt)

        backspace_timer = backspace_timer + dt
        alert_timer = alert_timer - dt
        deleted_timer = deleted_timer + dt

        if 
            backspace_timer > BACKSPACE_INTERVAL and 
            util.input:is_down("backspace") and
            deleted_timer > DELETING_INTERVAL and
            #code_box.text >= 1
        then
            deleted_timer = 0
            code_box.text = util.remove_last_character(code_box.text)
        end

        if alert_timer > 0 then
            alert.config.visible = true
        else
            alert.config.visible = false
        end
    end

    scrollable_scene = Scene:new()
    scrollable_scene:add(code_box)

    scrollable_scene.wheelmoved = function(self, x, y)
        local _, lines = code_font:getWrap(code_box.text, 800)
        local text_height = #lines * code_font:getHeight()

        local min_translate = math.min(0, -(text_height - 360))
        self.camera_translate.y = math.min(0, math.max(min_translate, self.camera_translate.y + 50 * y))
    end

    scrollable_scene.draw = function(self)
        local sw, sh = love.graphics.getDimensions()
        love.graphics.setScissor(
            0, sh/2-160, sw, 360
        )
        Scene.draw(self)
        love.graphics.setScissor()
    end

    scene:add(quit_button)
    scene:add(instruction)
    scene:add(scrollable_scene)
    scene:add(done_button)
    scene:add(clear_button)
    scene:add(input_reader)
    scene:add(paste_button)
    scene:add(border_box)

    return scene
end