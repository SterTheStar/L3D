local gl = require("L3D.core.gl")
local ffi = require("ffi")

local mesh = {}
mesh.__index = mesh

function mesh.new(vertices, indices)
    local vao = ffi.new("GLuint[1]")
    local vbo = ffi.new("GLuint[1]")
    local ebo = ffi.new("GLuint[1]")

    gl.glGenVertexArrays(1, vao)
    gl.glGenBuffers(1, vbo)
    gl.glGenBuffers(1, ebo)

    gl.glBindVertexArray(vao[0])

    gl.glBindBuffer(gl.ARRAY_BUFFER, vbo[0])
    local vert_data = ffi.new("float[?]", #vertices, vertices)
    gl.glBufferData(gl.ARRAY_BUFFER, ffi.sizeof(vert_data), vert_data, gl.STATIC_DRAW)

    gl.glBindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo[0])
    local index_data = ffi.new("unsigned int[?]", #indices, indices)
    gl.glBufferData(gl.ELEMENT_ARRAY_BUFFER, ffi.sizeof(index_data), index_data, gl.STATIC_DRAW)

    gl.glVertexAttribPointer(0, 3, gl.FLOAT, 0, 8 * ffi.sizeof("float"), nil)
    gl.glEnableVertexAttribArray(0)
    
    gl.glVertexAttribPointer(1, 3, gl.FLOAT, 0, 8 * ffi.sizeof("float"), ffi.cast("const void*", 3 * ffi.sizeof("float")))
    gl.glEnableVertexAttribArray(1)
    
    gl.glVertexAttribPointer(2, 2, gl.FLOAT, 0, 8 * ffi.sizeof("float"), ffi.cast("const void*", 6 * ffi.sizeof("float")))
    gl.glEnableVertexAttribArray(2)

    gl.glBindBuffer(gl.ARRAY_BUFFER, 0)
    gl.glBindVertexArray(0)

    return setmetatable({
        vao = vao[0],
        vbo = vbo[0],
        ebo = ebo[0],
        indexCount = #indices
    }, mesh)
end

function mesh:bind()
    gl.glBindVertexArray(self.vao)
end

function mesh:unbind()
    gl.glBindVertexArray(0)
end

function mesh:drawRaw()
    gl.glDrawElements(gl.TRIANGLES, self.indexCount, gl.UNSIGNED_INT, nil)
end

function mesh:draw()
    self:bind()
    self:drawRaw()
    self:unbind()
end

return mesh