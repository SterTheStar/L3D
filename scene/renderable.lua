local mat4 = require("L3D.math.mat4")
local vec3 = require("L3D.math.vec3")

local renderable = {}
renderable.__index = renderable

function renderable.new(mesh, material, position, rotation, scale)
    return setmetatable({
        mesh = mesh,
        material = material or {ambient = vec3.new(0.2, 0.2, 0.2), diffuse = vec3.new(0.8, 0.8, 0.8), specular = vec3.new(1.0, 1.0, 1.0), shininess = 32.0},
        position = position or vec3.new(0, 0, 0),
        rotation = rotation or vec3.new(0, 0, 0),
        scale = scale or vec3.new(1, 1, 1),
        dirty = true,
        modelMatrix = mat4.identity(),
        boundingRadius = 1.0
    }, renderable)
end

function renderable:getModelMatrix()
    if self.dirty then
        local model = mat4.identity()
        model = model * mat4.translate(self.position.x, self.position.y, self.position.z)
        model = model * mat4.rotate(self.rotation.y, 0, 1, 0)
        model = model * mat4.rotate(self.rotation.x, 1, 0, 0)
        model = model * mat4.rotate(self.rotation.z, 0, 0, 1)
        model = model * mat4.scale(self.scale.x, self.scale.y, self.scale.z)
        self.modelMatrix = model
        self.dirty = false
    end
    return self.modelMatrix
end

function renderable:getNormalMatrix(model)
    local m = model or self:getModelMatrix()
    
    local upper = {
        m[1], m[2], m[3],
        m[5], m[6], m[7],
        m[9], m[10], m[11]
    }
    
    local det = m[1] * (m[6]*m[11] - m[7]*m[10]) - 
                m[2] * (m[5]*m[11] - m[7]*m[9]) + 
                m[3] * (m[5]*m[10] - m[6]*m[9])
    
    if math.abs(det) < 0.0001 then
        return {1, 0, 0, 0, 1, 0, 0, 0, 1}
    end
    
    local invDet = 1.0 / det
    
    return {
        (m[6]*m[11] - m[7]*m[10]) * invDet,
        (m[3]*m[10] - m[2]*m[11]) * invDet,
        (m[2]*m[7] - m[3]*m[6]) * invDet,
        (m[7]*m[9] - m[5]*m[11]) * invDet,
        (m[1]*m[11] - m[3]*m[9]) * invDet,
        (m[3]*m[5] - m[1]*m[7]) * invDet,
        (m[5]*m[10] - m[6]*m[9]) * invDet,
        (m[2]*m[9] - m[1]*m[10]) * invDet,
        (m[1]*m[6] - m[2]*m[5]) * invDet
    }
end

function renderable:setPosition(x, y, z)
    self.position = vec3.new(x, y, z)
    self.dirty = true
end

function renderable:setRotation(x, y, z)
    self.rotation = vec3.new(x, y, z)
    self.dirty = true
end

function renderable:setScale(x, y, z)
    self.scale = vec3.new(x, y, z)
    self.dirty = true
end

function renderable:translate(x, y, z)
    self.position = self.position:add(vec3.new(x, y, z))
    self.dirty = true
end

function renderable:rotate(x, y, z)
    self.rotation = self.rotation:add(vec3.new(x, y, z))
    self.dirty = true
end

return renderable