local vec3 = {}
vec3.__index = vec3

function vec3.new(x, y, z)
    return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vec3)
end

function vec3:add(v)
    return vec3.new(self.x + v.x, self.y + v.y, self.z + v.z)
end

function vec3:sub(v)
    return vec3.new(self.x - v.x, self.y - v.y, self.z - v.z)
end

function vec3:mul(s)
    return vec3.new(self.x * s, self.y * s, self.z * s)
end

function vec3:length()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

function vec3:normalize()
    local len = self:length()
    if len > 0 then
        return self:mul(1 / len)
    end
    return vec3.new(0, 0, 0)
end

function vec3:dot(v)
    return self.x * v.x + self.y * v.y + self.z * v.z
end

function vec3:cross(v)
    return vec3.new(
        self.y * v.z - self.z * v.y,
        self.z * v.x - self.x * v.z,
        self.x * v.y - self.y * v.x
    )
end

function vec3.__add(a, b)
    return a:add(b)
end

function vec3.__sub(a, b)
    return a:sub(b)
end

function vec3.__mul(a, b)
    if type(a) == "number" then return b:mul(a) end
    if type(b) == "number" then return a:mul(b) end
    return vec3.new(a.x * b.x, a.y * b.y, a.z * b.z)
end

return vec3
