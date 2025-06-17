local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local util = require("util")
local GameObject = require("game_objects.GameObject")
local sounds = require("sounds")

return function(actions, time, star_times, best_time)
    local timer = 0

    local function make_star(x, y, delay, time_limit, i)
        local star = GameObject:new(Vec2:new(x, y))

        star.is_yellow = false
        star.has_turned_yellow = false
        star.yellow = {r = 0.82, g = 0.70, b = 0.0, a = 1}
        star.gray = {r = 0.7, g = 0.7, b = 0.7, a = 0.5}

        star.draw = function(self)
            love.graphics.setBlendMode("add")
            local c = self.is_yellow and self.yellow or self.gray
            love.graphics.setColor(c.r, c.g, c.b, c.a or 1)
            util.draw_star("fill", self.position.x, self.position.y, 50)
            love.graphics.setColor(1,1,1,1)
            love.graphics.setBlendMode("alpha")
        end

        star.update = function(self, dt)
            GameObject.update(self, dt)

            if timer > delay and not self.has_turned_yellow then
                self.has_turned_yellow = true

                if time <= time_limit then
                    self.is_yellow = true
                    sounds.star_caught:setPitch(0.85 + (i-1)*0.2)
                    sounds.star_caught:play()
                else
                    --sounds.star_not_caught:play()
                end
            end
        end 

        local star_text = TextBox:new(Vec2:new(x, y + 65), 1000, 200, util.format_time(time_limit, true), nil, love.graphics.newFont("assets/fonts/default.ttf", 18))
        star_text.draw = function(self)
            if star.is_yellow then
                self.config.color = star.yellow
            else
                self.config.color = star.gray
            end
            love.graphics.setBlendMode("add")
            TextBox.draw(self)
            love.graphics.setBlendMode("alpha")
        end

        return star, star_text
    end

    local scene = Scene:new()

    scene.update = function(self, dt)
        Scene.update(self, dt)

        timer = timer + dt
    end

    local time_display = TextBox:new(Vec2:new(0, -230), 1000, 200, util.format_time(time), nil, love.graphics.newFont("assets/fonts/default.ttf", 70))
    local next_button = Button:new(Vec2:new(280, 220), 400, 120, "Próximo", actions.next, love.graphics.newFont("assets/fonts/default.ttf", 34))
    local restart_button = Button:new(Vec2:new(-100, 240), 220, 80, "Tentar novamente", actions.restart, love.graphics.newFont("assets/fonts/default.ttf", 18))
    local quit_button = Button:new(Vec2:new(-360, 240), 220, 80, "Voltar ao menu", actions.quit, love.graphics.newFont("assets/fonts/default.ttf", 18))

    scene:add(time_display)
    scene:add(next_button)
    scene:add(restart_button)
    scene:add(quit_button)

    local STAR_SPACING = 120
    local STAR_SHOW_DELAY = 0.4
    local START_SHOWING_STARS_DELAY = 0.4

    local star1, star1_text = make_star(-STAR_SPACING, -50, START_SHOWING_STARS_DELAY, star_times[1], 1)
    local star2, star2_text = make_star(0, -50, START_SHOWING_STARS_DELAY + STAR_SHOW_DELAY, star_times[2], 2)
    local star3, star3_text = make_star(STAR_SPACING, -50, START_SHOWING_STARS_DELAY + 2*STAR_SHOW_DELAY, star_times[3], 3)

    scene:add(star1)
    scene:add(star1_text)
    scene:add(star2)
    scene:add(star2_text)
    scene:add(star3)
    scene:add(star3_text)

    local text = (not best_time or (best_time - time > -0.0002)) and "novo recorde!" or ("melhor tempo: " .. util.format_time(best_time))
    local best_time_display = TextBox:new(Vec2:new(0, -170), 1000, 200, text, nil, love.graphics.newFont("assets/fonts/default.ttf", 18))
    scene:add(best_time_display)

    return scene
end