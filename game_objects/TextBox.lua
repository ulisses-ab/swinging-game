local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")
local utf8 = require("utf8")

local TextBox = {}
TextBox.__index = TextBox
setmetatable(TextBox, GameObject)

TextBox.type = "TextBox"

function TextBox:new(position, width, height, text, config)
    local obj = GameObject:new(position)

    obj.width = width
    obj.height = height

    obj.config = config or { }
    obj.text = text
    obj.font = love.graphics.newFont("assets/fonts/default.ttf", 28)
    obj.text_size = 24
    return setmetatable(obj, self)
end

function TextBox:update(dt)

end

function TextBox:draw() 
    if self.config.borders then
        local margin = self.config.margin or 0
        love.graphics.rectangle("line", 
            self.position.x  - self.width / 2 - margin, 
            self.position.y  - self.height / 2 - margin, 
            self.width + 2*margin, 
            self.height + 2*margin
        )
    end

    if not utf8.len(self.text) then
        print(self.text)
        return
    end

    love.graphics.setFont(self.font, self.text_size)
    love.graphics.printf(
        self.text,
        self.position.x  - self.width / 2,
        self.position.y - love.graphics.getFont():getHeight() / 2,
        self.width,
        "center"
    )
end

return TextBox