local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")
local PivotBehavior = require("behaviors.PivotBehavior")
local SlingshotBehavior = require("behaviors.SlingshotBehavior")
local PlatformBehavior = require("behaviors.PlatformBehavior")
local AttackBehavior = require("behaviors.AttackBehavior")
local WallBehavior = require("behaviors.WallBehavior")
local PlayerController = require("behaviors.PlayerController")
local EventBus = require("EventBus")

local Player = {}
Player.__index = Player
setmetatable(Player, GameObject)

Player.type = "Player"

Player.allow_respawn = true

function Player:new(spawn_position)
    local obj = GameObject:new(spawn_position)

    obj.spawn_position = spawn_position

    obj.z = 1

    obj.acceleration = Vec2:new(0, 4000)

    local function draw_line(...) obj:draw_line(...) end 

    obj.pivot_behavior = PivotBehavior:new(obj, draw_line)
    obj.slingshot_behavior = SlingshotBehavior:new(obj, draw_line)
    obj.platform_behavior = PlatformBehavior:new(obj)
    obj.attack_behavior = AttackBehavior:new(obj)
    obj.wall_behavior = WallBehavior:new(obj)
    obj.controller = PlayerController:new(obj)

    obj.width = 28
    obj.height = 28

    obj.color = {r = 1, g = 0, b = 1, a = 1}

    return setmetatable(obj, self)
end

function Player:persistance_object()
    obj = {
        x = self.position.x,
        y = self.position.y,
        type = self.type,
    }

    return obj
end

function Player:from_persistance_object(obj)
    return Player:new(Vec2:new(obj.x, obj.y), obj.velocity, obj.acceleration)
end

function Player:bottom()
    return Vec2:new(self.position.x, self.position.y + self.height / 2)
end

function Player:center_to_bottom_vec()
    return self:bottom():sub(self.position)
end

function Player:draw() 
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a or 1)
    GameObject.draw(self)

    love.graphics.setColor(1, 1, 1)

    self.pivot_behavior:draw()
    self.slingshot_behavior:draw()
    self.attack_behavior:draw()
end

function Player:draw_line(pos1, pos2) 
    love.graphics.setLineWidth(3)
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a or 1)
    love.graphics.line(
        pos1.x, pos1.y,
        pos2.x, pos2.y
    )
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(util.global_line_width)
end

function Player:update(dt)
    GameObject.update(self, dt)

    self.controller:apply_input(dt)

    self.pivot_behavior:update(dt)
    self.slingshot_behavior:update(dt)
    self.platform_behavior:update(dt)
    self.attack_behavior:update(dt)
    self.controller:update(dt)
    self.wall_behavior:update(dt)
end

function Player:respawn()
    if not Player.allow_respawn then return end

    self.position = self.spawn_position
    self.velocity = Vec2:new(0, 0)
    self.pivot_behavior:try_detaching()
    self.slingshot_behavior:try_detaching()
    self.platform_behavior:reset_platform()
    self.attack_behavior:reset()
    EventBus:emit("PlayerRespawn", self)
end

function Player:keypressed(key)
    self.controller:keypressed(key)
end

function Player:keyreleased(key)
    self.controller:keyreleased(key)
end

function Player:mousepressed(x, y, button, istouch, presses)
    self.controller:mousepressed(x, y, button, istouch, presses)
end

function Player:mousereleased(x, y, button, istouch, presses)
    self.controller:mousereleased(x, y, button, istouch, presses)
end

function Player:set_near_slingshot(slingshot)
    self.slingshot_behavior:set_near_slingshot(slingshot)
end

function Player:reset_near_slingshot()
    self.slingshot_behavior:reset_near_slingshot()
end

function Player:set_platform(platform)
    if not self.controller:set_platform(platform) then return end

    self.platform_behavior:set_platform(platform)
end

function Player:reset_platform()
    self.platform_behavior:reset_platform()
end

return Player
