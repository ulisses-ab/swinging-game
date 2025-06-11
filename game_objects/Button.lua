local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")

local Button = {}
Button.__index = Button
setmetatable(Button, GameObject)

Button.type = "Button"

function Button:new(position, width, height, text, action, font)
    local obj = GameObject:new(position)

    obj.width = width
    obj.height = height
    obj.text = text
    obj.action = action
    obj.mouse_is_over = false
    obj.font = font or love.graphics.newFont("assets/fonts/default.ttf", 24)

    obj.is_clicking = false

    return setmetatable(obj, self)
end

function Button:update(dt)
    if self:cursor_is_over() then
        util.set_hand_cursor()
    else
        self.is_clicking = false
    end
end

function Button:cursor_is_over()
    local x, y = self.scene:get_mouse_position()
    return util.is_within_margin(Vec2:new(x, y), self.position, self.width/2, self.height/2)
end

function Button:draw() 
    local margin = 0

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", self.position.x-self.width/2-margin, self.position.y-self.height/2-margin, self.width+2*margin, self.height+2*margin)
    love.graphics.setColor(1, 1, 1, 1)


    love.graphics.rectangle("line", self.position.x-self.width/2, self.position.y-self.height/2, self.width, self.height)

    if self:cursor_is_over() then
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("fill", self.position.x-self.width/2, self.position.y-self.height/2, self.width, self.height)
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setFont(self.font)
    love.graphics.printf(
        self.text,
        self.position.x - self.width / 2,
        self.position.y - love.graphics.getFont():getHeight() / 2,
        self.width,
        "center"
    )
end

function Button:mousepressed(x, y)
    if self:cursor_is_over() then
        self.is_clicking = true
    end
end

function Button:mousereleased(x, y)
    if self.is_clicking then
        self.action()
    end
end

return Button