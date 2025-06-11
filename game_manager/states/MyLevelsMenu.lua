local Scene = require("Scene")
local Scene = require("Scene")
local gui = require("game_manager.gui.my_levels_menu")
local Player = require("game_objects.Player")

local MyLevelsMenu = Scene:new()
MyLevelsMenu.__index = MyLevelsMenu

function MyLevelsMenu:init()
    local file_names = love.filesystem.getDirectoryItems("my_levels")

    local gui_scene = gui({
        quit = function()
            self.state_machine:change("StartingMenu")
        end,
        create = function()
            self:create_level()
        end,

    }, file_names)

    self:add(gui_scene)
end

function MyLevelsMenu:create_level()
    local scene = Scene:new()
    scene:add(Player:new())

    self.state_machine:change("Editor", scene)
end

function MyLevelsMenu:edit_level(file)
    local scene = persistance.load_scene("my_levels/" .. file)

    self.state_machine:change("Editor", scene)
end

function MyLevelsMenu:play_level(file)
    local scene = persistance.load_scene("my_levels/" .. file)

    self.state_machine:change("Gameplay", scene)
end

MyLevelsMenu:init()

return MyLevelsMenu