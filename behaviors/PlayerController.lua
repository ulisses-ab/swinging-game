local util = require("util")
local Vec2 = require("Vec2")
local sounds = require("sounds")

local PlayerController = {}
PlayerController.__index = PlayerController

function PlayerController:new(player)
    obj = {}
    
    obj.player = player

    obj.MAX_MOVEMENT_VELOCITY = 600

    obj.can_jump = false

    obj.spacebar_buffer_timer = 0
    obj.SPACEBAR_BUFFER_TIME = 0.1

    obj.coyote_timer = 0
    obj.COYOTE_TIME = 0.05

    return setmetatable(obj, self)
end

function PlayerController:update(dt)
    self.spacebar_buffer_timer = self.spacebar_buffer_timer - dt

    if self.player.platform_behavior:is_on_platform() then
        self.coyote_timer = self.COYOTE_TIME
    else
        self.coyote_timer = self.coyote_timer - dt
    end
end

function PlayerController:apply_input(dt)
    if self.player.slingshot_behavior:is_attached() then return end

    local input_direction = util.input:read_wasd()
    local on_platform = self.player.platform_behavior:is_on_platform()
    local on_pivot = self.player.pivot_behavior:is_attached()
    local pivot_rope_is_extended = self.player.pivot_behavior:is_rope_extended()

    if down then
        self.player.platform_behavior:try_going_down()
    end

    if pivot_rope_is_extended then
        self:apply_rope_input(dt, input_direction)
        return
    end

    if on_platform then
        self:apply_platform_input(dt, input_direction)
        return
    end

    self:apply_air_input(dt, input_direction, on_pivot)
end

function PlayerController:apply_air_input(dt, input_direction, on_pivot)
    local accel = 7000
    local decel = 3500
    local stopping_threshold = 30

    if input_direction.x == 0 then
        if on_pivot then return end

        if math.abs(self.player.velocity.x) < stopping_threshold then
            self.player.velocity.x = 0
        else
            self.player.velocity.x = self.player.velocity.x - (self.player.velocity.x > 0 and 1 or -1) * decel * dt
        end

        return
    end

    if input_direction.x * self.player.velocity.x > self.MAX_MOVEMENT_VELOCITY then
        return
    end

    self.player.velocity.x = self.player.velocity.x + input_direction.x * accel * dt
end

function PlayerController:apply_platform_input(dt, input_direction)
    local platform_deceleration = 14000

    if input_direction.x == 0 then
        self.player.velocity.x = 0
        return
    end

    if 
        math.abs(self.player.velocity.x) > self.MAX_MOVEMENT_VELOCITY and
        self.player.velocity.x * input_direction.x > 0  
    then
        self.player.velocity.x = self.player.velocity.x - (self.player.velocity.x > 0 and 1 or -1) * platform_deceleration * dt
        return
    end

    self.player.velocity.x = self.MAX_MOVEMENT_VELOCITY * input_direction.x
    return
end

function PlayerController:apply_rope_input(dt, input_direction)
    local pivot_pos = self.player.pivot_behavior.attached_pivot.position
    local pivot_displacement = self.player.position:sub(pivot_pos)

    if input_direction:length() > 0 then
        input_direction = input_direction:normalize()
    else
        return
    end

    local accel = 3000

    local inward_component = pivot_displacement:dot(input_direction) < 0 and input_direction:project(pivot_displacement) or Vec2:new(0, 0)

    input_direction = input_direction:sub(inward_component)

    self.player.velocity = self.player.velocity:add(input_direction:mul(dt*accel))
end

function PlayerController:jump()
    self.spacebar_buffer_timer = 0
    sounds.jump:stop()
    sounds.jump:play()
    self.can_jump = false
    self.player.velocity.y = -1640
    self.player.platform_behavior:reset_platform()
end

function PlayerController:keypressed(key)
    if key == "space" then
        self.player.pivot_behavior:try_attaching()
        self.player.slingshot_behavior:try_attaching()
        self.spacebar_buffer_timer = self.SPACEBAR_BUFFER_TIME

        if self.can_jump and (self.player.platform_behavior:is_on_platform() or self.coyote_timer > 0) then
            self:jump()
        end

        self.can_jump = false
    elseif key == "q" then
        print(self.player.velocity:length())
    elseif key == "r" then
        self.player:respawn()
    elseif key == "s" then
        self.player.platform_behavior:try_going_down()
    end
end

function PlayerController:set_platform()
    if self.spacebar_buffer_timer > 0 then
        self.player.platform_behavior.fall_sound:play()
        self:jump()
        return false
    end

    if util.input:is_down("s") then
        return false
    end

    self.can_jump = true

    return true
end

function PlayerController:keyreleased(key)
    if key == "space" then
        self.player.pivot_behavior:try_detaching()
        self.player.slingshot_behavior:try_detaching()
    end
end

function PlayerController:mousepressed(x, y, button)
    if button == 1 then
        self.player.gun_behavior:load()
    end
end

function PlayerController:mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        self.player.gun_behavior:release()
    end
end

return PlayerController