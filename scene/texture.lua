local gl = require("L3D.core.gl")
local ffi = require("ffi")

local texture = {}
texture.__index = texture

function texture.new(path, type)
    local id = ffi.new("GLuint[1]")
    gl.glGenTextures(1, id)
    
    gl.glBindTexture(gl.TEXTURE_2D, id[0])
    
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, 0x812F)
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, 0x812F)
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, 0x2601)
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, 0x2601)
    
    local width = ffi.new("int[1]")
    local height = ffi.new("int[1]")
    local channels = ffi.new("int[1]")
    
    local data = love.image.newImageData(path)
    
    gl.glTexImage2D(gl.TEXTURE_2D, 0, 0x1908, data:getWidth(), data:getHeight(), 0, 0x1908, 0x1401, nil)
    
    gl.glGenerateMipmap(gl.TEXTURE_2D)
    
    return setmetatable({
        id = id[0],
        type = type or "diffuse",
        path = path
    }, texture)
end

function texture.newFromImageData(imageData, type)
    local id = ffi.new("GLuint[1]")
    gl.glGenTextures(1, id)
    
    gl.glBindTexture(gl.TEXTURE_2D, id[0])
    
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, 0x812F)
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, 0x812F)
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, 0x2601)
    gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, 0x2601)
    
    local width = imageData:getWidth()
    local height = imageData:getHeight()
    
    local rawData = imageData:getString()
    local dataPtr = ffi.new("unsigned char[?]", #rawData)
    for i = 0, #rawData - 1 do
        dataPtr[i] = string.byte(rawData, i + 1)
    end
    
    gl.glTexImage2D(gl.TEXTURE_2D, 0, 0x1908, width, height, 0, 0x1908, 0x1401, dataPtr)
    gl.glGenerateMipmap(gl.TEXTURE_2D)
    
    return setmetatable({
        id = id[0],
        type = type or "diffuse"
    }, texture)
end

function texture.newColor(r, g, b, type)
    local id = ffi.new("GLuint[1]")
    gl.glGenTextures(1, id)
    
    gl.glBindTexture(gl.TEXTURE_2D, id[0])
    
    local data = ffi.new("unsigned char[3]", {r, g, b})
    gl.glTexImage2D(gl.TEXTURE_2D, 0, 0x1908, 1, 1, 0, 0x1908, 0x1401, data)
    
    return setmetatable({
        id = id[0],
        type = type or "diffuse"
    }, texture)
end

function texture:bind(slot)
    gl.glActiveTexture(0x84C0 + (slot or 0))
    gl.glBindTexture(gl.TEXTURE_2D, self.id)
end

return texture