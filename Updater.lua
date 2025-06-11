local Updater = {}
Updater.__index = Updater

function Updater:new()
    local obj = {
        updatables = {},
        active = true
    }

    return setmetatable(obj, Updater)
end

function Updater:update(dt)
    if not self.active then return end

    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

function Updater:draw()
    if not self.active then return end

    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

function Updater:keypressed(key)  
    if not self.active then return end

    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

function Updater:keyreleased(key)
    if not self.active then return end

    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

function Updater:mousepressed(x, y, button, istouch, presses)
    if not self.active then return end

    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

function Updater:mousereleased(x, y, button, istouch, presses)
    if not self.active then return end

    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

function Updater:wheelmoved(x, y)
    if not self.active then return end

    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

function Updater:textinput(text)
    if not self.active then return end

    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

function Updater:resize(w, h)
    if not self.active then return end
    
    for _, updatable in ipairs(self.updatables) do
        if updatable.update then
            updatable:update(dt)
        end
    end
end

return Updater