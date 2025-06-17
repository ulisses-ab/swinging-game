local gui = require("game_manager.gui.starting_menu")
local Scene = require("Scene")
local CameraMovementOverlay = require("game_manager.overlays.CameraMovementOverlay")
local CountdownOverlay = require("game_manager.overlays.CountdownOverlay")
local EnemyDeathFxOverlay = require("game_manager.overlays.EnemyDeathFxOverlay")
local PauseOverlay = require("game_manager.overlays.PauseOverlay")
local TimerAndCounterOverlay = require("game_manager.overlays.TimerAndCounterOverlay")
local MyLevelsGameEndOverlay = require("game_manager.overlays.MyLevelsGameEndOverlay")
local persistance = require("persistance")
local my_levels_util = require("game_manager.my_levels_util")
local Player = require("game_objects.Player")

local MyLevelsGameplay = Scene:new()
MyLevelsGameplay.state_machine = nil

function MyLevelsGameplay:init()

end

function MyLevelsGameplay:enter_state(level_name)
    self:remove_all()

    local scene = my_levels_util:load_level(level_name)

    Player.allow_respawn = true

    scene.time_rate = 0.71
    local cam = CameraMovementOverlay:new(scene, scene)
    local tim = TimerAndCounterOverlay:new(cam, scene)
    local efx = EnemyDeathFxOverlay:new(tim, scene)
    local cnt = CountdownOverlay:new(efx)
    cnt:start_countdown(3)
    local pause = PauseOverlay:new(cnt, function()
        self.state_machine:change("MyLevelsMenu")
    end)
    local geo = MyLevelsGameEndOverlay:new(pause, tim, scene, pause, function()
        self.state_machine:change("MyLevelsMenu")
    end, function(time)
        my_levels_util:register_time(level_name, time)
    end, function()
        return my_levels_util:get_best_time(level_name)
    end)

    self:add(geo)
end

MyLevelsGameplay:init()

return MyLevelsGameplay