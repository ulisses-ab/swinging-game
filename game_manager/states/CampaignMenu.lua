local gui = require("game_manager.gui.campaign_menu")
local GameplayState = require("GameplayState")

local CampaignMenu = Updater:new()
CampaignMenu.state_machine = nil

function CampaignMenu:init()
    local file_names = love.filesystem.getDirectoryItems("campaign_levels")

    local gui_scene = gui({
        exit = function()
            self.state_machine.pop()
        end,
        play = function(file)
            self:play_file(file)
        end,
    }, file_names)

    self:add(gui_scene)
end

function CampaignMenu:play_file(file)
    self.state_machine.push(GameplayState, persistance.load_scene("campaign_levels" .. file))
end

CampaignMenu:init()

return CampaignMenu