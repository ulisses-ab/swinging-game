local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")

local DraggingOverlay = {}
DraggingOverlay.__index = DraggingOverlay
setmetatable(DraggingOverlay, Overlay)

function DraggingOverlay:new(wrapped, base_scene)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene
    obj.being_dragged = {}

    return setmetatable(obj, DraggingOverlay)
end

function DraggingOverlay:stop_dragging()
    self.being_dragged = {}
end

function DraggingOverlay:start_dragging(obj)
    local mx, my = self.base_scene:get_mouse_position()

    local offset = obj.position:sub(Vec2:new(mx, my))

    table.insert(self.being_dragged, {obj, offset})
end

function DraggingOverlay:update(dt)
    Overlay.update(self, dt)

    local mx, my = self.base_scene:get_mouse_position()
    local mouse_vec = Vec2:new(mx, my)

    for _, obj in ipairs(self.being_dragged) do
        obj[1].position = mouse_vec:add(obj[2])

        if obj[1].type == "Player" then
            obj[1]:set_spawn()
        end
    end
end


return DraggingOverlay