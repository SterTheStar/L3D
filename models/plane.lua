local mesh = require("L3D.scene.mesh")

local plane = {}

function plane.new(width, height)
    local w = width or 1.0
    local h = height or 1.0
    
    local vertices = {
        -w/2, 0.0, -h/2,  0.0, 1.0, 0.0,  0.0, 0.0,
         w/2, 0.0, -h/2,  0.0, 1.0, 0.0,  1.0, 0.0,
         w/2, 0.0,  h/2,  0.0, 1.0, 0.0,  1.0, 1.0,
        -w/2, 0.0,  h/2,  0.0, 1.0, 0.0,  0.0, 1.0
    }
    
    local indices = {
        0, 1, 2,
        0, 2, 3
    }
    
    return mesh.new(vertices, indices)
end

return plane