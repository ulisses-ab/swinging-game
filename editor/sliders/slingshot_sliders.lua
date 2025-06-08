local Vec2 = require("Vec2")

local function slingshot_sliders(slingshot) 
    local min_measure = 50
    local allow_center_being_outside = false

    local function resize(slingshot, new_range, opp_range, set_range)
        if new_range < -opp_range + min_measure then
            new_range = -opp_range + min_measure
        end

        if not allow_center_being_outside and new_range < 0 then
            new_range = 0
        end

        set_range(slingshot, new_range)
    end

    obj = {
        up = {
            position = function() 
                return Vec2:new(slingshot:rect_position().x + slingshot.rect_size.x / 2, slingshot.position.y - slingshot:up_range()) 
            end,
            action = function(x, y) 
                resize(slingshot, slingshot.position.y - y, slingshot:down_range(), slingshot.set_up_range)
            end,
        },
        down = {
            position = function() 
                return Vec2:new(slingshot:rect_position().x + slingshot.rect_size.x / 2, slingshot.position.y + slingshot:down_range()) 
            end,
            action = function(x, y) 
                resize(slingshot, y - slingshot.position.y, slingshot:up_range(), slingshot.set_down_range)
            end,
        },
        left = {
            position = function() 
                return Vec2:new(slingshot.position.x - slingshot:left_range(), slingshot:rect_position().y + slingshot.rect_size.y / 2) 
            end,
            action = function(x, y) 
                resize(slingshot, slingshot.position.x - x, slingshot:right_range(), slingshot.set_left_range)
            end,
        },
        right = {
            position = function() 
                return Vec2:new(slingshot.position.x + slingshot:right_range(), slingshot:rect_position().y + slingshot.rect_size.y / 2) 
            end,
            action = function(x, y) 
                resize(slingshot, x - slingshot.position.x, slingshot:left_range(), slingshot.set_right_range)
            end,
        },
    }

    obj.up_left = {
        position = function() 
            return Vec2:new(slingshot.position.x - slingshot:left_range(), slingshot.position.y - slingshot:up_range()) 
        end,
        action = function(x, y)
            obj.up.action(x, y)
            obj.left.action(x, y)
        end
    }

    obj.up_right = {
        position = function() 
            return Vec2:new(slingshot.position.x + slingshot:right_range(), slingshot.position.y - slingshot:up_range()) 
        end,
        action = function(x, y)
            obj.up.action(x, y)
            obj.right.action(x, y)
        end
    }

    obj.down_left = {
        position = function() 
            return Vec2:new(slingshot.position.x - slingshot:left_range(), slingshot.position.y + slingshot:down_range()) 
        end,
        action = function(x, y)
            obj.down.action(x, y)
            obj.left.action(x, y)
        end
    }

    obj.down_right = {
        position = function() 
            return Vec2:new(slingshot.position.x + slingshot:right_range(), slingshot.position.y + slingshot:down_range()) 
        end,
        action = function(x, y)
            obj.down.action(x, y)
            obj.right.action(x, y)
        end
    }

    return obj
end

return slingshot_sliders