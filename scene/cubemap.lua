local gl = require("L3D.core.gl")
local ffi = require("ffi")

local cubemap = {}
cubemap.__index = cubemap

function cubemap.new(faces)
    local id = ffi.new("GLuint[1]")
    gl.glGenTextures(1, id)
    gl.glBindTexture(gl.TEXTURE_CUBE_MAP, id[0])
    
    gl.glPixelStorei(gl.UNPACK_ALIGNMENT, 1)
    
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE)
    
    local faceTargets = {
        gl.TEXTURE_CUBE_MAP_POSITIVE_X,
        gl.TEXTURE_CUBE_MAP_NEGATIVE_X,
        gl.TEXTURE_CUBE_MAP_POSITIVE_Y,
        gl.TEXTURE_CUBE_MAP_NEGATIVE_Y,
        gl.TEXTURE_CUBE_MAP_POSITIVE_Z,
        gl.TEXTURE_CUBE_MAP_NEGATIVE_Z
    }
    
    local defaultColors = {
        {255, 0, 0},
        {0, 255, 0},
        {0, 0, 255},
        {255, 255, 0},
        {255, 0, 255},
        {0, 255, 255}
    }
    
    for i = 1, 6 do
        local r, g, b = 0, 0, 0
        if faces and faces[i] then
            local ok, img = pcall(require, "image")
            if ok and img then
                local data = img.load(faces[i])
                r, g, b = data[1], data[2], data[3]
            end
        else
            r, g, b = unpack(defaultColors[i])
        end
        
        local data = ffi.new("unsigned char[3]", {r, g, b})
        gl.glTexImage2D(faceTargets[i], 0, gl.RGB, 1, 1, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
    end
    
    return setmetatable({id = id[0]}, cubemap)
end

function cubemap.newColor(r, g, b)
    local faces = {}
    for i = 1, 6 do
        faces[i] = {r, g, b}
    end
    
    local id = ffi.new("GLuint[1]")
    gl.glGenTextures(1, id)
    gl.glBindTexture(gl.TEXTURE_CUBE_MAP, id[0])
    
    gl.glPixelStorei(gl.UNPACK_ALIGNMENT, 1)
    
    for i = 1, 6 do
        local data = ffi.new("unsigned char[3]", faces[i])
        gl.glTexImage2D(0x8515 + i - 1, 0, gl.RGB, 1, 1, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
    end
    
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    gl.glTexParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_R, gl.CLAMP_TO_EDGE)
    
    return setmetatable({id = id[0]}, cubemap)
end

function cubemap.newDefault()
    return cubemap.new(nil)
end

function cubemap:bind()
    gl.glBindTexture(gl.TEXTURE_CUBE_MAP, self.id)
end

function cubemap:updateColor(r, g, b)
    local gl = require("L3D.core.gl")
    local ffi = require("ffi")
    gl.glBindTexture(gl.TEXTURE_CUBE_MAP, self.id)
    for i = 0, 5 do
        local data = ffi.new("unsigned char[3]", {r, g, b})
        gl.glTexImage2D(0x8515 + i, 0, gl.RGB, 1, 1, 0, gl.RGB, gl.UNSIGNED_BYTE, data)
    end
end

function cubemap:destroy()
    local gl = require("L3D.core.gl")
    local ffi = require("ffi")
    local id = ffi.new("GLuint[1]", {self.id})
    gl.glDeleteTextures(1, id)
end

return cubemap