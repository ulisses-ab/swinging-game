local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")

local CameraMovementOverlay = {}
CameraMovementOverlay.__index = CameraMovementOverlay
setmetatable(CameraMovementOverlay, Overlay)

function CameraMovementOverlay:new(wrapped, base_scene)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene

    return setmetatable(obj, CameraMovementOverlay)
end

function CameraMovementOverlay:update(dt)
    Overlay.update(self, dt)

    self:zoom_based_on_velocity(dt)
    self:move_camera_if_player_out_of_bounds(dt)
end

function CameraMovementOverlay:zoom_based_on_velocity(dt)
    local player = self.base_scene:get_player()
    if not player then return end

    local MIN_SCALE = 0.45
    local MAX_SCALE = 1.1
    local SCALE_COEFFICIENT = 0.001
    local ZOOMING_VELOCITY = 0.5

    local target_scale = MAX_SCALE - player.velocity:length() * SCALE_COEFFICIENT * (MAX_SCALE - MIN_SCALE)

    local target_scale = math.min(MAX_SCALE, math.max(target_scale, MIN_SCALE))

    self.camera_scale = self.camera_scale + (target_scale - self.camera_scale) * ZOOMING_VELOCITY * dt
end

function CameraMovementOverlay:move_camera_if_player_out_of_bounds(dt)
    local player = self.base_scene:get_player()
    if not player then return end


    local absolute_translate = self.base_scene:get_absolute_translate()
    local absolute_scale = self.base_scene:get_absolute_scale()
    local absolute_player_pos = absolute_translate:add(player.position:mul(absolute_scale))

    local CORRECTION_SPEED = 4

    local x_limit = 150
    local x_correct = math.max(0, math.abs(absolute_player_pos.x) - x_limit) * util.sign(absolute_player_pos.x) * dt * CORRECTION_SPEED

    local y_limit = 100
    local y_correct = math.max(0, math.abs(absolute_player_pos.y) - y_limit) * util.sign(absolute_player_pos.y) * dt * CORRECTION_SPEED


    local parent_scale = self.scene and self.scene:get_absolute_scale() or 1
    self.camera_translate = self.camera_translate:sub(Vec2:new(x_correct, y_correct):div(parent_scale))
end

return CameraMovementOverlay