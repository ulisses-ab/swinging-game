local util = require("util")
local Bullet = require("game_objects.Bullet")
local Vec2 = require("Vec2")

local Scene = {}
Scene.__index = Scene

function Scene:new(name)
    local obj = {
        objects = {},
        obj_by_type = setmetatable({}, {
            __index = function() return {} end
        }),
        name = name or "unnamed scene",
        camera_scale = 1,
        camera_translate = Vec2:new(0, 0),
        frozen = false,
        alpha = 1
    }

    return setmetatable(obj, Scene)
end

function Scene:add(object)
    object.scene = self

    table.insert(self.objects, object)

    if #self.obj_by_type[object.type] == 0 then
        self.obj_by_type[object.type] = {object}
        return
    end

    table.insert(self.obj_by_type[object.type], object)
end

function Scene:remove(object)
    util.remove_obj_in_array(self.objects, object)
    util.remove_obj_in_array(self.obj_by_type[object.type], object)
end

function Scene:update(dt)
    self:frozen_update(dt)

    if self.frozen then return end

    for _, object in ipairs(self.objects) do
        if object.update then
            object:update(dt)
        end
    end
end

function Scene:frozen_update(dt)
    for _, object in ipairs(self.objects) do
        if object.frozen_update then
            object:frozen_update(dt)
        end
    end
end

function Scene:translate_xy(x, y)
    x = x / self.camera_scale
    y = y / self.camera_scale
    x = x - self.camera_translate.x
    y = y - self.camera_translate.y

    return x, y
end

function Scene:get_mouse_position()
    x, y = love.mouse.getPosition()
    x = x - love.graphics.getWidth() / 2 
    y = y - love.graphics.getHeight() / 2
    return self:translate_xy(x, y)
end

function Scene:draw()
    local sw, sh = love.graphics.getDimensions()
    local canvas = love.graphics.newCanvas()
    local prev = love.graphics.getCanvas()

    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    table.sort(self.objects, function(a, b)
        return (a.z or 0) < (b.z or 0)
    end)

    for _, object in ipairs(self.objects) do
        if object.draw then
            object:draw()
        end
    end

    love.graphics.setCanvas(prev)

    love.graphics.push()
    love.graphics.scale(self.camera_scale, self.camera_scale)
    love.graphics.translate(self.camera_translate.x-sw/2, self.camera_translate.y-sh/2)
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.draw(canvas)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function Scene:keypressed(key)
    if self.frozen then return end

    for _, object in ipairs(self.objects) do
        if object.keypressed then
            object:keypressed(key)
        end
    end
end

function Scene:keyreleased(key)
    if self.frozen then return end

    for _, object in ipairs(self.objects) do
        if object.keyreleased then
            object:keyreleased(key)
        end
    end
end

function Scene:mousepressed(x, y, button, istouch, presses)
    if self.frozen then return end

    x, y = self:translate_xy(x, y)

    for _, object in ipairs(self.objects) do
        if object.mousepressed then
            object:mousepressed(x, y, button, istouch, presses)
        end
    end
end

function Scene:mousereleased(x, y, button, istouch, presses)
    if self.frozen then return end

    x, y = self:translate_xy(x, y)

    for _, object in ipairs(self.objects) do
        if object.mousereleased then
            object:mousereleased(x, y, button, istouch, presses)
        end
    end
end

function Scene:textinput(t)
    if self.frozen then return end

    for _, object in ipairs(self.objects) do
        if object.textinput then
            object:textinput(t)
        end
    end
end

function Scene:respawn_players()
    for _, player in ipairs(self.obj_by_type["Player"]) do
        player:respawn()
    end

    self:respawn_enemies()
end

function Scene:respawn_enemies()
    for _, enemy in ipairs(self.obj_by_type["Enemy"]) do
        enemy:respawn()
    end
end

function Scene:set_player_spawns()
    for _, player in ipairs(self.obj_by_type["Player"]) do
        player.spawn_position = player.position
    end
end

function Scene:count_dead_enemies()
    local counter = 0
    for _, enemy in ipairs(self.obj_by_type["Enemy"]) do
        if enemy.dead then 
            counter = counter + 1
        end
    end
    return counter
end

return Scene