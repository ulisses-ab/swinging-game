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
    selection_frames = {},
    area_select_start = nil,
    drag_start = nil,
    has_dragged = false,
    get_mouse_position = nil,
}

local hover_margin = 10

function editor_mode:start_editing(scene)
    self.selection_frames = {}
    self.editing_scene = scene
    self.get_mouse_position = function()
        return scene:get_mouse_position()
    end
end 

function editor_mode:stop_editing()
    self.editing_scene = nil
end

function editor_mode:get_hovering_object()
    if not self.editing_scene then
        return nil
    end

    local x, y = self:get_mouse_position()

    for _, object in ipairs(self.editing_scene.objects) do
        local bounding_box = object:get_bounding_box()
        if util.is_inside_rectangle(Vec2:new(x, y), bounding_box.position, bounding_box.size, hover_margin) then
            return object
        end
    end
end

function editor_mode:get_objects_inside_area_select()
    if not self.area_select_start then
        return {}
    end

    local mx, my = self:get_mouse_position()
    local ax = self.area_select_start.x
    local ay = self.area_select_start.y

    local x1 = math.min(mx, ax)
    local x2 = math.max(mx, ax)
    local y1 = math.min(my, ay)
    local y2 = math.max(my, ay)

    local sx = x2 - x1
    local sy = y2 - y1

    local objects = {}

    for _, object in ipairs(self.editing_scene.objects) do
        if util.is_inside_rectangle(object.position, Vec2:new(x1, y1), Vec2:new(sx, sy)) then
            table.insert(objects, object)
        end
    end

    return objects
end

function editor_mode:update(dt)
    local mx, my = self:get_mouse_position()
    self:move_scene()
    
    if 
        drag_start and
        (math.abs(mx-drag_start.x) > 0 or
        math.abs(my-drag_start.y) > 0)
    then
        self.has_dragged = true
    end

    for _, frame in ipairs(self.selection_frames) do
        frame:update(dt)
    end

    if self:get_hovering_object() then
        util.set_hand_cursor()
    end

    self.editing_scene:set_player_spawns()
end

function editor_mode:move_scene()
    if not self.editing_scene then return end

    local MOVEMENT_SPEED = 50

    local movement = util.input:read_wasd():normalize():mul(-MOVEMENT_SPEED)

    local camera_scale = self.editing_scene.camera_scale

    local limit_x = 4000
    local limit_y = 2000

    self.editing_scene.camera_translate.x = math.max(-limit_x, math.min(self.editing_scene.camera_translate.x + movement.x, limit_x))
    self.editing_scene.camera_translate.y = math.max(-limit_y, math.min(self.editing_scene.camera_translate.y + movement.y, limit_y))
end

function editor_mode:draw()
    if not self.editing_scene then return end

    love.graphics.push()
    love.graphics.scale(self.editing_scene.camera_scale, self.editing_scene.camera_scale) 
    love.graphics.translate(self.editing_scene.camera_translate.x, self.editing_scene.camera_translate.y)

    if self.area_select_start ~= nil then
        love.graphics.setColor(0.7, 0.7, 1)
        local mx, my = self:get_mouse_position()
        local as = self.area_select_start
        love.graphics.rectangle("line", as.x, as.y, mx - as.x, my - as.y)
        love.graphics.setColor(0.7, 0.7, 1, 0.1)
        love.graphics.rectangle("fill", as.x, as.y, mx - as.x, my - as.y)
        love.graphics.setColor(1, 1, 1, 1)
    end

    for _, frame in ipairs(self.selection_frames) do
        frame:draw()
    end
    
    love.graphics.pop()
end

function editor_mode:make_selection_frame(object, show_sliders)
    if show_sliders == nil then
        show_sliders = true
    end

    return SelectionFrame:new(
        object, 
        function(obj)
            self.selection_frames = {}
            self.editing_scene:remove(obj)
        end,
        show_sliders,
        function(x, y)
            for _, frame in ipairs(self.selection_frames) do
                drag_start = Vec2:new(x, y)
                has_dragged = false
                frame:start_dragging(x, y)
            end
        end
    )
end

function editor_mode:select_single(obj)
    self.selection_frames = {
        self:make_selection_frame(obj)
    }
end

function editor_mode:mousepressed(x, y, button, istouch, presses)
    if not self.editing_scene then return end

    x, y = self.editing_scene:translate_xy(x, y)

    local clicked_on_frame = false
    for _, frame in ipairs(self.selection_frames) do
        if frame:mousepressed(x, y, button, istouch, presses) then
            clicked_on_frame = true
        end
    end
    if clicked_on_frame then 
        self.has_dragged = false
        return 
    else
        self.selection_frames = {}
    end
        
    local hovered_object = self:get_hovering_object()
    if hovered_object then
        self:select_single(hovered_object)
        local mx, my = self:get_mouse_position()
        self.selection_frames[1]:start_dragging(mx, my)
    else
        self.area_select_start = Vec2:new(x, y)
    end
end

function editor_mode:mousereleased(x, y, button, istouch, presses)
    if not self.editing_scene then return end

    x, y = self.editing_scene:translate_xy(x, y)

    local hovered_object = self:get_hovering_object()
    if hovered_object and not self.has_dragged then
        self:select_single(hovered_object)
    end


    for _, frame in ipairs(self.selection_frames) do
        frame:mousereleased(x, y, button, istouch, presses)
    end

    local inside_area = self:get_objects_inside_area_select()
    for _, obj in ipairs(inside_area) do
        table.insert(self.selection_frames, self:make_selection_frame(obj, #inside_area == 1 and true or false))
    end
    self.area_select_start = nil
    self.has_dragged = false
end

function editor_mode:keypressed(key)
    if not self.editing_scene then
        return
    end

    for _, frame in ipairs(self.selection_frames) do
        frame:keypressed(key)
    end

    local mx, my = self:get_mouse_position()
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
    else 
        return
    end

    self:add_to_scene(obj)
end

function editor_mode:add_to_scene(obj)
    obj.position = self.editing_scene.camera_translate:mul(-1)

    if self.editing_scene and obj then
        self.editing_scene:add(obj)
    end
end

function editor_mode:keyreleased(key)

end

function editor_mode:wheelmoved(x, y)
    if not self.editing_scene then return end

    self.editing_scene.camera_scale = math.min(3, math.max(self.editing_scene.camera_scale + y * 0.1, 0.15))
end

return editor_mode