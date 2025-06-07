local util = {
    scale = 1
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

function input:get_mouse_position()
    local x, y = love.mouse.getPosition()
    return x / util.scale, y / util.scale
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

return util