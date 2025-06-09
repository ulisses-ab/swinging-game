local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local paused = require("game_manager.gui.paused")
local util = require("util")

local PauseOverlay = {}
PauseOverlay.__index = PauseOverlay

PauseOverlay.type = "PauseOverlay"

local countdown_font = love.graphics.newFont("assets/fonts/default.ttf", 100)

function PauseOverlay:new(scene, actions, paused_gui)
    local scene = scene or Scene:new()
    scene.camera_scale = 0.66666

    local obj = {
        COUNTDOWN_TIME = 3,
        game_scene = scene,
        paused = nil,
        actions = actions,
        paused_gui = paused_gui,
    }

    obj.countdown = obj.COUNTDOWN_TIME

    return setmetatable(obj, self)
end

function PauseOverlay:pause()
    self.paused = self.paused_gui:get_scene({
        continue = function()
            self.paused = nil
            self.countdown = self.COUNTDOWN_TIME
        end,
        restart = function()
            self.actions.restart()
        end,
        quit = function()
            self.actions.quit()
        end
    })
end

function PauseOverlay:is_paused()
    return self.paused or self.countdown > 0
end

function PauseOverlay:update(dt)
    if self.paused then
        self.paused:update(dt)
        return
    end

    self.countdown = self.countdown - dt / util.time_rate
    if self.countdown > 0 then
        return
    end

    self.game_scene:update(dt)
end

function PauseOverlay:draw()
    self.game_scene:draw()

    self:draw_pause()
end

function PauseOverlay:draw_pause()
    local sw, sh = util.get_dimensions()

    if self.paused then
        love.graphics.setColor(0, 0, 0, 0.95)
        love.graphics.rectangle("fill", -sw/2, -sh/2, sw, sh)
        love.graphics.setColor(1,1,1,1)
        self.paused:draw()
    elseif self.countdown > 0 then
        love.graphics.setColor(0, 0, 0, 0.2)
        love.graphics.rectangle("fill", -sw/2, -sh/2, sw, sh)
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

function PauseOverlay:keypressed(key)
    if key == "escape" then
        self:pause()
    end

    if self:is_paused() then
        if self.paused then self.paused:keypressed(key) end
        return 
    end

    self.game_scene:keypressed(key)
end

function PauseOverlay:keyreleased(key)
    if self:is_paused() then
        if self.paused then self.paused:keyreleased(key) end
        return 
    end

    self.game_scene:keyreleased(key)
end

function PauseOverlay:mousepressed(x, y, button, istouch, presses)
    if self:is_paused() then
        if self.paused then self.paused:mousepressed(x, y, button, istouch, presses) end
        return 
    end

    self.game_scene:mousepressed(x, y, button, istouch, presses)
end

function PauseOverlay:mousereleased(x, y, button, istouch, presses)
    if self:is_paused() then
        if self.paused then self.paused:mousereleased(x, y, button, istouch, presses) end
        return 
    end

    self.game_scene:mousereleased(x, y, button, istouch, presses)
end

return PauseOverlay