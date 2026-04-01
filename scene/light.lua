local vec3 = require("L3D.math.vec3")

local light = {}
light.__index = light

function light.newDirectional(direction, color, intensity)
    return setmetatable({
        type = "directional",
        direction = direction or vec3.new(-1, -1, -1),
        position = vec3.new(0, 0, 0),
        color = color or {1, 1, 1},
        intensity = intensity or 1.0
    }, light)
end

function light.newPoint(position, color, constant, linear, quadratic)
    return setmetatable({
        type = "point",
        position = position or vec3.new(0, 0, 0),
        color = color or {1, 1, 1},
        constant = constant or 1.0,
        linear = linear or 0.09,
        quadratic = quadratic or 0.032
    }, light)
end

function light.newSpot(position, direction, cutOff, outerCutOff, color, constant, linear, quadratic)
    return setmetatable({
        type = "spot",
        position = position or vec3.new(0, 0, 0),
        direction = direction or vec3.new(0, -1, 0),
        cutOff = cutOff or math.cos(math.rad(12.5)),
        outerCutOff = outerCutOff or math.cos(math.rad(15.0)),
        color = color or {1, 1, 1},
        constant = constant or 1.0,
        linear = linear or 0.09,
        quadratic = quadratic or 0.032
    }, light)
end

function light.newAmbient(color, intensity)
    return setmetatable({
        type = "ambient",
        position = vec3.new(0, 0, 0),
        direction = vec3.new(0, 0, 0),
        color = color or {0.2, 0.2, 0.2},
        intensity = intensity or 1.0
    }, light)
end

function light:setPosition(x, y, z)
    if type(x) == "table" then
        self.position = x
    else
        self.position = vec3.new(x, y, z)
    end
end

function light:setDirection(x, y, z)
    if type(x) == "table" then
        self.direction = x
    else
        self.direction = vec3.new(x, y, z)
    end
end

return light