local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local paused = require("game_manager.gui.paused")
local util = require("util")
local PauseOverlay = require("game_manager.overlays.PauseOverlay")

local GameplayOverlay = {}
GameplayOverlay.__index = GameplayOverlay
setmetatable(GameplayOverlay, PauseOverlay)

function GameplayOverlay:new(scene, actions, paused_gui)
    local obj = PauseOverlay:new(scene, actions, paused_gui or paused)

    obj.game_timer = 0
    obj.show_timer = true
    obj.ending_timer = 0
    obj.ENDING_DURATION = 3.6
    obj.FADEOUT_START = 1.5
    obj.FADEOUT_END = 3
    obj.alpha = 1

    return setmetatable(obj, self)
end

function GameplayOverlay:update(dt)
    if self.game_scene:count_live_enemies() == 0 then
        self.ending_timer = self.ending_timer + dt / util.time_rate

        local fade_time = math.min(1, math.max(0, (self.ending_timer - self.FADEOUT_START) / (self.FADEOUT_END - self.FADEOUT_START)))
        self.alpha = 1 - fade_time

        if self.ending_timer > self.ENDING_DURATION then
            actions.quit()
        end
    else
        self.alpha = 1
        self.ending_timer = 0
    end

    PauseOverlay.update(self, dt)

    if not self:is_paused() then
        self.game_timer = self.game_timer + dt / util.time_rate * util.timer_time_rate
    end

    self:move_camera_if_player_out_of_bounds(dt)
    self:zoom_based_on_velocity(dt)
end

local function format_time(time)
    local minutes = math.floor(time / 60)
    local seconds = math.floor(time % 60)
    local centiseconds = math.floor((time * 100) % 100)

    if minutes == 0 then
        return string.format("%d.%02d", seconds, centiseconds)
    end

    return string.format("%d:%02d.%02d", minutes, seconds, centiseconds)
end

function GameplayOverlay:draw()
    local sw, sh = love.graphics.getDimensions()
    local canvas = love.graphics.newCanvas()
    local prev = love.graphics.getCanvas()

    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    self.game_scene:draw()

    if self.show_timer then
        local font = love.graphics.newFont("assets/fonts/default.ttf", 30)
        love.graphics.setFont(font)
        love.graphics.printf(
            format_time(self.game_timer),
            -800,
            -320,
            780, --width
            "right"
        )

        love.graphics.setColor(1,0,0)
        love.graphics.printf(
            self.game_scene:count_dead_enemies() .. "/" .. #self.game_scene.obj_by_type["Enemy"],
            20,
            -320,
            780, --width
            "left"
        )
        love.graphics.setColor(1,1,1)
    end

    love.graphics.setCanvas(prev)

    love.graphics.push()
    love.graphics.scale(self.camera_scale, self.camera_scale)
    love.graphics.translate(-sw/2, -sh/2)
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.draw(canvas)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()

    self:draw_pause()
end


function GameplayOverlay:move_camera_if_player_out_of_bounds(dt)
    local player = self.game_scene.obj_by_type["Player"][1]

    if not player then return end

    local absolute_player_pos = player.position:add(self.game_scene.camera_translate):mul(self.game_scene.camera_scale)

    local CORRECTION_SPEED = 8

    local x_limit = 150
    local x_correct = math.max(0, math.abs(absolute_player_pos.x) - x_limit) * util.sign(absolute_player_pos.x) * dt * CORRECTION_SPEED

    local y_limit = 100
    local y_correct = math.max(0, math.abs(absolute_player_pos.y) - y_limit) * util.sign(absolute_player_pos.y) * dt * CORRECTION_SPEED

    self.game_scene.camera_translate = self.game_scene.camera_translate:sub(Vec2:new(x_correct, y_correct))
end

function GameplayOverlay:zoom_based_on_velocity(dt)
    local player = self.game_scene.obj_by_type["Player"][1]
    if not player then return end

    local MIN_SCALE = 0.45
    local MAX_SCALE = 1.1
    local SCALE_COEFFICIENT = 0.001
    local ZOOMING_VELOCITY = 0.5

    local target_scale = MAX_SCALE - player.velocity:length() * SCALE_COEFFICIENT * (MAX_SCALE - MIN_SCALE)

    local target_scale = math.min(MAX_SCALE, math.max(target_scale, MIN_SCALE))

    local current_scale = self.game_scene.camera_scale
    self.game_scene.camera_scale = current_scale + (target_scale - current_scale) * ZOOMING_VELOCITY * dt
end

function GameplayOverlay:keypressed(key)
    PauseOverlay.keypressed(self, key)

    if key == "r" then
        self.game_scene:respawn_players()
    end
end

return GameplayOverlay