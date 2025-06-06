local Vec2 = require("Vec2")

local function pivot_sliders(pivot) 
    local min_range = 50

    return {
        top = {
            position = function() return Vec2:new(pivot.position.x, pivot.position.y + pivot.range) end,
            action = function(x, y) 
                local range = y - pivot.position.y
                if range < min_range then
                    range = min_range
                end
                pivot.range = range
            end,
        },
        bottom = {
            position = function() return Vec2:new(pivot.position.x, pivot.position.y - pivot.range) end,
            action = function(x, y) 
                local range = pivot.position.y - y
                if range < min_range then
                    range = min_range
                end
                pivot.range = range
            end,
        },
        left = {
            position = function() return Vec2:new(pivot.position.x - pivot.range, pivot.position.y) end,
            action = function(x, y) 
                local range = pivot.position.x - x
                if range < min_range then
                    range = min_range
                end
                pivot.range = range
            end,
        },
        right = {
            position = function() return Vec2:new(pivot.position.x + pivot.range, pivot.position.y) end,
            action = function(x, y) 
                local range = x - pivot.position.x
                if range < min_range then
                    range = min_range
                end
                pivot.range = range
            end,
        },
    }
end

return pivot_sliders