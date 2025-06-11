local Scene = require("Scene")
local Scene = require("Scene")

local Overlay = {}
Overlay.__index = Overlay
setmetatable(Overlay, Scene)

function Overlay:new(wrapped)
    local obj = Scene:new()

    obj.wrapped = wrapped
    obj:add(wrapped)

    return setmetatable(obj, Overlay)
end

return Overlay