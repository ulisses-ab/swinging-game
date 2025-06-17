local gui = require("game_manager.gui.starting_menu")
local Scene = require("Scene")
local CameraMovementOverlay = require("game_manager.overlays.CameraMovementOverlay")
local CountdownOverlay = require("game_manager.overlays.CountdownOverlay")
local EnemyDeathFxOverlay = require("game_manager.overlays.EnemyDeathFxOverlay")
local PauseOverlay = require("game_manager.overlays.PauseOverlay")
local TimerAndCounterOverlay = require("game_manager.overlays.TimerAndCounterOverlay")
local GameEndOverlay = require("game_manager.overlays.GameEndOverlay")
local Overlay = require("game_manager.overlays.Overlay")
local persistance = require("persistance")
local campaign_util = require("game_manager.campaign_util")
local Player = require("game_objects.Player")

local Playtest = Scene:new()
Playtest.state_machine = nil

function Playtest:init()

end

function Playtest:enter_state(scene)
    self:remove_all()

    Player.allow_respawn = true
    scene.time_rate = 0.71
    scene.updates_active = true
    
    local cam = CameraMovementOverlay:new(scene, scene)
    local tim = TimerAndCounterOverlay:new(cam, scene)
    local efx = EnemyDeathFxOverlay:new(tim, scene)
    local quit = Overlay:new(efx)

    quit.keypressed = function(_, key)
        if key == "escape" then
            self.state_machine:change("Editor", scene)
        end

        Overlay.keypressed(_, key)
    end

    self:add(quit)
end

Playtest:init()

return Playtest