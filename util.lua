local Vec2 = require("Vec2")

local util = {
    scale = 1,
    global_line_width = 2,
    camera_shake = {
        x = 0,
        y = 0,
    }
}

local input = {
    keys_down = setmetatable({}, {
        __index = function() return false end
    }),
    mouse_buttons_down = setmetatable({}, {
        __index = function() return false end
    }),
}

function input:is_down(key) 
    return self.keys_down[key]
end

function input:keypressed(key) 
    self.keys_down[key] = true
end

function input:keyreleased(key) 
    self.keys_down[key] = false
end

function input:mousepressed(x, y, button) 
    self.mouse_buttons_down[button] = true
end

function input:mousereleased(x, y, button) 
    self.mouse_buttons_down[button] = false
end

function input:is_mouse_down(button)
    return self.mouse_buttons_down[button]
end 

util.input = input

function util.circular_collision(pos1, pos2, d)
    local distance = pos1:sub(pos2)

    return distance:length() < d
end

function util.is_inside_rectangle(pos, rect_pos, rect_size, margin)
    margin = margin or 0

    local margin_x, margin_y

    if type(margin) == "table" then
        margin_x = margin.x
        margin_y = margin.y
    else 
        margin_x = margin
        margin_y = margin
    end

    local rect_end = rect_pos:add(rect_size)
    return  pos.x >= rect_pos.x - margin_x and pos.x <= rect_end.x + margin_x
        and pos.y >= rect_pos.y - margin_y and pos.y <= rect_end.y + margin_y
end

function util.from_persistance_object(obj, class)
    if not obj or not class then
        return nil
    end

    local new_obj = class:from_persistance_object(obj)
    if not new_obj then
        return nil
    end

    return new_obj
end

function util.is_obj_in_array(array, object)
    for i, obj in ipairs(array) do
        if obj == object then
            return true
        end
    end

    return false
end  

function util.remove_obj_in_array(array, to_remove)
    for i, obj in ipairs(array) do
        if obj == to_remove then
            table.remove(array, i)
            break
        end
    end
end

function util.set_default_cursor()
    love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function util.set_hand_cursor()
    love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
end

function util.is_within_margin(pos, pos2, margin_x, margin_y)
    if not margin_y then
        margin_y = margin_x
    end

    return pos.x >= pos2.x - margin_x and pos.x <= pos2.x + margin_x
        and pos.y >= pos2.y - margin_y and pos.y <= pos2.y + margin_y   
end

function util.get_dimensions()
    local w, h = love.graphics.getDimensions()
    return w / util.scale, h / util.scale
end

function util.sign(num)
    if num > 0 then
        return 1
    elseif num < 0 then
        return -1
    else
        return 0
    end
end

function util.input:read_wasd()
    local direction = Vec2:new(0, 0)

    if util.input:is_down("w") then direction.y = direction.y - 1 end
    if util.input:is_down("a") then direction.x = direction.x - 1 end
    if util.input:is_down("s") then direction.y = direction.y + 1 end
    if util.input:is_down("d") then direction.x = direction.x + 1 end

    return direction
end

function util.draw_ring(x, y, outer_radius, inner_radius)
    local width = outer_radius - inner_radius

    love.graphics.setLineWidth(width)

    love.graphics.circle("line", x, y, (outer_radius + inner_radius) / 2)

    love.graphics.setLineWidth(util.global_line_width)
end

function util.draw_rotated_rectangle(filltype, x, y, width, height, angle)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(angle)
    love.graphics.rectangle(filltype, -width/2, -height/2, width, height)
    love.graphics.pop()
end

function util.ease_in_out(x)
    x = math.max(0, math.min(x, 1))

    if x < 0.5 then
        return 4 * x * x * x
    else
        x = 1-x
        return 1 - x * x * x * 4
    end
end

function util.ease_out(x, pow)
    pow = pow or 3

    x = math.max(0, math.min(x, 1))

    x = 1 - x

    return math.pow(x, pow)
end

function util.lerp(a, b, t)
    return a + (b - a) * t
end

function util.draw_star(filltype, x, y, outer_radius, inner_radius, points, angle)
    points = points or 5
    angle = angle or 0
    inner_radius = inner_radius or 0.45 * outer_radius

    local vertices = {}

    for i = 0, points*2 do
        local current_angle = 2*math.pi * (i / (points*2))


        local radius = i % 2 == 0 and inner_radius or outer_radius

        local px = x + radius * math.cos(current_angle + angle + math.pi/2)
        local py = y + radius * math.sin(current_angle + angle + math.pi/2)

        table.insert(vertices, px)
        table.insert(vertices, py)
    end

    love.graphics.polygon(filltype, vertices)
end

return util