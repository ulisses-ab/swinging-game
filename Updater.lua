local util = require("util")

local Updater = {}
Updater.__index = Updater

function Updater:new()
    local obj = {
        updatables = {},
        updates_active = true
    }

    return setmetatable(obj, Updater)
end

function Updater:add_updatable(updatable)
    table.insert(self.updatables, updatable)
end

function Updater:remove_updatable(updatable)
    util.remove_object_in_array(self.updatables, updatable)
end

function Updater:reset_updatables()
    self.updatables = {}
end

local function get_method_updater(method)
    return function(self, ...)
        if not self.updates_active then return end
        
        for _, updatable in ipairs(self.updatables) do
            if updatable[method] then
                updatable[method](updatable, ...)
            end
        end
    end
end

Updater.load = get_method_updater("load")
Updater.quit = get_method_updater("quit")
Updater.update = get_method_updater("update")
Updater.draw = get_method_updater("draw")
Updater.mousepressed = get_method_updater("mousepressed")
Updater.mousereleased = get_method_updater("mousereleased")
Updater.keypressed = get_method_updater("keypressed")
Updater.keyreleased = get_method_updater("keyreleased")
Updater.wheelmoved = get_method_updater("wheelmoved")
Updater.resize = get_method_updater("resize")
Updater.textinput = get_method_updater("textinput")

return Updater