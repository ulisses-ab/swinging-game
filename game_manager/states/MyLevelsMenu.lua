local Scene = require("Scene")
local Scene = require("Scene")
local gui = require("game_manager.gui.my_levels_menu")
local Player = require("game_objects.Player")
local ImportOverlay = require("game_manager.overlays.ImportOverlay")
local my_levels_util = require("game_manager.my_levels_util")
local persistance = require("persistance")

local MyLevelsMenu = Scene:new()
MyLevelsMenu.__index = MyLevelsMenu

function MyLevelsMenu:init()

end

function MyLevelsMenu:enter_state(scroll)
    self:remove_all()

    local file_names = love.filesystem.getDirectoryItems("my_levels")

    local import
    local gui_scene

    gui_scene = gui({
        quit = function()
            self.state_machine:change("StartingMenu")
        end,
        create = function()
            self:create_level()
        end,
        play = function(level_name)
            self.state_machine:change("MyLevelsGameplay", level_name)
        end,
        import = function()
            import:activate()
        end,
        edit = function(level_name)
            self.state_machine:change("Editor", persistance.load_scene("my_levels/".. level_name), level_name)
        end,
        delete = function(level_name)
            my_levels_util:delete_level(level_name)
            local scroll = gui_scene:get_scroll()
            self.state_machine:change("MyLevelsMenu", scroll)
        end,
    }, file_names, scroll)

    import = ImportOverlay:new(gui_scene, function(str)
        local success, result = pcall(function() 
            my_levels_util:save_string(str)
        end)

        if not success then
            import:alert()
        else 
            import:deactivate()
            local scroll = gui_scene:get_scroll()
            self.state_machine:change("MyLevelsMenu", scroll)
        end
    end)

    self:add(import)
end

function MyLevelsMenu:create_level()
    self.state_machine:change("Editor")
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