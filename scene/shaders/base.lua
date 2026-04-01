local gl = require("L3D.core.gl")
local ffi = require("ffi")

local base = {}
base.__index = base

function base.compile(source, type)
    local id = gl.glCreateShader(type)
    local src_ptr = ffi.new("const char*[1]", {source})
    local len = ffi.new("int[1]", {#source})
    gl.glShaderSource(id, 1, src_ptr, len)
    gl.glCompileShader(id)

    local success = ffi.new("GLint[1]")
    gl.glGetShaderiv(id, 0x8B81, success)
    if success[0] ~= 1 then
        local infoLog = ffi.new("char[512]")
        local logLen = ffi.new("GLsizei[1]")
        gl.glGetShaderInfoLog(id, 512, logLen, infoLog)
        if logLen[0] > 0 then
            print("WARNING::SHADER::COMPILATION_FAILED: " .. ffi.string(infoLog))
        end
    end
    return id
end

function base.link(vs, fs)
    local id = gl.glCreateProgram()
    gl.glAttachShader(id, vs)
    gl.glAttachShader(id, fs)
    gl.glLinkProgram(id)

    local success = ffi.new("GLint[1]")
    gl.glGetProgramiv(id, 0x8B82, success)
    if success[0] == 0 then
        local infoLog = ffi.new("char[512]")
        gl.glGetProgramInfoLog(id, 512, nil, infoLog)
        print("ERROR::SHADER::LINKING_FAILED\n", ffi.string(infoLog))
    end

    gl.glDeleteShader(vs)
    gl.glDeleteShader(fs)
    
    return id
end

function base:use()
    gl.glUseProgram(self.id)
end

function base:getLoc(name)
    if not self.locations then self.locations = {} end
    local loc = self.locations[name]
    if loc == nil then
        loc = gl.glGetUniformLocation(self.id, name)
        self.locations[name] = loc
    end
    return loc
end

function base:setMat4(name, mat)
    local loc = self:getLoc(name)
    if loc == -1 then return end
    if not self._mat4buff then self._mat4buff = ffi.new("float[16]") end
    for i=1,16 do self._mat4buff[i-1] = mat[i] end
    gl.glUniformMatrix4fv(loc, 1, 0, self._mat4buff)
end

function base:setMat3(name, mat)
    local loc = self:getLoc(name)
    if loc == -1 then return end
    if not self._mat3buff then self._mat3buff = ffi.new("float[9]") end
    for i=1,9 do self._mat3buff[i-1] = mat[i] end
    gl.glUniformMatrix3fv(loc, 1, 0, self._mat3buff)
end

function base:setVec3(name, x, y, z)
    local loc = self:getLoc(name)
    if loc ~= -1 then
        gl.glUniform3f(loc, x, y, z)
    end
end

function base:setVec2(name, x, y)
    local loc = self:getLoc(name)
    if loc ~= -1 then
        gl.glUniform2f(loc, x, y)
    end
end

function base:setFloat(name, value)
    local loc = self:getLoc(name)
    if loc ~= -1 then
        gl.glUniform1f(loc, value)
    end
end

function base:setInt(name, value)
    local loc = self:getLoc(name)
    if loc ~= -1 then
        gl.glUniform1i(loc, value)
    end
end

return base
