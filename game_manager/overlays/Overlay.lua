local Updater = require("Updater")
local Scene = require("Scene")

local Overlay = {}
Overlay.__index = Overlay
setmetatable(Overlay, Updater)

function Overlay:new(wrapped)
    local obj = Updater:new()

    obj.wrapped = wrapped
    obj.scene = Scene:new()
    obj.scene:add(wrapped)
    obj:add_uptadable(obj.scene)

    return setmetatable(obj, Overlay)
end

return Overlay