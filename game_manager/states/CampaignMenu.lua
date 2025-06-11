local gui = require("game_manager.gui.campaign_menu")
local Scene = require("Scene")
local persistance = require("persistance")

local CampaignMenu = Scene:new()
CampaignMenu.state_machine = nil

function CampaignMenu:init()
    local file_names = love.filesystem.getDirectoryItems("campaign_levels")

    local gui_scene = gui({
        quit = function()
            self.state_machine:change("StartingMenu")
        end,
        play = function(file)
            self:play_file(file)
        end,
    }, file_names)

    self:add(gui_scene)
end

function CampaignMenu:play_file(file)
    self.state_machine:change("Gameplay", persistance.load_scene("campaign_levels/" .. file))
end

CampaignMenu:init()

return CampaignMenu