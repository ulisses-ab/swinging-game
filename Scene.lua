local util = require("util")
local Bullet = require("game_objects.Bullet")

local Scene = {}
Scene.__index = Scene

function Scene:new(name)
    local obj = {
        objects = {},
        pivots = {},
        slingshots = {},
        platforms = {},
        players = {},
        name = name or "unnamed scene"
    }

    return setmetatable(obj, Scene)
end

function Scene:add(object)
    table.insert(self.objects, object)

    local actions = {
        Pivot = self.add_pivot,
        Slingshot = self.add_slingshot,
        Platform = self.add_platform,
        Player = self.add_player,
    }

    local action = actions[object.type]

    if action then
        action(self, object)
    end
end

function Scene:remove(object)
    for i, obj in ipairs(self.objects) do
        if obj == object then
            table.remove(self.objects, i)
            break
        end
    end

    local actions = {
        Pivot = self.remove_pivot,
        Slingshot = self.remove_slingshot,
        Platform = self.remove_platform,
        Player = self.remove_player,
    }

    local action = actions[object.type]

    if action then
        action(self, object)
    end
end

function Scene:add_pivot(pivot)
    table.insert(self.pivots, pivot)
end

function Scene:remove_pivot(pivot)
    util.remove_obj_in_array(self.pivots, pivot)
end

function Scene:add_player(player)
    player.gun_behavior.spawn_bullet = self:bullet_spawner()
    table.insert(self.players, player)
end

function Scene:remove_player(player)
    util.remove_obj_in_array(self.players, player)
end

function Scene:add_slingshot(slingshot)
    table.insert(self.slingshots, slingshot)
end

function Scene:remove_slingshot(slingshot)
    util.remove_obj_in_array(self.slingshots, slingshot)
end

function Scene:add_platform(platform)
    table.insert(self.platforms, platform)
end

function Scene:remove_platform(platform)
    util.remove_obj_in_array(self.platforms, platform)
end

function Scene:update(dt)
    self:check_pivot_collision()
    self:check_slingshot_collision()
    self:check_platform_collision()

    for _, object in ipairs(self.objects) do
        if object.update then
            object:update(dt)
        end
    end
end

function Scene:draw()    
    table.sort(self.objects, function(a, b)
        return (a.z or 0) < (b.z or 0)
    end)

    for _, object in ipairs(self.objects) do
        if object.draw then
            object:draw()
        end
    end
end

function Scene:keypressed(key)
    for _, object in ipairs(self.objects) do
        if object.keypressed then
            object:keypressed(key)
        end
    end
end

function Scene:keyreleased(key)
    for _, object in ipairs(self.objects) do
        if object.keyreleased then
            object:keyreleased(key)
        end
    end
end

function Scene:mousepressed(x, y, button, istouch, presses)
    for _, object in ipairs(self.objects) do
        if object.mousepressed then
            object:mousepressed(x, y, button, istouch, presses)
        end
    end
end

function Scene:mousereleased(x, y, button, istouch, presses)
    for _, object in ipairs(self.objects) do
        if object.mousereleased then
            object:mousereleased(x, y, button, istouch, presses)
        end
    end
end

function Scene:check_pivot_collision()
    for _, player in ipairs(self.players) do
        local found = false 

        for _, pivot in ipairs(self.pivots) do
            if util.circular_collision(player.position, pivot.position, pivot.range) then
                player:set_near_pivot(pivot)
                found = true
                break
            end
        end

        if not found then
            player:reset_near_pivot()
        end
    end
end

function Scene:check_slingshot_collision()
    for _, player in ipairs(self.players) do
        local found = false

        for _, slingshot in ipairs(self.slingshots) do
            if util.is_inside_rectangle(player.position, slingshot:rect_position(), slingshot.rect_size) then
                found = true
                player:set_near_slingshot(slingshot)
                break
            end
        end

        if not found then
            player:reset_near_slingshot()
        end
    end
end

function Scene:check_platform_collision()
    for _, player in ipairs(self.players) do
        for _, platform in ipairs(self.platforms) do
            if 
                (platform:is_above(player.last_position:add(player:center_to_bottom_vec()), player.width / 2) and
                platform:is_below(player.position:add(player:center_to_bottom_vec()), player.width / 2)) or
                (platform:is_right_above(player.position:add(player:center_to_bottom_vec()), player.width / 2) and
                player.velocity.y > 0)
            then
                player:set_platform(platform)
                break
            end
        end
    end
end

function Scene:bullet_spawner()
    return function(position, velocity)
        local bullet = Bullet:new(position, velocity, self:object_remover())
        self:add(bullet)
    end
end

function Scene:object_remover()
    return function(object)
        self:remove(object)
    end
end

return Scene