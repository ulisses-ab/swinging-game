local Vec2 = {}
Vec2.__index = Vec2

function Vec2:new(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vec2)
end

function Vec2:from_angle(angle, length)
    length = length or 1
    return Vec2:new(length * math.cos(angle), length * math.sin(angle))
end

function Vec2:add(v)
    return Vec2:new(self.x + v.x, self.y + v.y)
end

function Vec2:sub(v)
    return Vec2:new(self.x - v.x, self.y - v.y)
end

function Vec2:mul(scalar)
    return Vec2:new(self.x * scalar, self.y * scalar)
end

function Vec2:div(scalar)
    return Vec2:new(self.x / scalar, self.y / scalar)
end

function Vec2:dot(v)
    return self.x * v.x + self.y * v.y
end

function Vec2:cross(v)
    return self.x * v.y - self.y * v.x
end

function Vec2:project(v)
    local scalar = self:dot(v) / v:dot(v)
    return v:mul(scalar)
end

function Vec2:orthogonal_projection(v)
    return self:sub(self:project(v))
end

function Vec2:orthogonal()
    return Vec2:new(-self.y, self.x)
end

function Vec2:angle()
    return math.atan2(self.y, self.x)
end

function Vec2:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vec2:normalize()
    local len = self:length()
    if len == 0 then
        return Vec2:new(0, 0)
    end
    return self:div(len)
end

function Vec2:copy()
    return Vec2:new(self.x, self.y)
end

function Vec2:rotate(angle)
    local current_angle = self:angle()
    local new_angle = current_angle + angle
    local len = self:length()

    return Vec2:new(len*math.cos(new_angle), len*math.sin(new_angle))
end

return Vec2