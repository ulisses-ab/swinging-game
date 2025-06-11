local util = require("util")
local Vec2 = require("Vec2")
local Updater = require("Updater")

local Scene = {}
Scene.__index = Scene
setmetatable(Scene, Updater)

function Scene:new(name)
    local obj = Updater:new()

    obj.objects = {}
    obj.obj_by_type = setmetatable({}, {
        __index = function() return {} end
    })
    obj.name = name or "unnamed scene"
    obj.camera_scale = 1
    obj.camera_translate = Vec2:new(0, 0)
    obj.time_rate = 1
    obj.scene = nil

    return setmetatable(obj, Scene)
end

function Scene:add(object)
    self:add_updatable(object)

    object.scene = self

    table.insert(self.objects, object)

    if not object.type then return end

    if #self.obj_by_type[object.type] == 0 then
        self.obj_by_type[object.type] = {object}
        return
    end

    table.insert(self.obj_by_type[object.type], object)
end

function Scene:remove(object)
    self:remove_updatable(object)

    util.remove_obj_in_array(self.objects, object)

    if not object.type then return end

    util.remove_obj_in_array(self.obj_by_type[object.type], object)
end

function Scene:update(dt)
    dt = dt * self.time_rate
    Updater.update(self, dt)
end

function Scene:draw()
    love.graphics.push()
    love.graphics.scale(self.camera_scale, self.camera_scale)
    love.graphics.translate(self.camera_translate.x, self.camera_translate.y)

    table.sort(self.objects, function(a, b)
        return (a.z or 0) < (b.z or 0)
    end)

    for _, object in ipairs(self.objects) do
        if object.draw then
            object:draw()
        end
    end

    love.graphics.pop()
end

function Scene:translate_xy(x, y)
    x = x / self.camera_scale
    y = y / self.camera_scale
    x = x - self.camera_translate.x
    y = y - self.camera_translate.y

    return x, y
end

function Scene:get_mouse_position()
    local x, y
    if type(self.scene) == "table" then
        x, y = self.scene:get_mouse_position()
    else
        x, y = love.mouse.getPosition()
    end

    x = x - love.graphics.getWidth() / 2 
    y = y - love.graphics.getHeight() / 2
    return self:translate_xy(x, y)
end

function Scene:get_absolute_translate()
    if self.scene then
        return self.camera_translate:add(self.scene:get_absolute_translate()):mul(self:get_absolute_scale())
    end

    return self.camera_translate
end

function Scene:get_absolute_scale()
    if self.scene then
        return self.camera_scale * self.scene:get_absolute_scale()
    end

    return self.camera_scale
end

function Scene:mousepressed(x, y, ...)
    x, y = self:translate_xy(x, y)

    Updater.mousepressed(self, x, y, ...)
end

function Scene:mousereleased(x, y, ...)
    x, y = self:translate_xy(x, y)

    Updater.mousereleased(self, x, y, ...)
end

return Scene