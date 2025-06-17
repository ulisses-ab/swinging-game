local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local GameObject = require("game_objects.GameObject")

return function(actions, file_names, scroll)
    local scene = Scene:new()

    local quit_button = Button:new(Vec2:new(-350, -150), 60, 60, "←", actions.quit)
    quit_button.z = 2
    local add_button = Button:new(Vec2:new(350, -150), 200, 60, "criar", actions.create)
    add_button.z = 2
    local import_button = Button:new(Vec2:new(130, -150), 200, 60, "importar", actions.import)
    import_button.z = 2

    local cover = GameObject:new(Vec2:new(0, -800))
    cover.width = 10000
    cover.height = 1420
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
    scene:add(import_button)

    local share_notice = TextBox:new(Vec2:new(0, 350), 800, 80, "nível copiado para a área de transferência", {
        padding = 30,
        margin = 10,
        background_color = {
            r = 0, g = 0, b = 0, a = 1
        },
        borders = true
    })
    share_notice.text_size = 20
    share_notice.z = 3
    
    scene:add(share_notice)

    local SHARE_NOTICE_TIME = 3
    local share_timer = -10

    scene.update = function(self, dt)
        Scene.update(self, dt)
        share_timer = share_timer - dt

        if share_timer < 0 then
            share_notice.config.visible = false
        else
            share_notice.config.visible = true
        end
    end

    local scrollable_scene = Scene:new()
    scrollable_scene.camera_translate.y = scroll or 0
    local y_offset = 180

    scrollable_scene.wheelmoved = function(self, x, y)
        local min_translate = math.min(0, -(#file_names-1) * y_offset + 300)
        self.camera_translate.y = math.min(0, math.max(self.camera_translate.y + y * 40, min_translate))
    end

    for i, file in ipairs(file_names) do
        local button = Button:new(Vec2:new(0, (i-1) * y_offset), 900, 60, file, function()
            actions.play(file)
        end)

        local share_button = Button:new(Vec2:new(300, (i-1) * y_offset + 60), 300, 60, "compartilhar", function()
            love.system.setClipboardText(love.filesystem.read("my_levels/" .. file))
            share_timer = love.timer.getTime()
            share_notice.text = "'" .. file .. "' copiado para a área de transferência"
        end)

        local edit_button = Button:new(Vec2:new(0, (i-1) * y_offset + 60), 300, 60, "editar", function()
            actions.edit(file)
        end)

        local delete_button = Button:new(Vec2:new(-300, (i-1) * y_offset + 60), 300, 60, "deletar", function()
            actions.delete(file)
        end)

        scrollable_scene:add(button)
        scrollable_scene:add(share_button)
        scrollable_scene:add(edit_button)
        scrollable_scene:add(delete_button)
    end

    scene:add(scrollable_scene)
    scene.camera_translate.y = -125

    scene.get_scroll = function(self)
        return scrollable_scene.camera_translate.y
    end


    return scene
end
