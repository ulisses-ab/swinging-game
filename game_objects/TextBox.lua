local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")
local utf8 = require("utf8")

local TextBox = {}
TextBox.__index = TextBox
setmetatable(TextBox, GameObject)

TextBox.type = "TextBox"

function TextBox:new(position, width, height, text, config, font)
    local obj = GameObject:new(position)

    obj.width = width
    obj.height = height

    obj.config = config or { }
    obj.config.visible = true
    obj.text = text
    obj.font = font or love.graphics.newFont("assets/fonts/default.ttf", 24)

    return setmetatable(obj, self)
end

function TextBox:update(dt)

end

function TextBox:draw() 
    if not self.config.visible then return end

    local padding = self.config.padding or 0
    local margin = self.config.margin or 0

    if self.config.background_color then
        local bgc = self.config.background_color
        love.graphics.setColor(bgc.r,bgc.g, bgc.b, bgc.a or 1)
        love.graphics.rectangle("fill", 
            self.position.x  - self.width / 2 - padding - margin, 
            self.position.y  - self.height / 2 - padding - margin, 
            self.width + 2*padding + 2*margin, 
            self.height + 2*padding + 2*margin
        )
        love.graphics.setColor(1, 1, 1, 1)
    end

    if self.config.borders then
        love.graphics.rectangle("line", 
            self.position.x  - self.width / 2 - padding, 
            self.position.y  - self.height / 2 - padding, 
            self.width + 2*padding, 
            self.height + 2*padding
        )
    end

    if not utf8.len(self.text) then
        print(self.text)
        return
    end

    love.graphics.setFont(self.font)
    local _, lines = self.font:getWrap(self.text, self.width)
    local text_height = #lines * self.font:getHeight()
    
    local c = self.config.color or {r = 1, g = 1, b = 1}
    love.graphics.setColor(c.r,c.g, c.b, c.a or 1)
    love.graphics.printf(
        self.text,
        self.position.x  - self.width / 2,
        self.position.y - text_height / 2,
        self.width,
        self.config.align or "center"
    )
    love.graphics.setColor(1,1,1,1)
end

return TextBox