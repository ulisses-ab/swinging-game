local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local paused = require("game_manager.gui.paused")
local util = require("util")
local PauseOverlay = require("game_manager.overlays.PauseOverlay")

local GameplayOverlay = {}
GameplayOverlay.__index = GameplayOverlay
setmetatable(GameplayOverlay, PauseOverlay)

local timer_font = love.graphics.newFont("assets/fonts/default.ttf", 30)

function GameplayOverlay:new(scene, actions, paused_gui)
    local obj = PauseOverlay:new(scene, actions, paused_gui or paused)

    obj.game_timer = 0
    obj.show_timer = true
    obj.ending_timer = 0
    obj.ENDING_DURATION = 3.6
    obj.FADEOUT_START = 1.5
    obj.FADEOUT_END = 3
    obj.alpha = 1
    obj.ending_enabled = true

    return setmetatable(obj, self)
end

function GameplayOverlay:update(dt)
    if self.game_scene:count_live_enemies() == 0 then
        if self.ending_enabled then
            self.ending_timer = self.ending_timer + dt / util.time_rate

            local fade_time = math.min(1, math.max(0, (self.ending_timer - self.FADEOUT_START) / (self.FADEOUT_END - self.FADEOUT_START)))
            self.alpha = 1 - fade_time

            if self.ending_timer > self.ENDING_DURATION then
                util.camera_shake.x = 0
                util.camera_shake.y = 0
                self.actions.finished()
            end
        end
    else
        self.alpha = 1
        self.ending_timer = 0

        if not self:is_paused() then
            util.camera_shake.x = 0
            util.camera_shake.y = 0
            self.game_timer = self.game_timer + dt / util.time_rate * util.timer_time_rate
        end
    end

    PauseOverlay.update(self, dt)

    self:move_camera_if_player_out_of_bounds(dt)
    self:zoom_based_on_velocity(dt)
end

local canvas = love.graphics.newCanvas()

function GameplayOverlay:draw()
    local sw, sh = love.graphics.getDimensions()
    local prev = love.graphics.getCanvas()

    if canvas:getWidth() ~= sw or canvas:getHeight() ~= sh then
        canvas = love.graphics.newCanvas()
    end

    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    self.game_scene:draw()

    if self.show_timer then
        love.graphics.setFont(timer_font)
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

function GameplayOverlay:keypressed(key)
    if key == "r" then
        self.game_timer = 0
        self.game_scene:respawn_players()
    end
end

return GameplayOverlay