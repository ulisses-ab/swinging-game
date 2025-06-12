local util = require("util")
local sounds = require("sounds")
local Vec2 = require("Vec2")
local StateMachine = require("game_manager.StateMachine")
local StartingMenu = require("game_manager.states.StartingMenu")
local CampaignMenu = require("game_manager.states.CampaignMenu")
local MyLevelsMenu = require("game_manager.states.MyLevelsMenu")
local CampaignGameplay = require("game_manager.states.CampaignGameplay")
local Scene = require("Scene")

global_line_width = 2

local game_manager = StateMachine:new()
game_manager:register("StartingMenu", StartingMenu)
game_manager:register("CampaignMenu", CampaignMenu)
game_manager:register("MyLevelsMenu", MyLevelsMenu)
game_manager:register("CampaignGameplay", CampaignGameplay)
game_manager:change("StartingMenu")

local scene = Scene:new()
scene:add(game_manager)

local function toggle_fullscreen()
    love.window.setFullscreen(not love.window.getFullscreen())
    canvas = love.graphics.newCanvas()
end

function love.load()
    love.window.setMode(1280, 720, {resizable=true, vsync=true})
    toggle_fullscreen()

    canvas = love.graphics.newCanvas()
    shader = love.graphics.newShader("assets/shaders/crt.glsl")

    sounds.SR20DET:setLooping(true)
    sounds.SR20DET:play()

    scene:load()
end

function love.quit()
    scene:quit()
end

function love.update(dt)
    util.set_default_cursor()

    scene:update(dt)

    shader:send("time", love.timer.getTime() / 2)
    shader:send("resolution", {love.graphics.getWidth(), love.graphics.getHeight()})
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.push()
    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(global_line_width)
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    scene:draw()
    love.graphics.pop()

    love.graphics.setCanvas()

    shader:send("tex0", canvas)
    love.graphics.setShader(shader)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end

function love.keypressed(key)  
    if 
        key == "f11"  or
        (key == "lalt" and util.input:is_down("return")) or
        (key == "return" and util.input:is_down("lalt"))
    then
        toggle_fullscreen()
    end
    
    util.input:keypressed(key)
    scene:keypressed(key)
end

function love.keyreleased(key)
    util.input:keyreleased(key)
    scene:keyreleased(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    x = x - love.graphics.getWidth() / 2 
    y = y - love.graphics.getHeight() / 2
    util.input:mousepressed(x/util.scale, y/util.scale, button, istouch, presses)
    scene:mousepressed(x/util.scale, y/util.scale, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    x = x - love.graphics.getWidth() / 2 
    y = y - love.graphics.getHeight() / 2
    util.input:mousereleased(x/util.scale, y/util.scale, button, istouch, presses)
    scene:mousereleased(x/util.scale, y/util.scale, button, istouch, presses)
end

function love.wheelmoved(x, y)
    scene:wheelmoved(x, y)
end

function love.textinput(text)
    scene:textinput(text)
end

function love.resize(w, h)
    canvas = love.graphics.newCanvas()
    scene:resize(w, h)
end

