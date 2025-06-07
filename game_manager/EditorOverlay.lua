local GameplayOverlay = require("game_manager.GameplayOverlay")
local editor_mode = require("editor.editor_mode")
local editor_gui = require("game_manager.editor_gui")
local Platform = require("game_objects.Platform")
local Pivot = require("game_objects.Pivot")
local Slingshot = require("game_objects.Slingshot")
local Vec2 = require("Vec2")
local util = require("util")

local EditorOverlay = {}
EditorOverlay.__index = EditorOverlay
setmetatable(EditorOverlay, GameplayOverlay)

function EditorOverlay:new(scene_data, actions)
    local sw, sh = util.get_dimensions()
    local center = Vec2:new(sw/2, sh/2)

    local obj = GameplayOverlay:new(scene_data, actions)

    obj.gui = editor_gui:get_scene({
        platform = function()
            editor_mode.editing_scene:add(Platform:new(center))
        end,
        pivot = function()
            editor_mode.editing_scene:add(Pivot:new(center))
        end,
        slingshot = function()
            editor_mode.editing_scene:add(Slingshot:new(center))
        end,
    })

    editor_mode:start_editing(obj.game_scene)

    return setmetatable(obj, EditorOverlay)
end

function EditorOverlay:update(dt)
    GameplayOverlay.update(self, dt)
    editor_mode:update(dt)
    self.gui:update(dt)
    self.countdown = -1
end

function EditorOverlay:draw()
    love.graphics.push()
    GameplayOverlay.draw(self, dt)
    editor_mode:draw()

    love.graphics.pop()
    self.gui:draw()
end

function EditorOverlay:keypressed(key)
    GameplayOverlay.keypressed(self, key)
    editor_mode:keypressed(key)
    self.gui:keypressed(key)
end

function EditorOverlay:keyreleased(key)
    GameplayOverlay.keyreleased(self, key)
    editor_mode:keyreleased(key)
    self.gui:keyreleased(key)
end

function EditorOverlay:mousepressed(x, y, button)
    GameplayOverlay.mousepressed(self, x, y, button)
    editor_mode:mousepressed(x, y, button)
    self.gui:mousepressed(x, y, button)
end

function EditorOverlay:mousereleased(x, y, button)
    GameplayOverlay.mousereleased(self, x, y, button)
    editor_mode:mousereleased(x, y, button)
    self.gui:mousereleased(x, y, button)
end

return EditorOverlay


