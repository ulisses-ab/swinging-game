local Scene = require("Scene")
local util = require("util")
local CameraMovementOverlay = require("editor.overlays.CameraMovementOverlay")
local SelectionOverlay = require("editor.overlays.SelectionOverlay")
local DraggingOverlay = require("editor.overlays.DraggingOverlay")
local GuiOverlay = require("editor.overlays.GuiOverlay")
local SlidersOverlay = require("editor.overlays.SlidersOverlay")
local DoneEditingOverlay = require("editor.overlays.DoneEditingOverlay")
local PauseOverlay = require("game_manager.overlays.PauseOverlay")
local Player = require("game_objects.Player")
local GameScene = require("GameScene")
local Vec2 = require("Vec2")
local my_levels_util = require("game_manager.my_levels_util")

local Editor = Scene:new()
Editor.state_machine = nil

function Editor:init()

end

function Editor:enter_state(scene, name)
    self:remove_all()

    if not scene then
        scene = GameScene:new()
        scene:add(Player:new(Vec2:new(0, 0)))
    end

    self:clear_non_persistent_objects(scene)

    scene:get_player():respawn()
    scene.updates_active = false

    local slider = SlidersOverlay:new(scene)
    local drag = DraggingOverlay:new(slider, scene)
    local sel = SelectionOverlay:new(drag, scene, drag, slider)
    local cmo = CameraMovementOverlay:new(sel)

    local done
    local gui = GuiOverlay:new(cmo, scene, function()
        self.state_machine:change("Playtest", scene)
    end, function()
        if #scene.obj_by_type["Enemy"] == 0 then return end
        done:activate()
    end)
    local pause = PauseOverlay:new(gui, function()
        self.state_machine:change("MyLevelsMenu")
    end, nil, "Deseja sair sem salvar?")
    done = DoneEditingOverlay:new(pause, name, function(chosen_name, substitute)
        my_levels_util:save_scene(scene, chosen_name, substitute)

        self.state_machine:change("MyLevelsMenu")
    end)

    self:add(done)
end

function Editor:clear_non_persistent_objects(scene)
    local non_persistent = {}

    for _, obj in ipairs(scene.objects) do
        if not obj.persistance_object then
            table.insert(non_persistent, obj)
        end
    end

    for _, obj in ipairs(non_persistent) do
        scene:remove(obj)
    end
end

Editor:init()

return Editor