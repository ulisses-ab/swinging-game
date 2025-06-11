local CampaignMenu = require("states.CampaignMenu")
local MyLevelsMenu = require("states.MyLevelsMenu")
local gui = require("game_manager.gui.starting_menu")

local StartingMenu = Updater:new()
StartingMenu.state_machine = nil

function StartingMenu:init()
    local gui_scene = gui({
        campaign = function()
            self.state_machine:push(CampaignMenu)
        end,
        my_levels = function()
            self.state_machine:push(MyLevelsMenu)
        end,
        exit = love.events.exit  
    })
    
    self:add(gui_scene)
end

StartingMenu:init()

return StartingMenu