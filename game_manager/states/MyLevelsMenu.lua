local Scene = require("Scene")
local Editor = require("game_manager.states.Editor")
local gui = require("game_manager.gui.my_levels_menu")

local MyLevelsMenu = {}
MyLevelsMenu.__index = MyLevelsMenu

function MyLevelsMenu:init()
    local file_names = love.filesystem.getDirectoryItems("my_levels")

    local gui_scene = gui({
        exit = function()
            self.state_machine:pop()
        end,
        create = function()
            self:create_level()
        end,

    }, file_name)

    self:add(gui_scene)
end

function MyLevelsMenu:create_level()
    local scene = Scene:new()
    scene:add(Player:new())

    self.state_machine:push(Editor, scene)
end

function MyLevelsMenu:edit_level(file)
    local scene = persistance.load_scene("my_levels/" .. file)

    self.state_machine:push(Editor, scene)
end

function MyLevelsMenu:play_level(file)
    local scene = persistance.load_scene("my_levels/" .. file)

    self.state_machine:push(Gameplay, scene)
end

MyLevelsMenu:init()

return MyLevelsMenu