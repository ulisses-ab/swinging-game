local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")
local utf8 = require("utf8")

local InputReader = {}
InputReader.__index = InputReader
setmetatable(InputReader, GameObject)

InputReader.type = "InputReader"

function InputReader:new(action)
    local obj = GameObject:new()

    obj.action = action

    return setmetatable(obj, self)
end

function InputReader:draw()

end

function InputReader:update()

end

function InputReader:textinput(t)
    if utf8.len(t) then
        self.action(t)
    end
end

return InputReader