local Updater = {}
Updater.__index = Updater

setmetatable(Updater, { __index = function(t, key)
    return function(self, ...)
        if not self.updaselfes_active then return end

        for _, updatable in ipairs(self.updatables) do
            if updatable[key] then
                updatable[key](updatable, ...)
            end
        end
    end
end})

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

return Updater