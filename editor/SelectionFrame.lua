local util = require("util")
local Bullet = require("game_objects.Bullet")
local Vec2 = require("Vec2")

local SelectionFrame = {}
SelectionFrame.__index = SelectionFrame

local margin = 10

function SelectionFrame:new(owner, close, delete)
    local mx, my = util.input:get_mouse_position()

    local obj = {
        owner = owner,
        close = close,
        delete = delte,
        slider_margin = 5,
        slider_size = 10,
        is_dragging_slider = false,
        current_slider = nil,
        dragging_offset = Vec2:new(mx, my):sub(owner.position),
        is_dragging = true,
    }

    obj.sliders = self:get_sliders(owner)

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
    else
        util.set_default_cursor()
    end

    if self.is_dragging_slider then
        local mx, my = util.input:get_mouse_position()
        self.current_slider.action(mx, my)
    end

    if self.is_dragging then
        util.set_hand_cursor()
        local mx, my = util.input:get_mouse_position()
        self.owner.position = Vec2:new(mx, my):sub(self.dragging_offset)
    end

    local hovered_slider = self:get_hovered_slider()

    if hovered_slider then
        util.set_hand_cursor()
        self.current_slider = hovered_slider
    else
        self.current_slider = nil
    end
end

function SelectionFrame:get_hovered_slider()
    if self.is_dragging_slider then
        return self.current_slider
    end

    local mx, my = util.input:get_mouse_position()

    for _, slider in pairs(self.sliders) do
        local slider_position = slider.position()
        if util.is_within_margin(Vec2:new(mx, my), slider_position, self.slider_size + self.slider_margin) then
            return slider
        end
    end

    return nil
end

function SelectionFrame:mousepressed(x, y, button, istouch, presses)
    if self.current_slider then
        self.is_dragging_slider = true
        return true
    end

    local is_over_owner = self:cursor_is_over_owner()

    if is_over_owner then
        self.is_dragging = true
        self.dragging_offset = Vec2:new(x, y):sub(self.owner.position)
    end

    if 
        not self.is_dragging_slider and 
        not self.is_dragging and
        not is_over_owner
    then
        self.close()
    end
end

function SelectionFrame:mousereleased(x, y, button, istouch, presses)
    self.is_dragging_slider = false
    self.is_dragging = false
end

function SelectionFrame:keypressed(key)
    if key == "backspace" then
        self.delete(owner)
    end
end

function SelectionFrame:cursor_is_over_owner()
    local mx, my = util.input:get_mouse_position()
    return util.is_within_margin(Vec2:new(mx, my), self.owner.position, margin + self.owner.height/2, margin + self.owner.height/2)
end

local pivot_sliders = require("editor.sliders.pivot_sliders")
local platform_sliders = require("editor.sliders.platform_sliders")
local slingshot_sliders = require("editor.sliders.slingshot_sliders")

function SelectionFrame:get_sliders(owner)
    if owner.type == "Pivot" then
        return pivot_sliders(owner)
    elseif owner.type == "Slingshot" then
        return slingshot_sliders(owner)
    elseif owner.type == "Platform" then
        return platform_sliders(owner, margin)
    end

    return {}
end

return SelectionFrame