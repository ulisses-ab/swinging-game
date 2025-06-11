local starting_menu = require("gui.starting_menu")

local StartingMenu = {}
StartingMenu.__index = StartingMenu

function StartingMenu:new(push, pop)
    obj = Scene:new()

    return setmetatable(obj, StartingMenu)
end

return StartingMenu