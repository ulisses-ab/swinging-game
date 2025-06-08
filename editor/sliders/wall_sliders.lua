local Vec2 = require("Vec2")

local function wall_sliders(wall, margin)
    local min_dimension = 10

    obj = {
        left = {
            position = function() 
                return Vec2:new(wall.position.x - wall.width/2 - margin, wall.position.y) 
            end,
            action = function(x, y)
                local right_extremity = wall.position.x + wall.width/2
                local new_width = right_extremity - x - margin

                if new_width < min_dimension then
                    new_width = min_dimension
                end

                wall.width = new_width
                wall.position.x = right_extremity - new_width/2
            end
        },
        right = {
            position = function() 
                return Vec2:new(wall.position.x + wall.width/2 + margin, wall.position.y) 
            end,
            action = function(x, y)
                local left_extremity = wall.position.x - wall.width/2
                local new_width = x - left_extremity - margin

                if new_width < min_dimension then
                    new_width = min_dimension
                end

                wall.width = new_width
                wall.position.x = left_extremity + new_width/2
            end
        },
        up = {
            position = function() 
                return Vec2:new(wall.position.x, wall.position.y - wall.height/2 - margin) 
            end,
            action = function(x, y)
                local down_extremity = wall.position.y + wall.height/2
                local new_height = down_extremity - y - margin

                if new_height < min_dimension then
                    new_height = min_dimension
                end

                wall.height = new_height
                wall.position.y = down_extremity - new_height/2
            end
        },
        down = {
            position = function() 
                return Vec2:new(wall.position.x, wall.position.y + wall.height/2 + margin) 
            end,
            action = function(x, y)
                local up_extremity = wall.position.y - wall.height/2
                local new_height = y - up_extremity - margin

                if new_height < min_dimension then
                    new_height = min_dimension
                end

                wall.height = new_height
                wall.position.y = up_extremity + new_height/2
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