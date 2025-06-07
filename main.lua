local Scene = require("Scene")
local util = require("util")
local Button = require("game_objects.Button")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local editor_mode = require("editor.editor_mode")
local game_manager = require("manager.game_manager")
local sounds = require("sounds")

util.scale = 0.75
util.time_rate = 0.66

function love.load()
    love.window.setMode(1280, 720, {resizable=false, vsync=true})


    canvas = love.graphics.newCanvas()
    shader = love.graphics.newShader("assets/shaders/crt.glsl")

    local sound = sounds.SR20DET
    sound:play()

    game_manager:load()
end

function love.quit()
    game_manager:quit()
end

function love.update(dt)
    util.set_default_cursor()

    dt = dt * util.time_rate
    game_manager:update(dt)

    shader:send("time", love.timer.getTime() / 2)
    shader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.push()
    love.graphics.setColor(1,1,1)
    love.graphics.scale(util.scale, util.scale)
    game_manager:draw()
    love.graphics.pop()

    love.graphics.setCanvas()

    -- Apply shader to the whole scene
    shader:send("tex0", canvas) -- so tex0 has real content
    love.graphics.setShader(shader)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end

function love.keypressed(key)
    util.input:keypressed(key)
    game_manager:keypressed(key)
end

function love.keyreleased(key)
    util.input:keyreleased(key)
    game_manager:keyreleased(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    util.input:mousepressed(x/util.scale, y/util.scale, button, istouch, presses)
    game_manager:mousepressed(x/util.scale, y/util.scale, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    util.input:mousereleased(x/util.scale, y/util.scale, button, istouch, presses)
    game_manager:mousereleased(x/util.scale, y/util.scale, button, istouch, presses)
end
 
