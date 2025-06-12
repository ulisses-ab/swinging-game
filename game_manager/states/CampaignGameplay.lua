local gui = require("game_manager.gui.starting_menu")
local Scene = require("Scene")
local CameraMovementOverlay = require("game_manager.overlays.CameraMovementOverlay")
local CountdownOverlay = require("game_manager.overlays.CountdownOverlay")
local EnemyDeathFxOverlay = require("game_manager.overlays.EnemyDeathFxOverlay")
local PauseOverlay = require("game_manager.overlays.PauseOverlay")
local TimerAndCounterOverlay = require("game_manager.overlays.TimerAndCounterOverlay")
local CampaignGameEndOverlay = require("game_manager.overlays.CampaignGameEndOverlay")
local persistance = require("persistance")
local campaign_util = require("game_manager.campaign_util")

local CampaignGameplay = Scene:new()
CampaignGameplay.state_machine = nil

function CampaignGameplay:init()

end

function CampaignGameplay:enter_state(number)
    if number > #campaign_util:get_level_list() then
        self.state_machine:change("CampaignMenu")
        return
    end

    self:remove_all()

    local scene = campaign_util:load_level(number)

    scene.time_rate = 0.71
    local cam = CameraMovementOverlay:new(scene, scene)
    local tim = TimerAndCounterOverlay:new(cam, scene)
    local efx = EnemyDeathFxOverlay:new(tim, scene)
    local cnt = CountdownOverlay:new(efx)
    cnt:start_countdown(3)
    local pause = PauseOverlay:new(cnt, function()
        self.state_machine:change("CampaignMenu")
    end)
    local geo = CampaignGameEndOverlay:new(pause, tim, scene, pause, function()
        self.state_machine:change("CampaignMenu")
    end, function()
        self.state_machine:change("CampaignGameplay", number + 1)
    end, campaign_util:get_star_times(number), function(time)
        campaign_util:register_time(number, time)
    end)

    self:add(geo)
end

CampaignGameplay:init()

return CampaignGameplay