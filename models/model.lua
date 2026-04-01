local mesh = require("L3D.scene.mesh")

local model = {}
model.__index = model

function model.new(path)
    local vertices = {}
    local indices = {}
    
    local file = io.open(path, "r")
    if not file then
        print("ERROR::MODEL::FILE_NOT_FOUND: " .. path)
        return nil
    end
    
    local positions = {}
    local normals = {}
    local texCoords = {}
    
    for line in file:lines() do
        local parts = {}
        for part in string.gmatch(line, "%S+") do
            table.insert(parts, part)
        end
        
        if #parts > 0 then
            if parts[1] == "v" then
                table.insert(positions, tonumber(parts[2]))
                table.insert(positions, tonumber(parts[3]))
                table.insert(positions, tonumber(parts[4]))
            elseif parts[1] == "vn" then
                table.insert(normals, tonumber(parts[2]))
                table.insert(normals, tonumber(parts[3]))
                table.insert(normals, tonumber(parts[4]))
            elseif parts[1] == "vt" then
                table.insert(texCoords, tonumber(parts[2]))
                table.insert(texCoords, tonumber(parts[3]))
            elseif parts[1] == "f" then
                local face = {}
                for i = 2, #parts do
                    local vert = {}
                    for num in string.gmatch(parts[i], "%d+") do
                        table.insert(vert, tonumber(num))
                    end
                    table.insert(face, vert)
                end
                
                if #face == 3 then
                    for _, v in ipairs(face) do
                        local posIdx = (v[1] - 1) * 3 + 1
                        local vert = {
                            positions[posIdx], positions[posIdx+1], positions[posIdx+2]
                        }
                        
                        if v[2] and texCoords[(v[2]-1)*2+1] then
                            table.insert(vert, texCoords[(v[2]-1)*2+1])
                            table.insert(vert, texCoords[(v[2]-1)*2+2])
                        else
                            table.insert(vert, 0.0)
                            table.insert(vert, 0.0)
                        end
                        
                        if v[3] and normals[(v[3]-1)*3+1] then
                            table.insert(vert, normals[(v[3]-1)*3+1])
                            table.insert(vert, normals[(v[3]-1)*3+2])
                            table.insert(vert, normals[(v[3]-1)*3+3])
                        else
                            table.insert(vert, 0.0)
                            table.insert(vert, 1.0)
                            table.insert(vert, 0.0)
                        end
                        
                        local existing = -1
                        for i = 1, #vertices, 8 do
                            local match = true
                            for j = 1, 8 do
                                if math.abs(vertices[i+j-1] - vert[j]) > 0.0001 then
                                    match = false
                                    break
                                end
                            end
                            if match then
                                existing = (i - 1) / 8
                                break
                            end
                        end
                        
                        if existing >= 0 then
                            table.insert(indices, existing)
                        else
                            for _, val in ipairs(vert) do
                                table.insert(vertices, val)
                            end
                            table.insert(indices, (#vertices / 8) - 1)
                        end
                    end
                elseif #face == 4 then
                    local v1, v2, v3, v4 = face[1], face[2], face[3], face[4]
                    local face1 = {v1, v2, v3}
                    local face2 = {v1, v3, v4}
                    
                    for _, f in ipairs({face1, face2}) do
                        for _, v in ipairs(f) do
                            local posIdx = (v[1] - 1) * 3 + 1
                            local vert = {
                                positions[posIdx], positions[posIdx+1], positions[posIdx+2]
                            }
                            
                            if v[2] and texCoords[(v[2]-1)*2+1] then
                                table.insert(vert, texCoords[(v[2]-1)*2+1])
                                table.insert(vert, texCoords[(v[2]-1)*2+2])
                            else
                                table.insert(vert, 0.0)
                                table.insert(vert, 0.0)
                            end
                            
                            if v[3] and normals[(v[3]-1)*3+1] then
                                table.insert(vert, normals[(v[3]-1)*3+1])
                                table.insert(vert, normals[(v[3]-1)*3+2])
                                table.insert(vert, normals[(v[3]-1)*3+3])
                            else
                                table.insert(vert, 0.0)
                                table.insert(vert, 1.0)
                                table.insert(vert, 0.0)
                            end
                            
                            local existing = -1
                            for i = 1, #vertices, 8 do
                                local match = true
                                for j = 1, 8 do
                                    if math.abs(vertices[i+j-1] - vert[j]) > 0.0001 then
                                        match = false
                                        break
                                    end
                                end
                                if match then
                                    existing = (i - 1) / 8
                                    break
                                end
                            end
                            
                            if existing >= 0 then
                                table.insert(indices, existing)
                            else
                                for _, val in ipairs(vert) do
                                    table.insert(vertices, val)
                                end
                                table.insert(indices, (#vertices / 8) - 1)
                            end
                        end
                    end
                end
            end
        end
    end
    
    file:close()
    
    if #vertices == 0 then
        return nil
    end
    
    return setmetatable({
        mesh = mesh.new(vertices, indices)
    }, model)
end

function model:draw()
    self.mesh:draw()
end

return model