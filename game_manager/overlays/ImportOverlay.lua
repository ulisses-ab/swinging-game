local Overlay = require("game_manager.overlays.Overlay")
local Scene = require("Scene")
local util = require("util")
local Vec2 = require("Vec2")
local gui = require("game_manager.gui.import")

local ImportOverlay = {}
ImportOverlay.__index = ImportOverlay
setmetatable(ImportOverlay, Overlay)

function ImportOverlay:new(wrapped, done)
    local obj = Overlay:new(wrapped)

    obj.gui = gui({
        quit = function()
            obj:deactivate()
        end,
        done = done
    })

    return setmetatable(obj, ImportOverlay)
end

function ImportOverlay:draw()
    self.wrapped:draw()

    if self.active then
        love.graphics.setColor(0,0,0,0.95)
        util.draw_clear()
        love.graphics.setColor(1,1,1,1)
        self.gui:draw()
    end
end

function ImportOverlay:activate()
    self.active = true

    self:reset_updatables()
    self:add_updatable(self.gui)
end

function ImportOverlay:deactivate()
    self.active = false

    self:reset_updatables()
    self:add_updatable(self.wrapped)
end

function ImportOverlay:alert()
    self.gui:alert()
end


return ImportOverlay