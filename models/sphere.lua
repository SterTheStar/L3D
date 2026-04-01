local mesh = require("L3D.scene.mesh")

local sphere = {}

function sphere.new(radius, sectors, stacks)
    local R = radius or 1.0
    local S = sectors or 32
    local St = stacks or 16
    
    local vertices = {}
    local indices = {}
    
    local sectorStep = 2 * math.pi / S
    local stackStep = math.pi / St
    
    for i = 0, St do
        local stackAngle = math.pi / 2 - i * stackStep
        local xy = R * math.cos(stackAngle)
        local z = R * math.sin(stackAngle)
        
        for j = 0, S do
            local sectorAngle = j * sectorStep
            local x = xy * math.cos(sectorAngle)
            local y = xy * math.sin(sectorAngle)
            
            local nx = x / R
            local ny = y / R
            local nz = z / R
            
            local u = j / S
            local v = i / St
            
            table.insert(vertices, x)
            table.insert(vertices, y)
            table.insert(vertices, z)
            table.insert(vertices, nx)
            table.insert(vertices, ny)
            table.insert(vertices, nz)
            table.insert(vertices, u)
            table.insert(vertices, v)
        end
    end
    
    for i = 0, St - 1 do
        for j = 0, S - 1 do
            local first = (i * (S + 1)) + j
            local second = first + S + 1
            
            table.insert(indices, first)
            table.insert(indices, second)
            table.insert(indices, first + 1)
            
            table.insert(indices, second)
            table.insert(indices, second + 1)
            table.insert(indices, first + 1)
        end
    end
    
    return mesh.new(vertices, indices)
end

return sphere