local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local paused = require("game_manager.paused")
local util = require("util")

local GameplayOverlay = {}
GameplayOverlay.__index = GameplayOverlay

GameplayOverlay.type = "GameplayOverlay"

local countdown_font = love.graphics.newFont("assets/fonts/default.ttf", 100)

function GameplayOverlay:new(scene_data, actions)
    local scene = scene_data and persistance.scene_from_string(scene_data) or Scene:new()
    scene.camera_scale = 0.66666

    local obj = {
        game_scene = scene,
        countdown = 3,
        paused = nil,
        actions = actions,
    }

    return setmetatable(obj, self)
end

function GameplayOverlay:pause()
    self.paused = paused:get_scene({
        continue = function()
            self.paused = nil
            self.countdown = 3
        end,
        restart = function()
            self.actions.restart()
        end,
        quit = function()
            self.actions.quit()
        end
    })
end

function GameplayOverlay:is_paused()
    return self.paused or self.countdown > 0
end

function GameplayOverlay:update(dt)
    if self.paused then
        self.paused:update(dt)
        return
    end

    self.countdown = self.countdown - dt / util.time_rate
    if self.countdown > 0 then
        return
    end

    self.game_scene:update(dt)
    self:move_camera_if_player_out_of_bounds(dt)
end

function GameplayOverlay:move_camera_if_player_out_of_bounds(dt)
    local player = self.game_scene.players[1]
    if not player then return end

    local absolute_player_pos = player.position:add(self.game_scene.camera_translate):mul(self.game_scene.camera_scale)

    local CORRECTION_SPEED = 8

    local x_limit = 150
    local x_correct = math.max(0, math.abs(absolute_player_pos.x) - x_limit) * util.sign(absolute_player_pos.x) * dt * CORRECTION_SPEED

    local y_limit = 100
    local y_correct = math.max(0, math.abs(absolute_player_pos.y) - y_limit) * util.sign(absolute_player_pos.y) * dt * CORRECTION_SPEED

    self.game_scene.camera_translate = self.game_scene.camera_translate:sub(Vec2:new(x_correct, y_correct))
end

function GameplayOverlay:draw()
    local sw, sh = util.get_dimensions()

    self.game_scene:draw()

    if self.paused then
        love.graphics.setColor(0, 0, 0, 0.95)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
        love.graphics.setColor(1,1,1,1)
        self.paused:draw()
    elseif self.countdown > 0 then
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", 0, 0, sw, sh)
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(countdown_font)
        love.graphics.printf(
            math.floor(self.countdown)+1,
            -50,
            -50,
            100,
            "center"
        )
    end
end

function GameplayOverlay:keypressed(key)
    if key == "escape" then
        self:pause()
    end

    if self:is_paused() then
        if self.paused then self.paused:keypressed(key) end
        return 
    end

    self.game_scene:keypressed(key)
end

function GameplayOverlay:keyreleased(key)
    if self:is_paused() then
        if self.paused then self.paused:keyreleased(key) end
        return 
    end

    self.game_scene:keyreleased(key)
end

function GameplayOverlay:mousepressed(x, y, button, istouch, presses)
    if self:is_paused() then
        if self.paused then self.paused:mousepressed(x, y, button, istouch, presses) end
        return 
    end

    self.game_scene:mousepressed(x, y, button, istouch, presses)
end

function GameplayOverlay:mousereleased(x, y, button, istouch, presses)
    if self:is_paused() then
        if self.paused then self.paused:mousereleased(x, y, button, istouch, presses) end
        return 
    end

    self.game_scene:mousereleased(x, y, button, istouch, presses)
end

return GameplayOverlay