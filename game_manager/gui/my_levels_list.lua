local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local util = require("util")
local GameObject = require("game_objects.GameObject")

local my_levels_list = {

}

function my_levels_list:get_scene(actions)
    local sw, sh = util.get_dimensions()

    local scene = Scene:new()

    if not love.filesystem.getInfo("my_levels") then
        love.filesystem.createDirectory("my_levels")
    end

    local items = love.filesystem.getDirectoryItems("my_levels")
    local y_start = 0
    local y_offset = 72

    local level_buttons = {}
    local share_buttons = {}

    local share_time = -10

    local quit_button = Button:new(Vec2:new(-350, -150), 60, 60, "←", actions.quit)
    quit_button.z = 2
    local add_button = Button:new(Vec2:new(320, -150), 200, 60, "criar", actions.edit_scene)
    add_button.z = 2

    local cover = GameObject:new(Vec2:new(0, -800))
    cover.width = 10000
    cover.height = 1470
    cover.z = 1

    cover.draw = function(self)
        love.graphics.setColor(0, 0, 0, 1)
        GameObject.draw(self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.line(-500, self.position.y + self.height/2, 500, self.position.y + self.height/2)
    end

    scene:add(quit_button)
    scene:add(add_button)
    scene:add(cover)

    local function update_level_buttons()
        for i, button in ipairs(level_buttons) do
            button.position = Vec2:new(button.position.x, y_start + (i-1) * y_offset)
        end 

        for i, button in ipairs(share_buttons) do
            button.position = Vec2:new(button.position.x, y_start + (i-1) * y_offset)
        end 
    end

    scene.wheelmoved = function(self, x, y)
        y_start = y_start + y * 40

        y_start = math.max(-#level_buttons * y_offset, math.min(y_start, 0))

        if y_start < 250 - #level_buttons * y_offset then
            y_start = math.max(250 - #level_buttons * y_offset)
        end
        
        update_level_buttons()
    end

    local share_notice = TextBox:new(Vec2:new(0, 250), 800, 80, "nível copiado para a área de transferência", {
        padding = 30,
        margin = 10,
        background_color = {
            r = 0, g = 0, b = 0, a = 1
        },
        borders = true,
    })
    share_notice.text_size = 20
    share_notice.z = 3
    
    scene:add(share_notice)

    local SHARE_NOTICE_TIME = 3

    scene.update = function(self, dt)
        Scene.update(self, dt)

        if love.timer.getTime() - share_time > SHARE_NOTICE_TIME then
            share_notice.config.visible = false
        else
            share_notice.config.visible = true
        end
    end

    for i, file in ipairs(items) do
        local button = Button:new(Vec2:new(0, y_start + (i-1) * y_offset), 950, 60, file, function()
            actions.play(love.filesystem.read("my_levels/" .. file))
        end)

        local share_button = Button:new(Vec2:new(325, y_start + (i-1) * y_offset), 300, 60, "compartilhar", function()
            love.system.setClipboardText(love.filesystem.read("my_levels/" .. file))
            share_time = love.timer.getTime()
            share_notice.text = "'" .. file .. "' copiado para a área de transferência"
        end)
        share_button.text_size = 15

        table.insert(level_buttons, button)
        table.insert(share_buttons, share_button)

        scene:add(button)
        --scene:add(share_button)

        scene.camera_translate.y = -100
    end


    return scene
end

return my_levels_list