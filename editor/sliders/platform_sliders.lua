local Vec2 = require("Vec2")

local function platform_sliders(platform, margin)
    local min_width = 10

    local function handle_resize(x, fixed_x, is_left)
        local new_width
        if is_left then
            new_width = fixed_x - x - margin
        else
            new_width = x - fixed_x - margin
        end

        new_width = math.max(new_width, min_width)
        platform.width = new_width
        platform.position.x = fixed_x + (is_left and -new_width/2 or new_width/2)
    end

    return {
        left = {
            position = function() 
                return Vec2:new(platform.position.x - platform.width/2 - margin, platform.position.y) 
            end,
            action = function(x, y)
                handle_resize(x, platform.position.x + platform.width/2, true)
            end
        },
        right = {
            position = function() 
                return Vec2:new(platform.position.x + platform.width/2 + margin, platform.position.y) 
            end,
            action = function(x, y)
                handle_resize(x, platform.position.x - platform.width/2, false)
            end
        },
    }
end

return platform_sliders