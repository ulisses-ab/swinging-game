local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")

local SelectionOverlay = {}
SelectionOverlay.__index = SelectionOverlay
setmetatable(SelectionOverlay, Overlay)

function SelectionOverlay:new(wrapped, base_scene, dragging_overlay, sliders_overlay)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene

    obj.area_select_start = nil

    obj.selected = {}

    obj.dragging_overlay = dragging_overlay
    obj.sliders_overlay = sliders_overlay

    obj.MARGIN = 20

    return setmetatable(obj, SelectionOverlay)
end

function SelectionOverlay:update(dt)
    Overlay.update(self, dt)

    if self:hovered_object() then
        util.set_hand_cursor()
    end
end

function SelectionOverlay:hovered_object(margin)
    margin = margin or self.MARGIN

    for _, object in ipairs(self.base_scene.objects) do
        local mx, my = self.base_scene:get_mouse_position()

        if util.is_within_margin(Vec2:new(mx, my), object.position, object.width/2 + margin, object.height/2 + margin) then
            return object
        end
    end
end

function SelectionOverlay:mousepressed(...)
    local obj = self:hovered_object()
    local right_on_top = self:hovered_object(0)

    if right_on_top then
        self:click_on_obj(right_on_top)
        return
    end

    if Overlay.mousepressed(self, ...) then return true end

    if obj then
        self:click_on_obj(obj)
        return
    end

    self:deselect_all()
    self:start_area_select()
end

function SelectionOverlay:click_on_obj(obj)
    if not self:is_selected(obj) then 
        self:deselect_all()
        self:select(obj)
    end

    self:notify_dragging()
end

function SelectionOverlay:start_area_select()
    local x, y = self.base_scene:get_mouse_position()

    self.area_select_start = Vec2:new(x, y)
end

function SelectionOverlay:finish_area_select()
    if not self.area_select_start then return end

    local box = self:get_area_select_box()

    for _, object in ipairs(self.base_scene.objects) do
        if util.is_inside_rectangle(object.position, box.position, box.size) then
            self:weak_select(object)
        end
    end

    self.area_select_start = nil
end

function SelectionOverlay:get_area_select_box()
    if not self.area_select_start then return end

    local mx, my = self.base_scene:get_mouse_position()
    local ax, ay = self.area_select_start.x, self.area_select_start.y

    return {
        position = Vec2:new(math.min(mx, ax), math.min(my, ay)),
        size = Vec2:new(math.abs(mx-ax), math.abs(my-ay))
    }
end

function SelectionOverlay:draw()
    self:draw_area_select_rectangle()

    self:draw_frames()

    Overlay.draw(self)
end

function SelectionOverlay:draw_frames()
    for _, obj in ipairs(self.selected) do
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("line", 
            obj.position.x - obj.width/2 - self.MARGIN,
            obj.position.y - obj.height/2 - self.MARGIN,
            obj.width + 2*self.MARGIN,
            obj.height + 2*self.MARGIN
        )
        love.graphics.setColor(1,1,1)
    end
end

function SelectionOverlay:draw_area_select_rectangle()
    if not self.area_select_start then return end

    local box = self:get_area_select_box()

    love.graphics.setColor(0.7, 0.7, 1)
    love.graphics.rectangle("line", box.position.x, box.position.y, box.size.x, box.size.y)
    love.graphics.setColor(0.7, 0.7, 1, 0.1)
    love.graphics.rectangle("fill", box.position.x, box.position.y, box.size.x, box.size.y)
    love.graphics.setColor(1, 1, 1, 1)
end

function SelectionOverlay:mousereleased(...)
    Overlay.mousereleased(self, ...)

    self:finish_area_select()

    self.dragging_overlay:stop_dragging()
end

function SelectionOverlay:select(obj)
    table.insert(self.selected, obj)
    self.sliders_overlay:delete_sliders()
    self.sliders_overlay:make_sliders(obj)
end

function SelectionOverlay:deselect_all()
    self.selected = {}
    self.sliders_overlay:delete_sliders()
end

function SelectionOverlay:weak_select(obj)
    table.insert(self.selected, obj)
end

function SelectionOverlay:is_selected(obj)
    return util.is_obj_in_array(self.selected, obj)
end

function SelectionOverlay:notify_dragging()
    for _, sel in ipairs(self.selected) do
        self.dragging_overlay:start_dragging(sel)
    end
end

function SelectionOverlay:keypressed(key)
    if key == "backspace" then
        self:delete_selected()
        return
    end

    Overlay.keypressed(self, key)
end

function SelectionOverlay:delete_selected()
    for _, obj in ipairs(self.selected) do 
        if obj.type ~= "Player" then
            self.base_scene:remove(obj)
        end
    end

    self.sliders_overlay:delete_sliders()
    self.selected = {}
end

return SelectionOverlay