local GameplayOverlay = require("game_manager.GameplayOverlay")
local editor_mode = require("editor.editor_mode")
local editor_gui = require("game_manager.editor_gui")
local Platform = require("game_objects.Platform")
local Pivot = require("game_objects.Pivot")
local Slingshot = require("game_objects.Slingshot")
local Wall = require("game_objects.Wall")
local Vec2 = require("Vec2")
local util = require("util")

local EditorOverlay = {}
EditorOverlay.__index = EditorOverlay
setmetatable(EditorOverlay, GameplayOverlay)

function EditorOverlay:new(scene_data, actions)
    local obj = GameplayOverlay:new(scene_data, actions)

    local function add_to_editor(obj)
        editor_mode:add_to_scene(obj)
        editor_mode:select_single(obj)
    end

    obj.gui = editor_gui:get_scene({
        platform = function()
            add_to_editor(Platform:new())
        end,
        pivot = function()
            add_to_editor(Pivot:new())
        end,
        slingshot = function()
            add_to_editor(Slingshot:new())
        end,
        wall = function()
            add_to_editor(Wall:new())
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

function EditorOverlay:move_camera_if_player_out_of_bounds(dt)

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

function EditorOverlay:wheelmoved(x, y)
    editor_mode:wheelmoved(x, y)
end

return EditorOverlay


