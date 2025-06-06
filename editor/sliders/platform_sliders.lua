local Vec2 = require("Vec2")

local function platform_sliders(platform, margin)
    local min_width = 10

    return {
        left = {
            position = function() 
                return Vec2:new(platform.position.x - platform.width/2 - margin, platform.position.y) 
            end,
            action = function(x, y)
                local right_extremity = platform.position.x + platform.width/2
                local new_width = right_extremity - x - margin

                if new_width < min_width then
                    new_width = min_width
                end

                platform.width = new_width
                platform.position.x = right_extremity - new_width/2
            end
        },
        right = {
            position = function() 
                return Vec2:new(platform.position.x + platform.width/2 + margin, platform.position.y) 
            end,
            action = function(x, y)
                local left_extremity = platform.position.x - platform.width/2
                local new_width = x - left_extremity - margin

                if new_width < min_width then
                    new_width = min_width
                end

                platform.width = new_width
                platform.position.x = left_extremity + new_width/2
            end
        },
    }
end

return platform_sliders