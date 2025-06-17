local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")
local gui = require("Editor.gui.editing")
local Player = require("game_objects.Player")
local Pivot = require("game_objects.Pivot")
local Slingshot = require("game_objects.Slingshot")
local Platform = require("game_objects.Platform")
local Enemy = require("game_objects.Enemy")
local Wall = require("game_objects.Wall")

local GuiOverlay = {}
GuiOverlay.__index = GuiOverlay
setmetatable(GuiOverlay, Overlay)

function GuiOverlay:new(wrapped, base_scene, play, done)
    local obj = Overlay:new(wrapped)

    obj.base_scene = base_scene

    obj.gui = gui({
        add = function(obj_type)
            obj:add_to_base_scene(obj_type)
        end,
        play = play,
        done = done,
    })

    obj.gui.z = 1
    obj:add(obj.gui)

    return setmetatable(obj, GuiOverlay)
end

function GuiOverlay:add_to_base_scene(obj_type)
    local classes = {
        Enemy = Enemy,
        Wall = Wall,
        Slingshot = Slingshot,
        Platform = Platform,
        Pivot = Pivot
    }

    local class = classes[obj_type]

    if not class then return end

    self.base_scene:add(class:new(self.base_scene:get_absolute_translate():mul(-1):div(self.base_scene:get_absolute_scale())))
end


return GuiOverlay