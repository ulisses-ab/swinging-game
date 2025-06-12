local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local GameObject = require("game_objects.GameObject")

return function(actions, number, best_times, star_times)
    local function make_star(x, y, star_time, best_time)
        local star = GameObject:new(Vec2:new(x, y))

        if best_time then 
            star.is_yellow = best_time <= star_time
        else
            star.is_yellow = false
        end

        star.draw = function(self)
            love.graphics.setBlendMode("add")
            local c = self.is_yellow and {r = 0.82, g = 0.70, b = 0.0, a = 1} or {r = 0.7, g = 0.7, b = 0.7, a = 0.5}
            love.graphics.setColor(c.r, c.g, c.b, c.a or 1)
            util.draw_star("fill", self.position.x, self.position.y, 25)
            love.graphics.setColor(1,1,1,1)
            love.graphics.setBlendMode("alpha")
        end

        return star
    end

    local scene = Scene:new()

    local y_start = -170
    local y_offset = 120
    for i = 1, number do
        local y = y_start + (i-1) * y_offset

        local button = Button:new(Vec2:new(-100, y), 70, 70, i, function()
            actions.play(i)
        end, love.graphics.newFont("assets/fonts/default.ttf", 32))

        button.enabled = i == 1 or best_times[i-1] ~= nil
        if not button.enabled then
            button.config.color = {r=1,g=1,b=1,a=0.5}
        end

        scene:add(button)

        if best_times[i] then
            local time_box = TextBox:new(Vec2:new(250, y), 200, 50, util.format_time(best_times[i]), 
            {align = "left"}, love.graphics.newFont("assets/fonts/default.ttf", 30))

            scene:add(time_box)

            local st = star_times[i] or {0, 0, 0}
            local star1 = make_star(-10, y, st[1], best_times[i])
            local star2 = make_star(40, y, st[2], best_times[i])
            local star3 = make_star(90, y, st[3], best_times[i])

            scene:add(star1)
            scene:add(star2)
            scene:add(star3)
        end
    end
    scene.camera_translate.x = -40
    scene.camera_scale = 0.9

    scene.wheelmoved = function(self, x, y)
        local min_translate = math.min(0, -(number-1) * y_offset + 400)
        self.camera_translate.y = math.min(0, math.max(self.camera_translate.y + y * 40, min_translate))
    end

    local outer_scene = Scene:new()
    outer_scene:add(scene)

    local exit_button = Button:new(Vec2:new(-400, -150), 60, 60, "←", actions.quit)
    outer_scene:add(exit_button)

    return outer_scene
end
