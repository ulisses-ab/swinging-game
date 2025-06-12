local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")

local CameraMovementOverlay = {}
CameraMovementOverlay.__index = CameraMovementOverlay
setmetatable(CameraMovementOverlay, Overlay)

function CameraMovementOverlay:new(wrapped)
    local obj = Overlay:new(wrapped)

    return setmetatable(obj, CameraMovementOverlay)
end

function CameraMovementOverlay:update(dt)
    Overlay.update(self, dt)
    self:move_camera(dt)
end

function CameraMovementOverlay:move_camera(dt)
    local MOVEMENT_SPEED = 50

    local movement = util.input:read_wasd():normalize():mul(-MOVEMENT_SPEED)

    local limit_x = 4000
    local limit_y = 2000

    self.camera_translate.x = math.max(-limit_x, math.min(self.camera_translate.x + movement.x, limit_x))
    self.camera_translate.y = math.max(-limit_y, math.min(self.camera_translate.y + movement.y, limit_y))
end

function CameraMovementOverlay:wheelmoved(x, y)
    local MAX_SCALE = 3
    local MIN_SCALE = 0.15
    local ZOOMING_VELOCITY = 0.1

    self.camera_scale = math.min(MAX_SCALE, math.max(self.camera_scale + y * ZOOMING_VELOCITY, MIN_SCALE))
end



return CameraMovementOverlay