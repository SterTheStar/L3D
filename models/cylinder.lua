local mesh = require("L3D.scene.mesh")

local cylinder = {}

function cylinder.new(radius, height, segments)
    local r = radius or 1.0
    local h = height or 1.0
    local seg = segments or 32
    
    local vertices = {}
    local indices = {}
    
    for i = 0, seg do
        local angle = 2 * math.pi * i / seg
        local x = r * math.cos(angle)
        local z = r * math.sin(angle)
        
        table.insert(vertices, x)
        table.insert(vertices, -h/2)
        table.insert(vertices, z)
        table.insert(vertices, math.cos(angle))
        table.insert(vertices, 0.0)
        table.insert(vertices, math.sin(angle))
        table.insert(vertices, i / seg)
        table.insert(vertices, 0.0)
        
        table.insert(vertices, x)
        table.insert(vertices, h/2)
        table.insert(vertices, z)
        table.insert(vertices, math.cos(angle))
        table.insert(vertices, 0.0)
        table.insert(vertices, math.sin(angle))
        table.insert(vertices, i / seg)
        table.insert(vertices, 1.0)
    end
    
    for i = 0, seg - 1 do
        local base = i * 2
        table.insert(indices, base)
        table.insert(indices, base + 1)
        table.insert(indices, base + 2)
        table.insert(indices, base + 1)
        table.insert(indices, base + 3)
        table.insert(indices, base + 2)
    end
    
    return mesh.new(vertices, indices)
end

return cylinder