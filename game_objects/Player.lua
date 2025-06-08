local GameObject = require("game_objects.GameObject")
local util = require("util")
local Vec2 = require("Vec2")
local PivotBehavior = require("behaviors.PivotBehavior")
local SlingshotBehavior = require("behaviors.SlingshotBehavior")
local PlatformBehavior = require("behaviors.PlatformBehavior")
local GunBehavior = require("behaviors.GunBehavior")
local SwordBehavior = require("behaviors.SwordBehavior")
local sounds = require("sounds")

local Player = {}
Player.__index = Player
setmetatable(Player, GameObject)

Player.type = "Player"

local main_color = {
    r = 1,
    g = 0,
    b = 1,
}

local jump_audio = sounds.jump

local function draw_line(pos1, pos2) 
    love.graphics.setColor(main_color.r, main_color.g, main_color.b)
    love.graphics.line(
        pos1.x, pos1.y,
        pos2.x, pos2.y
    )
    love.graphics.setColor(1, 1, 1)
end

function Player:new(position)
    local obj = GameObject:new(position)

    obj.z = 1

    obj.MAX_MOVEMENT_VELOCITY = 600

    obj.acceleration = Vec2:new(0, 4000)

    obj.pivot_behavior = PivotBehavior:new(obj, draw_line)
    obj.slingshot_behavior = SlingshotBehavior:new(obj, draw_line)
    obj.platform_behavior = PlatformBehavior:new(obj)
    obj.gun_behavior = GunBehavior:new(obj)

    obj.can_jump = false

    obj.platform_behavior.on_land = function()
        obj.can_jump = true
    end

    obj.spacebar_buffer_timer = 0
    obj.SPACEBAR_BUFFER_TIME = 0.1

    obj.coyote_timer = 0
    obj.COYOTE_TIME = 0.1

    obj.trail = {}
    obj.trail.positions = {}
    obj.trail.last = 0
    obj.trail.max_length = 100

    obj.width = 25
    obj.height = 25

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
    love.graphics.setColor(main_color.r, main_color.g, main_color.b)
    GameObject.draw(self)

    local sw, sh = love.graphics.getDimensions()

    if self.position.y < 0 then
        if self.position.x < 30 then
            love.graphics.polygon('fill', 
                60, 35,
                35, 60,
                30, 30
            )
        elseif self.position.x > sw-30 then
            love.graphics.polygon('fill', 
                sw-60, 35,
                sw-35, 60,
                sw-30, 30
            )
        else
            love.graphics.polygon('fill', 
                self.position.x - 15, 55,
                self.position.x + 15, 55,
                self.position.x, 30
            )
        end
    elseif self.position.x < 0 then
        love.graphics.polygon('fill', 
            55, self.position.y - 15,
            55, self.position.y + 15,
            30, self.position.y
        )
    elseif self.position.x > sw then
        love.graphics.polygon('fill', 
            sw-55, self.position.y - 15,
            sw-55, self.position.y + 15,
            sw-30, self.position.y
        )
    end

    love.graphics.setColor(1, 1, 1)

    self.pivot_behavior:draw()
    self.slingshot_behavior:draw()
    self.gun_behavior:draw()
end

function Player:update(dt)
    self.trail.last = self.trail.last + 1
    self.trail.positions[self.trail.last] = self.position:copy()
    if self.trail.last > self.trail.max_length then
        self.trail.positions[self.trail.last - self.trail.max_length] = nil
    end

    GameObject.update(self, dt)

    self:apply_move_input(dt)

    self.pivot_behavior:update(dt)
    self.slingshot_behavior:update(dt)
    self.platform_behavior:update(dt)
    self.gun_behavior:update(dt)

    self.spacebar_buffer_timer = self.spacebar_buffer_timer - dt

    if self.platform_behavior:is_on_platform() then
        self.coyote_timer = self.COYOTE_TIME
    else
        self.coyote_timer = self.coyote_timer - dt
    end
end

function Player:apply_move_input(dt)
    if self.slingshot_behavior:is_attached() then
        return
    end

    local left = util.input:is_down("a")
    local right = util.input:is_down("d")
    local up = util.input:is_down("w")
    local down = util.input:is_down("s")

    if down then
        self.platform_behavior:try_going_down()
    end


    local on_pivot = self.pivot_behavior:is_attached()
    local pivot_rope_is_extended = self.pivot_behavior:is_rope_extended()

    if pivot_rope_is_extended then
        self:apply_move_input_when_rope_is_extended(dt)
        return
    end

    local accel = 7000
    local stopping_threshold = 30

    if down and self.velocity.y < 2 * self.MAX_MOVEMENT_VELOCITY then
        --self.velocity.y = self.velocity.y + accel / 2 * dt
    end

    if pivot_rope_is_extended and up ~= down then
        if up then
            self.velocity.y = self.velocity.y - accel * dt
        elseif down then
            self.velocity.y = self.velocity.y + accel * dt
        end
    end

    if left == right then
        if on_pivot then
            return
        end
 
        if self.platform_behavior:is_on_platform() then
            self.velocity.x = 0
            return
        end

        if math.abs(self.velocity.x) < stopping_threshold then
            self.velocity.x = 0
        else
            self.velocity.x = self.velocity.x - (self.velocity.x > 0 and 1 or -1) * accel / 2 * dt
        end

        return
    end

    if self.platform_behavior:is_on_platform() then
        if 
            math.abs(self.velocity.x) > self.MAX_MOVEMENT_VELOCITY and
            self.velocity.x * (right and 1 or -1) > 0  
        then
            local platform_deceleration = 2 * accel
            self.velocity.x = self.velocity.x - (self.velocity.x > 0 and 1 or -1) * platform_deceleration * dt
            return
        end

        self.velocity.x = self.MAX_MOVEMENT_VELOCITY * (right and 1 or -1)
        return
    end

    if not pivot_rope_is_extended and
        (
            (right and self.velocity.x > self.MAX_MOVEMENT_VELOCITY) or
            (not right and self.velocity.x < -self.MAX_MOVEMENT_VELOCITY)
        )
    then
        return
    end

    self.velocity.x = self.velocity.x + (right and 1 or -1) * accel * dt
end

function Player:apply_move_input_when_rope_is_extended(dt)
    local pivot_pos = self.pivot_behavior.attached_pivot.position
    local pivot_displacement = self.position:sub(pivot_pos)

    local input_dir = Vec2:new(0, 0)

    if util.input:is_down("a") then input_dir.x = input_dir.x - 1 end
    if util.input:is_down("d") then input_dir.x = input_dir.x + 1 end
    if util.input:is_down("w") then input_dir.y = input_dir.y - 1 end
    if util.input:is_down("s") then input_dir.y = input_dir.y + 1 end

    if input_dir:length() > 0 then
        input_dir = input_dir:normalize()
    else
        return
    end

    local accel = 3000

    local inward_component = pivot_displacement:dot(input_dir) < 0 and input_dir:project(pivot_displacement) or Vec2:new(0, 0)

    input_dir = input_dir:sub(inward_component)

    self.velocity = self.velocity:add(input_dir:mul(dt*accel))
end

function Player:jump()
    jump_audio:stop()
    jump_audio:play()
    self.can_jump = false
    self.velocity.y = -1640
    self.platform_behavior:reset_platform()
end

function Player:keypressed(key)
    if key == "space" then
        self.pivot_behavior:try_attaching()
        self.slingshot_behavior:try_attaching()

        if self.can_jump and (self.platform_behavior:is_on_platform() or self.coyote_timer > 0) then
            self:jump()
        end

        self.spacebar_buffer_timer = self.SPACEBAR_BUFFER_TIME

        self.can_jump = false
    elseif key == "q" then
        print(self.velocity:length())
    elseif key == "r" then
        self.position = Vec2:new(100, 100)
        self.velocity = Vec2:new(0, 0)
        self.pivot_behavior:reset_near_pivot()
        self.slingshot_behavior:reset_near_slingshot()
        self.platform_behavior:reset_platform()
    elseif key == "s" then
        self.platform_behavior:try_going_down()
    end
end

function Player:keyreleased(key)
    if key == "space" then
        self.pivot_behavior:try_detaching()
        self.slingshot_behavior:try_detaching()
    end
end

function Player:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        self.gun_behavior:load()
    end
end

function Player:mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        self.gun_behavior:release()
    end
end

function Player:set_near_pivot(pivot)
    self.pivot_behavior:set_near_pivot(pivot)
end

function Player:reset_near_pivot()
    self.pivot_behavior:reset_near_pivot()
end

function Player:set_near_slingshot(slingshot)
    self.slingshot_behavior:set_near_slingshot(slingshot)
end

function Player:reset_near_slingshot()
    self.slingshot_behavior:reset_near_slingshot()
end

function Player:set_platform(platform)
    if self.spacebar_buffer_timer > 0 then
        self.platform_behavior.fall_sound:play()
        self:jump()
        return
    end

    if util.input:is_down("s") then
        return
    end

    self.platform_behavior:set_platform(platform)
end

function Player:reset_platform()
    self.platform_behavior:reset_platform()
end

return Player
