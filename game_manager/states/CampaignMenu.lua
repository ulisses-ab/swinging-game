local gui = require("game_manager.gui.campaign_menu")
local Scene = require("Scene")
local persistance = require("persistance")
local campaign_util = require("game_manager.campaign_util")

local CampaignMenu = Scene:new()
CampaignMenu.state_machine = nil

function CampaignMenu:init()

end   

function CampaignMenu:enter_state()
    self:remove_all()
    
    local gui_scene = gui({
        quit = function()
            self.state_machine:change("StartingMenu")
        end,
        play = function(number)
            self:play_number(number)
        end,
    }, #campaign_util:get_level_list(), campaign_util:get_all_best_times(), campaign_util:get_all_star_times())

    self:add(gui_scene)
end

function CampaignMenu:play_number(number)
    self.state_machine:change("CampaignGameplay", number)
end

CampaignMenu:init()

return CampaignMenu