local vec3 = require("L3D.math.vec3")

local material = {}
material.__index = material

function material.new(ambient, diffuse, specular, shininess)
    return setmetatable({
        ambient = ambient or vec3.new(0.2, 0.2, 0.2),
        diffuse = diffuse or vec3.new(0.8, 0.8, 0.8),
        specular = specular or vec3.new(1.0, 1.0, 1.0),
        shininess = shininess or 32.0
    }, material)
end

function material.newDefault()
    return material.new(
        vec3.new(0.2, 0.2, 0.2),
        vec3.new(0.8, 0.8, 0.8),
        vec3.new(1.0, 1.0, 1.0),
        32.0
    )
end

return material