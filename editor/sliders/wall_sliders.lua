local Vec2 = require("Vec2")

local function wall_sliders(wall, margin)
    local min_dimension = 10

    local function resize_dimension(value, extremity, is_forward, margin)
        local new_size = is_forward and (value - extremity - margin) or (extremity - value - margin)
        if new_size < min_dimension then
            new_size = min_dimension
        end
        return new_size, extremity + (is_forward and new_size/2 or -new_size/2)
    end

    obj = {
        left = {
            position = function() 
                return Vec2:new(wall.position.x - wall.width/2 - margin, wall.position.y) 
            end,
            action = function(x, y)
                wall.width, wall.position.x = resize_dimension(x, wall.position.x + wall.width/2, false, margin)
            end
        },
        right = {
            position = function() 
                return Vec2:new(wall.position.x + wall.width/2 + margin, wall.position.y) 
            end,
            action = function(x, y)
                wall.width, wall.position.x = resize_dimension(x, wall.position.x - wall.width/2, true, margin)
            end
        },
        up = {
            position = function() 
                return Vec2:new(wall.position.x, wall.position.y - wall.height/2 - margin) 
            end,
            action = function(x, y)
                wall.height, wall.position.y = resize_dimension(y, wall.position.y + wall.height/2, false, margin)
            end
        },
        down = {
            position = function() 
                return Vec2:new(wall.position.x, wall.position.y + wall.height/2 + margin) 
            end,
            action = function(x, y)
                wall.height, wall.position.y = resize_dimension(y, wall.position.y - wall.height/2, true, margin)
            end
        },
    }

    obj.up_left = {
        position = function() 
            return Vec2:new(wall.position.x - wall.width/2 - margin, wall.position.y - wall.height/2 - margin) 
        end,
        action = function(x, y)
            obj.up.action(x, y)
            obj.left.action(x, y)
        end
    }

    obj.up_right = {
        position = function() 
            return Vec2:new(wall.position.x + wall.width/2 + margin, wall.position.y - wall.height/2 - margin) 
        end,
        action = function(x, y)
            obj.up.action(x, y)
            obj.right.action(x, y)
        end
    }

    obj.down_left = {
        position = function() 
            return Vec2:new(wall.position.x - wall.width/2 - margin, wall.position.y + wall.height/2 + margin) 
        end,
        action = function(x, y)
            obj.down.action(x, y)
            obj.left.action(x, y)
        end
    }

    obj.down_right = {
        position = function() 
            return Vec2:new(wall.position.x + wall.width/2 + margin, wall.position.y + wall.height/2 + margin) 
        end,
        action = function(x, y)
            obj.down.action(x, y)
            obj.right.action(x, y)
        end
    }


    return obj
end

return wall_sliders