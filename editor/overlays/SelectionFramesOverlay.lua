local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")

local SelectionFramesOverlay = {}
SelectionFramesOverlay.__index = SelectionFramesOverlay
setmetatable(SelectionFramesOverlay, Overlay)

function SelectionFramesOverlay:new(wrapped, base_scene)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene

    return setmetatable(obj, SelectionFramesOverlay)
end

functio