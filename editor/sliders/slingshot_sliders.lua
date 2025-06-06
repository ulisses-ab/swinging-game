local Vec2 = require("Vec2")

local function slingshot_sliders(slingshot) 
    local min_measure = 20
    local allow_center_being_outside = false

    return {
        top = {
            position = function() 
                return Vec2:new(slingshot:rect_position().x + slingshot.rect_size.x / 2, slingshot.position.y - slingshot:up_range()) 
            end,
            action = function(x, y) 
                local up_range = slingshot.position.y - y
                local opp_range = slingshot:down_range()

                if up_range < -opp_range + min_measure then
                    up_range = -opp_range + min_measure
                end

                if not allow_center_being_outside and up_range < 0 then
                    up_range = 0
                end
                
                slingshot:set_up_range(up_range)
            end,
        },
        bottom = {
            position = function() 
                return Vec2:new(slingshot:rect_position().x + slingshot.rect_size.x / 2, slingshot.position.y + slingshot:down_range()) 
            end,
            action = function(x, y) 
                local down_range = y - slingshot.position.y
                local opp_range = slingshot:up_range()

                if down_range < -opp_range + min_measure then
                    down_range = -opp_range + min_measure
                end

                if not allow_center_being_outside and down_range < 0 then
                    down_range = 0
                end

                slingshot:set_down_range(down_range)
            end,
        },
        left = {
            position = function() 
                return Vec2:new(slingshot.position.x - slingshot:left_range(), slingshot:rect_position().y + slingshot.rect_size.y / 2) 
            end,
            action = function(x, y) 
                local left_range = slingshot.position.x - x
                local opp_range = slingshot:right_range()

                if left_range < -opp_range + min_measure then
                    left_range = -opp_range + min_measure
                end

                if not allow_center_being_outside and left_range < 0 then
                    left_range = 0
                end
                
                slingshot:set_left_range(left_range)
            end,
        },
        right = {
            position = function() 
                return Vec2:new(slingshot.position.x + slingshot:right_range(), slingshot:rect_position().y + slingshot.rect_size.y / 2) 
            end,
            action = function(x, y) 
                local right_range = x - slingshot.position.x
                local opp_range = slingshot:left_range()

                if right_range < -opp_range + min_measure then
                    right_range = -opp_range + min_measure
                end

                if not allow_center_being_outside and right_range < 0 then
                    right_range = 0
                end

                slingshot:set_right_range(right_range)
            end,
        },
    }
end

return slingshot_sliders