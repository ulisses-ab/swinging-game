local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local GameObject = require("game_objects.GameObject")
local sounds = require("sounds")

return function(actions, time, best_time)
    local scene = Scene:new()

    local time_display = TextBox:new(Vec2:new(0, -230), 1000, 200, util.format_time(time), nil, love.graphics.newFont("assets/fonts/default.ttf", 70))
    local done_button = Button:new(Vec2:new(280, 220), 400, 120, "Concluído", actions.quit, love.graphics.newFont("assets/fonts/default.ttf", 34))
    local restart_button = Button:new(Vec2:new(-100, 240), 220, 80, "Tentar novamente", actions.restart, love.graphics.newFont("assets/fonts/default.ttf", 18))

    local text = (not best_time or (best_time - time > -0.0002)) and "novo recorde!" or ("melhor tempo: " .. util.format_time(best_time))
    local best_time_display = TextBox:new(Vec2:new(0, -170), 1000, 200, text, nil, love.graphics.newFont("assets/fonts/default.ttf", 18))
    scene:add(best_time_display)

    scene:add(time_display)
    scene:add(done_button)
    scene:add(restart_button)

    return scene
end