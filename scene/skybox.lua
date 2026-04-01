local gl = require("L3D.core.gl")
local ffi = require("ffi")
local mat4 = require("L3D.math.mat4")
local shader = require("L3D.scene.shader")

local skybox = {}
skybox.__index = skybox

local skyboxVertices = {
    -1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
    -1.0,  1.0,  1.0,
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0
}

local skyboxIndices = {
    0, 1, 2, 0, 2, 3,
    4, 5, 6, 4, 6, 7,
    0, 1, 5, 0, 5, 4,
    2, 3, 7, 2, 7, 6,
    0, 3, 7, 0, 7, 4,
    1, 2, 6, 1, 6, 5
}

function skybox.new(cubemap)
    local vao = ffi.new("GLuint[1]")
    local vbo = ffi.new("GLuint[1]")
    local ebo = ffi.new("GLuint[1]")

    gl.glGenVertexArrays(1, vao)
    gl.glGenBuffers(1, vbo)
    gl.glGenBuffers(1, ebo)

    gl.glBindVertexArray(vao[0])

    local vert_data = ffi.new("float[?]", #skyboxVertices, skyboxVertices)
    gl.glBindBuffer(gl.ARRAY_BUFFER, vbo[0])
    gl.glBufferData(gl.ARRAY_BUFFER, ffi.sizeof(vert_data), vert_data, gl.STATIC_DRAW)

    local index_data = ffi.new("unsigned int[?]", #skyboxIndices, skyboxIndices)
    gl.glBindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo[0])
    gl.glBufferData(gl.ELEMENT_ARRAY_BUFFER, ffi.sizeof(index_data), index_data, gl.STATIC_DRAW)

    gl.glVertexAttribPointer(0, 3, gl.FLOAT, 0, 3 * ffi.sizeof("float"), nil)
    gl.glEnableVertexAttribArray(0)

    gl.glBindBuffer(gl.ARRAY_BUFFER, 0)
    gl.glBindVertexArray(0)

    return setmetatable({
        vao = vao[0],
        vbo = vbo[0],
        ebo = ebo[0],
        indexCount = #skyboxIndices,
        cubemap = cubemap,
        shader = shader.newSkybox()
    }, skybox)
end

function skybox:draw(view, projection)
    gl.glDepthFunc(gl.LEQUAL)
    gl.glDepthMask(0)
    gl.glDisable(gl.CULL_FACE)
    
    self.shader:use()
    
    local viewWithoutTranslation = {}
    for i = 1, 16 do
        viewWithoutTranslation[i] = view[i]
    end
    viewWithoutTranslation[13] = 0
    viewWithoutTranslation[14] = 0
    viewWithoutTranslation[15] = 0
    
    self.shader:setMat4("view", viewWithoutTranslation)
    self.shader:setMat4("projection", projection)
    
    gl.glActiveTexture(0x84C0) -- TEXTURE0
    self.cubemap:bind()
    self.shader:setInt("skybox", 0)
    
    gl.glBindVertexArray(self.vao)
    gl.glDrawElements(gl.TRIANGLES, self.indexCount, gl.UNSIGNED_INT, nil)
    gl.glBindVertexArray(0)
    
    gl.glDepthMask(1)
    gl.glDepthFunc(0x0201) -- GL_LESS
    gl.glEnable(gl.CULL_FACE)
end

return skybox