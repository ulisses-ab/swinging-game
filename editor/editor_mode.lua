local util = require("util")
local Vec2 = require("Vec2")
local Enemy = require("game_objects.Enemy")
local Platform = require("game_objects.Platform")
local Player = require("game_objects.Player")
local Pivot = require("game_objects.Pivot")
local Slingshot = require("game_objects.Slingshot")
local SelectionFrame = require("editor.SelectionFrame")

local editor_mode = {
    editing_scene = nil,
    selection_frame = nil,
}

local hover_margin = 10

function editor_mode:start_editing(scene)
    self.editing_scene = scene
end 

function editor_mode:stop_editing()
    self.editing_scene = nil
end

function editor_mode:get_hovering_object()
    if not self.editing_scene then
        return nil
    end

    local x, y = util.input:get_mouse_position()

    for _, object in ipairs(self.editing_scene.objects) do
        local bounding_box = object:get_bounding_box()
        if util.is_inside_rectangle(Vec2:new(x, y), bounding_box.position, bounding_box.size, hover_margin) then
            return object
        end
    end
end

function editor_mode:delete_object(object)
    self.editing_scene:remove(object)
end

function editor_mode:update(dt)
    if self.selection_frame then
        self.selection_frame:update(dt)
    end

    if self:get_hovering_object() then
        util.set_hand_cursor()
    elseif not self.selection_frame then
        util.set_default_cursor()
    end
end

function editor_mode:draw()
    if self.selection_frame then
        self.selection_frame:draw()
    end
end

function editor_mode:mousepressed(x, y, button, istouch, presses)
    if self.selection_frame and self.selection_frame:mousepressed(x, y, button, istouch, presses) then
        return
    end
        

    local hovered_object = self:get_hovering_object()

    if hovered_object then
        self.selection_frame = SelectionFrame:new(hovered_object, function()
            self.selection_frame = nil
        end, function(obj)
            self:delete_object(obj)
        end)
    end
end

function editor_mode:mousereleased(x, y, button, istouch, presses)
    if self.selection_frame then
        self.selection_frame:mousereleased(x, y, button, istouch, presses)
    end
end

function editor_mode:keypressed(key)
    if not self.editing_scene then
        return
    end

    if self.selection_frame then
        self.selection_frame:keypressed(key)
    end

    local mx, my = util.input:get_mouse_position()
    local pos = Vec2:new(mx, my)
    local obj = nil

    if key == "1" then
        obj = Player:new(pos)
    elseif key == "2" then
        obj = Platform:new(pos)
    elseif key == "3" then
        obj = Pivot:new(pos)
    elseif key == "4" then
        obj = Slingshot:new(pos)
    elseif key == "5" then
        obj = Enemy:new(pos)
    end

    if self.editing_scene and obj then
        self.editing_scene:add(obj)
    end
end

function editor_mode:keyreleased(key)

end

return editor_mode