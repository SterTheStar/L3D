local gl = require("L3D.core.gl")
local base = require("L3D.scene.shaders.base")
local lighting = require("L3D.scene.shaders.lighting")
local skybox = require("L3D.scene.shaders.skybox")
local ui = require("L3D.scene.shaders.ui")

local shader = setmetatable({}, base)
shader.__index = shader

function shader.newLighting()
    return lighting.new()
end

function shader.newSkybox()
    return skybox.new()
end

function shader.newUI()
    return ui.new()
end

function shader.new(vertex_source, fragment_source)
    if not vertex_source or not fragment_source then
        print("Use shader.newLighting() or shader.newSkybox() for built-in shaders")
        return nil
    end
    
    local vs = base.compile(vertex_source, gl.VERTEX_SHADER)
    local fs = base.compile(fragment_source, gl.FRAGMENT_SHADER)
    local id = base.link(vs, fs)
    
    return setmetatable({id = id, type = "basic"}, shader)
end

return shader