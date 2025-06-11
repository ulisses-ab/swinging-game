local util = require("util")
local Vec2 = require("Vec2")
local Overlay = require("game_manager.overlays.Overlay")
local SelectionFrame = require("editor.SelectionFrame")

local EditorMode = {}
EditorMode.__index = EditorMode
setmetatable(EditorMode, Overlay)

function EditorMode:new(base_scene)
    local obj = Overlay:new(base_scene)

    obj.base_scene = base_scene
    obj.selection_frames = {}
    obj.area_select_start = nil
    obj.drag_start = nil
    obj.has_dragged = false
    obj.get_mouse_position = nil
    obj.HOVER_MARGIN = 10

    return setmetatable(obj, EditorMode)
end

function EditorMode:get_hovering_object()
    local x, y = self.base_scene:get_mouse_position()

    for _, object in ipairs(self.base_scene.objects) do
        local bounding_box = object:get_bounding_box()
        if util.is_inside_rectangle(Vec2:new(x, y), bounding_box.position, bounding_box.size, hover_margin) then
            return object
        end
    end
end

function EditorMode:get_area_select_bounding_box()
    local mx, my = self.base_scene:get_mouse_position()
    local ax = self.area_select_start.x
    local ay = self.area_select_start.y

    local x1 = math.min(mx, ax)
    local x2 = math.max(mx, ax)
    local y1 = math.min(my, ay)
    local y2 = math.max(my, ay)

    local sx = x2 - x1
    local sy = y2 - y1

    return {
        position = Vec2:new(x1, y1),
        size = Vec2:new(sx, sy)
    }
end

function EditorMode:get_objects_inside_area_select()
    local bounding_box = self:get_area_select_bounding_box()

    local objects = {}

    for _, object in ipairs(self.base_scene.objects) do
        if util.is_inside_rectangle(object.position, bounding_box.position, bounding_box.size) then
            table.insert(objects, object)
        end
    end

    return objects
end

function EditorMode:update(dt)
    self:check_if_has_dragged()

    for _, frame in ipairs(self.selection_frames) do
        frame:update(dt)
    end

    if self:get_hovering_object() then
        util.set_hand_cursor()
    end

    self.base_scene:set_player_spawns()
end

function EditorMode:check_if_has_dragged()
    local mx, my = self.base_scene:get_mouse_position()

    if 
        drag_start and
        (math.abs(mx-drag_start.x) > 0 or
        math.abs(my-drag_start.y) > 0)
    then
        self.has_dragged = true
    end
end

function EditorMode:draw()
    love.graphics.push()
    love.graphics.scale(self.base_scene.camera_scale, self.base_scene.camera_scale) 
    love.graphics.translate(self.base_scene.camera_translate.x, self.base_scene.camera_translate.y)

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

function EditorMode:make_selection_frame(object, show_sliders)
    if show_sliders == nil then
        show_sliders = true
    end

    return SelectionFrame:new(
        object, 
        self.base_scene,
        function(obj)
            self.selection_frames = {}
            self.base_scene:remove(obj)
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

function EditorMode:select_single(obj)
    self.selection_frames = {
        self:make_selection_frame(obj)
    }
end

function EditorMode:mousepressed(x, y, button, istouch, presses)
    x, y = self.base_scene:get_mouse_position()

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

function EditorMode:mousereleased(x, y, button, istouch, presses)
    x, y = self.base_scene:get_mouse_position()

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

function EditorMode:keypressed(key)
    for _, frame in ipairs(self.selection_frames) do
        frame:keypressed(key)
    end

    self:add_to_base_scene(obj)
end

function EditorMode:add_to_base_scene(obj)
    obj.position = self.base_scene.camera_translate:mul(-1)

    if self.base_scene and obj then
        self.base_scene:add(obj)
    end
end

function EditorMode:wheelmoved(x, y)
    if not self.base_scene then return end

    self.base_scene.camera_scale = math.min(3, math.max(self.base_scene.camera_scale + y * 0.1, 0.15))
end

return EditorMode