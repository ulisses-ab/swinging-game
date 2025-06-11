local PauseOverlay = require("game_manager.overlays.PauseOverlay")
local editor_mode = require("editor.editor_mode")
local editor_gui = require("game_manager.gui.editor_gui")
local Platform = require("game_objects.Platform")
local Pivot = require("game_objects.Pivot")
local Slingshot = require("game_objects.Slingshot")
local Player = require("game_objects.Player")
local Enemy = require("game_objects.Enemy")
local Wall = require("game_objects.Wall")
local Vec2 = require("Vec2")
local util = require("util")
local paused = require("game_manager.gui.paused")
local GameplayOverlay = require("game_manager.overlays.GameplayOverlay")
local done_editing = require("game_manager.gui.done_editing")
local persistance = require("persistance")

local EditorOverlay = {}
EditorOverlay.__index = EditorOverlay
setmetatable(EditorOverlay, PauseOverlay)

function EditorOverlay:new(scene, actions)
    local obj = PauseOverlay:new(scene, actions, paused)

    obj.game_scene:add(Player:new(Vec2:new(0, 0)))
    obj.game_scene.frozen = true

    local function add_to_editor(obj)
        editor_mode:add_to_scene(obj)
        editor_mode:select_single(obj)
    end

    obj.gui = editor_gui:get_scene({
        platform = function()
            add_to_editor(Platform:new())
        end,
        pivot = function()
            add_to_editor(Pivot:new())
        end,
        slingshot = function()
            add_to_editor(Slingshot:new())
        end,
        wall = function()
            add_to_editor(Wall:new())
        end,
        enemy = function()
            add_to_editor(Enemy:new())
        end,
        play = function()
            obj:start_playtest()
        end,
        done = function()
            obj:editing_done()
        end
    })

    editor_mode:start_editing(obj.game_scene)

    obj.playtest_overlay = nil
    obj.done_overlay = nil

    return setmetatable(obj, EditorOverlay)
end

function EditorOverlay:start_playtest()
    self.game_scene.frozen = false

    local function stop_playtest()
        self.playtest_overlay = nil
        self.game_scene.frozen = true
        self.game_scene:respawn_players()
        self.game_scene.camera_translate = self.game_scene.obj_by_type["Player"][1].position:copy()
    end

    self.playtest_overlay = GameplayOverlay:new(self.game_scene, {finished = stop_playtest}, {get_scene = stop_playtest})

    self.playtest_overlay.ending_enabled = false
    self.playtest_overlay.COUNTDOWN_TIME = -1
    self.playtest_overlay.countdown = -1
end

function EditorOverlay:editing_done()
    self.done_overlay = done_editing:get_scene({
        done = function(name)
            self.game_scene.name = name
        
            local compressed_scene = persistance.save_in_dir(self.game_scene, "my_levels", name)

            self.actions.quit()
        end,
        quit = function()
            self.done_overlay = nil
        end
    })
end

function EditorOverlay:update(dt)
    if self.playtest_overlay ~= nil then
        self.playtest_overlay:update(dt)
        return
    end

    if self.done_overlay ~= nil then 
        self.done_overlay:update(dt)
        return
    end

    if self.paused then
        PauseOverlay.update(self, dt)
        return
    end

    editor_mode:update(dt)
    PauseOverlay.update(self, dt)
    self.gui:update(dt)
    self.countdown = -1
end

function EditorOverlay:draw()
    if self.playtest_overlay ~= nil then
        self.playtest_overlay:draw()
        return
    end

    self.game_scene:draw()
    self.gui:draw()
    self:draw_pause()
    editor_mode:draw()

    if self.done_overlay ~= nil then
        local sw, sh = util.get_dimensions()
        love.graphics.setColor(0, 0, 0, 0.95)
        love.graphics.rectangle("fill", -sw/2, -sh/2, sw, sh)
        love.graphics.setColor(1,1,1,1)
        self.done_overlay:draw()
    end
end

function EditorOverlay:keypressed(key)
    if self.playtest_overlay ~= nil then
        self.playtest_overlay:keypressed(key)
        return
    end

    if self.paused then
        PauseOverlay.keypressed(self, key)
        return
    end

    if self.done_overlay ~= nil then 
        self.done_overlay:keypressed(key)
        return
    end

    PauseOverlay.keypressed(self, key)
    editor_mode:keypressed(key)
    self.gui:keypressed(key)
end

function EditorOverlay:keyreleased(key)
    if self.playtest_overlay ~= nil then
        self.playtest_overlay:keyreleased(key)
        return
    end

    if self.paused then
        PauseOverlay.keyreleased(self, key)
        return
    end

    if self.done_overlay ~= nil then 
        self.done_overlay:keyreleased(key)
        return
    end

    PauseOverlay.keyreleased(self, key)
    editor_mode:keyreleased(key)
    self.gui:keyreleased(key)
end

function EditorOverlay:mousepressed(x, y, button)
    if self.playtest_overlay ~= nil then
        self.playtest_overlay:mousepressed(x, y, button)
        return
    end

    if self.paused then
        PauseOverlay.mousepressed(self, x, y, button)
        return
    end

    if self.done_overlay ~= nil then 
        self.done_overlay:mousepressed(x, y, button)
        return
    end

    PauseOverlay.mousepressed(self, x, y, button)
    editor_mode:mousepressed(x, y, button)
    self.gui:mousepressed(x, y, button)
end

function EditorOverlay:mousereleased(x, y, button)
    if self.playtest_overlay ~= nil then
        self.playtest_overlay:mousereleased(x, y, button)
        return
    end

    if self.paused then
        PauseOverlay.mousereleased(self, x, y, button)
        return
    end

    if self.done_overlay ~= nil then 
        self.done_overlay:mousereleased(x, y, button)
        return
    end

    PauseOverlay.mousereleased(self, x, y, button)
    editor_mode:mousereleased(x, y, button)
    self.gui:mousereleased(x, y, button)
end

function EditorOverlay:wheelmoved(x, y)
    if self.playtest_overlay ~= nil then
        return
    end

    if self.done_overlay ~= nil then 
        return
    end

    editor_mode:wheelmoved(x, y)
end

function EditorOverlay:textinput(t)
    if self.done_overlay ~= nil then 
        self.done_overlay:textinput(t)
        return
    end
end

return EditorOverlay


