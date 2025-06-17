local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")
local gui = require("editor.gui.done_editing")

local DoneEditingOverlay = {}
DoneEditingOverlay.__index = DoneEditingOverlay
setmetatable(DoneEditingOverlay, Overlay)

function DoneEditingOverlay:new(wrapped, default_name, done)
    local obj = Overlay:new(wrapped)

    obj.active = false

    obj.gui = gui({
        quit = function()
            obj:deactivate()
        end,
        done = done,
    }, default_name)


    return setmetatable(obj, DoneEditingOverlay)
end

function DoneEditingOverlay:draw()
    self.wrapped:draw()

    if self.active then
        love.graphics.setColor(0, 0, 0, 0.95)
        util.draw_clear()
        love.graphics.setColor(1,1,1,1)
        self.gui:draw()
    end
end

function DoneEditingOverlay:activate()
    self.active = true

    self:reset_updatables()
    self:add_updatable(self.gui)
end

function DoneEditingOverlay:deactivate()
    self.active = false

    self:reset_updatables()
    self:add_updatable(self.wrapped)
end

return DoneEditingOverlay