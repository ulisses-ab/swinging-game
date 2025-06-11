local gui = require("game_manager.gui.starting_menu")
local Scene = require("Scene")
local CameraMovementOverlay = require("game_manager.overlays.CameraMovementOverlay")
local CountdownOverlay = require("game_manager.overlays.CountdownOverlay")
local EnemyDeathFxOverlay = require("game_manager.overlays.EnemyDeathFxOverlay")
local PauseOverlay = require("game_manager.overlays.PauseOverlay")
local TimerAndCounterOverlay = require("game_manager.overlays.TimerAndCounterOverlay")

local Gameplay = Scene:new()
Gameplay.state_machine = nil

function Gameplay:init()

end

function Gameplay:enter_state(scene)
    self:remove_all()

    scene.time_rate = 0.71
    local cam = CameraMovementOverlay:new(scene, scene)
    local tim = TimerAndCounterOverlay:new(cam, scene)
    local efx = EnemyDeathFxOverlay:new(tim, scene)
    local cnt = CountdownOverlay:new(efx)
    cnt:start_countdown(3)
    local pause = PauseOverlay:new(cnt, function()
        self.state_machine:change("CampaignMenu")
    end)

    self:add(pause)
end

Gameplay:init()

return Gameplay