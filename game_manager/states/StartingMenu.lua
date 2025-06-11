local gui = require("game_manager.gui.starting_menu")
local Scene = require("Scene")

local StartingMenu = Scene:new()
StartingMenu.state_machine = nil

function StartingMenu:init()
    local gui_scene = gui({
        campaign = function()
            self.state_machine:change("CampaignMenu")
        end,
        my_levels = function()
            self.state_machine:change("MyLevelsMenu")
        end,
        quit = love.event.quit  
    })

    self:add(gui_scene)
end

StartingMenu:init()

return StartingMenu