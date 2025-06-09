local util = require("util")
local Bullet = require("game_objects.Bullet")
local Vec2 = require("Vec2")

local SelectionFrame = {}
SelectionFrame.__index = SelectionFrame

local margin = 10

function SelectionFrame:new(owner, delete, show_sliders, notify_dragging)
    local mx, my = owner:get_mouse_position()

    local obj = {
        owner = owner,
        delete = delete,
        notify_dragging = notify_dragging,
        slider_margin = 5,
        slider_size = 10,
        dragging_slider = nil,
        dragging_offset = Vec2:new(mx, my):sub(owner.position),
        is_dragging = false,
    }

    obj.sliders = show_sliders and self:get_sliders(owner) or {}

    return setmetatable(obj, SelectionFrame)
end

function SelectionFrame:draw()
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("line", 
        self.owner.position.x - margin - self.owner.width/2, 
        self.owner.position.y - margin - self.owner.height/2, 
        self.owner.width + margin * 2, 
        self.owner.height + margin * 2
    )

    for _, slider in pairs(self.sliders) do
        local slider_position = slider.position()
        love.graphics.rectangle("fill", slider_position.x - self.slider_size/2, slider_position.y - self.slider_size/2, self.slider_size, self.slider_size)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function SelectionFrame:update(dt)
    if self:cursor_is_over_owner() then
        util.set_hand_cursor()
    end

    local mx, my = self.owner:get_mouse_position()

    if self.dragging_slider then
        self.dragging_slider.action(mx, my)
    end

    if self.is_dragging then
        util.set_hand_cursor()
        self.owner.position = Vec2:new(mx, my):sub(self.dragging_offset)
    end

    local hovered_slider = self:get_hovered_slider()
    if hovered_slider then
        util.set_hand_cursor()
    end
end

function SelectionFrame:get_hovered_slider()
    local mx, my = self.owner:get_mouse_position()

    for _, slider in pairs(self.sliders) do
        local slider_position = slider.position()
        if util.is_within_margin(Vec2:new(mx, my), slider_position, self.slider_size + self.slider_margin) then
            return slider
        end
    end

    return nil
end

function SelectionFrame:start_dragging(x, y)
    self.dragging_offset = Vec2:new(x, y):sub(self.owner.position)
    self.is_dragging = true
end

function SelectionFrame:mousepressed(x, y, button, istouch, presses)
    local is_over_owner = self:cursor_is_over_owner()

    if is_over_owner then
        self.notify_dragging(x, y)
        return true
    end

    self.dragging_slider = self:get_hovered_slider()
    if self.dragging_slider then return true end

    return false
end

function SelectionFrame:mousereleased(x, y, button, istouch, presses)
    self.dragging_slider = nil
    self.is_dragging = false
end

function SelectionFrame:keypressed(key)
    if key == "backspace" then
        self.delete(self.owner)
    end
end

function SelectionFrame:cursor_is_over_owner()
    local mx, my = self.owner:get_mouse_position()
    return util.is_within_margin(Vec2:new(mx, my), self.owner.position, margin + self.owner.width/2, margin + self.owner.height/2)
end

local pivot_sliders = require("editor.sliders.pivot_sliders")
local platform_sliders = require("editor.sliders.platform_sliders")
local slingshot_sliders = require("editor.sliders.slingshot_sliders")
local wall_sliders = require("editor.sliders.wall_sliders")

function SelectionFrame:get_sliders(owner)
    if owner.type == "Pivot" then
        return pivot_sliders(owner)
    elseif owner.type == "Slingshot" then
        return slingshot_sliders(owner)
    elseif owner.type == "Platform" then
        return platform_sliders(owner, margin)
    elseif owner.type == "Wall" then
        return wall_sliders(owner, margin)
    end

    return {}
end

return SelectionFrame