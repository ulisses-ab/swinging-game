local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")

return function(actions, file_names)
    local scene = Scene:new()

    local y_start = -100
    local y_offset = 100
    for _, file_name in ipairs(file_names) do
        local button = Button:new(Vec2:new(0, y_start + (i-1) * y_offset), 50, 50, file_name, function()
            actions.play(file_name)
        end)

        scene:add(button)
    end

    local exit_button = Button:new(Vec2:new(-350, -150), 60, 60, "←", actions.exit)
    scene:add(exit_button)

    return scene
end
