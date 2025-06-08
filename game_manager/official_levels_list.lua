local Button = require("game_objects.Button")
local TextBox = require("game_objects.TextBox")
local Scene = require("Scene")
local Vec2 = require("Vec2")
local persistance = require("persistance")
local util = require("util")

local official_levels_list = {

}

function official_levels_list:get_scene(actions)
    local sw, sh = util.get_dimensions()

    local scene = Scene:new()

    if not love.filesystem.getInfo("official_levels") then
        love.filesystem.createDirectory("official_levels")
    end

    local items = love.filesystem.getDirectoryItems("official_levels")
    local y_start = -100
    local y_offset = 100
    for i, file in ipairs(items) do
        local button = Button:new(Vec2:new(0, y_start + (i-1) * y_offset), 50, 50, i, function()
            actions.play(love.filesystem.read("official_levels/" .. file))
        end)

        scene:add(button)
    end

    local quit_button = Button:new(Vec2:new(-350, -150), 60, 60, "←", actions.quit)
    scene:add(quit_button)

    return scene
end

return official_levels_list