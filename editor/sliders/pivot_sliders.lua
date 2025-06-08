local Vec2 = require("Vec2")

local min_range = 50

local function set_range(pivot, new_range)
    if new_range < min_range then
        new_range = min_range
    end
    pivot.range = new_range
end

local function pivot_sliders(pivot) 
    return {
        top = {
            position = function() return Vec2:new(pivot.position.x, pivot.position.y + pivot.range) end,
            action = function(x, y) 
                set_range(pivot, y - pivot.position.y)
            end,
        },
        bottom = {
            position = function() return Vec2:new(pivot.position.x, pivot.position.y - pivot.range) end,
            action = function(x, y) 
                set_range(pivot, pivot.position.y - y)
            end,
        },
        left = {
            position = function() return Vec2:new(pivot.position.x - pivot.range, pivot.position.y) end,
            action = function(x, y) 
                set_range(pivot, pivot.position.x - x)
            end,
        },
        right = {
            position = function() return Vec2:new(pivot.position.x + pivot.range, pivot.position.y) end,
            action = function(x, y) 
                set_range(pivot, x - pivot.position.x)
            end,
        },
    }
end

return pivot_sliders