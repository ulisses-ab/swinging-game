local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local editor_mode = require("editor.editor_mode")

local scale = 0.75

function love.load()
    util.input:set_scale(scale)

    scene = persistance.load_scene("scene.json")

    love.window.setMode(1280, 720, {resizable=false, vsync=true})

    editor_mode:start_editing(scene)
end

function love.quit()
    persistance.save_scene(scene, "scene.json")
end

function love.update(dt)
    dt = dt * 0.66
    editor_mode:update(dt)
    scene:update(dt)
end

function love.draw()
    love.graphics.scale(scale, scale)
    scene:draw()
    editor_mode:draw()
end

function love.keypressed(key)
    util.input:keypressed(key)
    editor_mode:keypressed(key)
    scene:keypressed(key)
end

function love.keyreleased(key)
    util.input:keyreleased(key)
    editor_mode:keyreleased(key)
    scene:keyreleased(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    util.input:mousepressed(x/scale, y/scale, button, istouch, presses)
    scene:mousepressed(x/scale, y/scale, button, istouch, presses)
    editor_mode:mousepressed(x/scale, y/scale, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    util.input:mousereleased(x/scale, y/scale, button, istouch, presses)
    scene:mousereleased(x/scale, y/scale, button, istouch, presses)
    editor_mode:mousereleased(x/scale, y/scale, button, istouch, presses)
end
 
