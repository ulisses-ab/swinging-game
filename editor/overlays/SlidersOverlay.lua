local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")
local pivot_sliders = require("editor.sliders.pivot_sliders")
local platform_sliders = require("editor.sliders.platform_sliders")
local slingshot_sliders = require("editor.sliders.slingshot_sliders")
local wall_sliders = require("editor.sliders.wall_sliders")

local SlidersOverlay = {}
SlidersOverlay.__index = SlidersOverlay
setmetatable(SlidersOverlay, Overlay)

function SlidersOverlay:new(wrapped)
    local obj = Overlay:new(wrapped)

    obj.sliders = {}

    obj.SLIDER_SIZE = 10
    obj.MARGIN = 20
    obj.CLICK_MARGIN = 15

    obj.dragging_slider = nil

    return setmetatable(obj, SlidersOverlay)
end

function SlidersOverlay:draw()
    Overlay.draw(self)
    self:draw_sliders()
end

function SlidersOverlay:draw_sliders()
    for _, obj_sliders in pairs(self.sliders) do
        for _, slider in pairs(obj_sliders) do
            local pos = slider.position()

            love.graphics.setColor(0, 0, 1)
            love.graphics.rectangle("fill", pos.x-self.SLIDER_SIZE/2, pos.y-self.SLIDER_SIZE/2, self.SLIDER_SIZE, self.SLIDER_SIZE)
            love.graphics.setColor(1,1,1)
        end
    end
end

function SlidersOverlay:update(dt)
    Overlay.update(self, dt)
    self:update_sliders()
end

function SlidersOverlay:update_sliders()
    local mx, my = self:get_mouse_position()
    local mouse_pos = Vec2:new(mx, my)

    for _, obj_sliders in pairs(self.sliders) do
        for _, slider in pairs(obj_sliders) do
            local position = slider.position()

            if util.is_within_margin(mouse_pos, position, self.SLIDER_SIZE/2 + self.CLICK_MARGIN) then
                util.set_hand_cursor()
            end
        end
    end

    if self.dragging_slider then
        self.dragging_slider.action(mx, my)
    end
end

function SlidersOverlay:mousepressed(...)
    local mx, my = self:get_mouse_position()
    local mouse_pos = Vec2:new(mx, my)

    for _, obj_sliders in pairs(self.sliders) do
        for _, slider in pairs(obj_sliders) do
            local position = slider.position()

            if util.is_within_margin(mouse_pos, position, self.SLIDER_SIZE/2 + self.CLICK_MARGIN) then
                self.dragging_slider = slider
                return true
            end
        end
    end

    Overlay.mousepressed(self, ...)
end

function SlidersOverlay:mousereleased(...)
    self.dragging_slider = nil

    Overlay.mousereleased(self, ...)
end

function SlidersOverlay:make_sliders(obj)
    local sliders = self:slider_factory(obj)

    if sliders then
        self.sliders[obj] = sliders
    end
end

function SlidersOverlay:delete_sliders()
    self.sliders = {}
end

function SlidersOverlay:slider_factory(obj)
    if obj.type == "Pivot" then
        return pivot_sliders(obj)
    elseif obj.type == "Slingshot" then
        return slingshot_sliders(obj)
    elseif obj.type == "Platform" then
        return platform_sliders(obj, self.MARGIN)
    elseif obj.type == "Wall" then
        return wall_sliders(obj, self.MARGIN)
    end
end

return SlidersOverlay