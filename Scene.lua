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
    obj.type = "Scene"

    return setmetatable(obj, Scene)
end

function Scene:add(object)
    self:add_updatable(object)

    object.scene = self

    table.insert(self.objects, object)
    table.sort(self.objects, function(a, b)
        return (a.z or 0) < (b.z or 0)
    end)

    if not object.type then return end

    if #self.obj_by_type[object.type] == 0 then
        self.obj_by_type[object.type] = {object}
        return
    end

    table.insert(self.obj_by_type[object.type], object)

    if object.on_add_to_scene then
        object:on_add_to_scene(self)
    end
end

function Scene:remove_all()
    for _, obj in ipairs(self.objects) do
        self:remove(obj)
    end
end

function Scene:remove(object)
    self:remove_updatable(object)

    util.remove_obj_in_array(self.objects, object)
    table.sort(self.objects, function(a, b)
        return (a.z or 0) < (b.z or 0)
    end)

    if not object.type then return end

    util.remove_obj_in_array(self.obj_by_type[object.type], object)

    if object.on_remove_from_scene then
        object:on_remove_from_scene(self)
    end
end

function Scene:update(dt)
    dt = dt * self.time_rate
    Updater.update(self, dt)
end

function Scene:draw()
    love.graphics.push()
    love.graphics.translate(self.camera_translate.x, self.camera_translate.y)
    love.graphics.scale(self.camera_scale, self.camera_scale)

    for _, object in ipairs(self.objects) do
        if object.draw then
            object:draw()
        end
    end

    love.graphics.pop()
end

function Scene:translate_xy(x, y)
    x = x - self.camera_translate.x
    y = y - self.camera_translate.y
    x = x / self.camera_scale
    y = y / self.camera_scale

    return x, y
end

function Scene:get_mouse_position()
    local x, y

    if type(self.scene) == "table" then
        x, y = self.scene:get_mouse_position()
    else
        x, y = love.mouse.getPosition()
        x = x - love.graphics.getWidth()/2
        y = y - love.graphics.getHeight()/2
    end

    x, y = self:translate_xy(x, y)
    return x, y
end

function Scene:get_absolute_translate()
    if self.scene then
        return self.scene:get_absolute_translate():add(self.camera_translate:mul(self.scene:get_absolute_scale()))
    end

    return self.camera_translate:copy()
end

function Scene:get_absolute_scale()
    if self.scene then
        return self.camera_scale * self.scene:get_absolute_scale()
    end

    return self.camera_scale
end

function Scene:mousepressed(...)
    if not self.updates_active then return end

    x, y = self:get_mouse_position()

    table.sort(self.updatables, function(a, b)
        return (a.z or 0) > (b.z or 0)
    end)

    for _, object in ipairs(self.updatables) do
        if object.mousepressed and object:mousepressed(x, y, ...) then
            return true
        end
    end
end

function Scene:mousereleased(...)
    x, y = self:get_mouse_position()

    Updater.mousereleased(self, x, y, ...)
end

return Scene