local vec3 = require("L3D.math.vec3")
local mat4 = require("L3D.math.mat4")
local renderable = require("L3D.scene.renderable")
local gl = require("L3D.core.gl")
local ffi = require("ffi")

local scene = {}
scene.__index = scene

function scene.new()
    return setmetatable({
        objects = {},
        lights = {},
        skybox = nil,
        camera = nil,
        ambientLight = {color = {0.1, 0.1, 0.1}, intensity = 1.0},
        
        -- Instancing Buffers
        instanceVBO = nil,
        instanceMatrixData = nil,
        maxInstances = 1000
    }, scene)
end

function scene:initInstancing()
    if self.instanceVBO then return end
    self.instanceVBO = ffi.new("GLuint[1]")
    gl.glGenBuffers(1, self.instanceVBO)
    self.instanceMatrixData = ffi.new("float[?]", self.maxInstances * 16)
end

function scene:addObject(renderableObj)
    table.insert(self.objects, renderableObj)
    return renderableObj
end

function scene:addLight(light)
    table.insert(self.lights, light)
    return light
end

function scene:setSkybox(skybox)
    self.skybox = skybox
end

function scene:setCamera(camera)
    self.camera = camera
end

function scene:setAmbientLight(color, intensity)
    self.ambientLight = {color = color, intensity = intensity}
end

function scene:update(dt)
    for _, obj in ipairs(self.objects) do
        if obj.update then
            obj:update(dt)
        end
    end
end

function scene:render(shader)
    if not self.camera then
        return
    end

    local view = self.camera:getViewMatrix()
    local proj = self.camera.projection

    -- Set uniforms that are constant for the whole scene
    shader:setMat4("view", view)
    shader:setMat4("projection", proj)
    -- 1. Group objects by (mesh, material)
    local batches = {}
    local batchOrder = {}
    for _, obj in ipairs(self.objects) do
        local key = tostring(obj.mesh.vao) .. "_" .. tostring(obj.material)
        if not batches[key] then
            batches[key] = {mesh = obj.mesh, mat = obj.material, objs = {}}
            table.insert(batchOrder, key)
        end
        table.insert(batches[key].objs, obj)
    end

    shader:setVec3("viewPos", self.camera.eye.x, self.camera.eye.y, self.camera.eye.z)
    
    -- Lighting
    shader:setInt("numLights", #self.lights + 1)
    shader:setVec3("lights[0].position", 0, 0, 0)
    shader:setInt("lights[0].type", 3)
    shader:setVec3("lights[0].color", self.ambientLight.color[1], self.ambientLight.color[2], self.ambientLight.color[3])
    shader:setFloat("lights[0].intensity", self.ambientLight.intensity)
    for i, light in ipairs(self.lights) do shader:setLight(i, light) end
    
    self:initInstancing()
    local lastVao = nil
    local lastMat = nil

    for _, key in ipairs(batchOrder) do
        local b = batches[key]
        local mesh = b.mesh
        local mat = b.mat
        local objs = b.objs
        local count = #objs

        -- Switch Material if needed
        if mat and mat ~= lastMat then
            shader:setMaterial(mat)
            lastMat = mat
        end

        -- Switch VAO if needed
        if mesh.vao ~= lastVao then
            mesh:bind()
            lastVao = mesh.vao
        end

        if count > 1 then
            -- INSTANCED DRAWING
            shader:setInt("uInstanced", 1)
            
            local n = math.min(count, self.maxInstances)
            for i = 1, n do
                local m = objs[i]:getModelMatrix()
                local offset = (i - 1) * 16
                for j = 1, 16 do
                    self.instanceMatrixData[offset + j - 1] = m[j]
                end
            end
            
            gl.glBindBuffer(gl.ARRAY_BUFFER, self.instanceVBO[0])
            gl.glBufferData(gl.ARRAY_BUFFER, n * 16 * 4, self.instanceMatrixData, gl.STREAM_DRAW)
            
            -- Setup Instanced Attributes (locations 3, 4, 5, 6 for mat4)
            for i = 0, 3 do
                local loc = 3 + i
                gl.glEnableVertexAttribArray(loc)
                gl.glVertexAttribPointer(loc, 4, gl.FLOAT, 0, 16 * 4, ffi.cast("void*", i * 4 * 4))
                gl.glVertexAttribDivisor(loc, 1)
            end
            
            gl.glDrawElementsInstanced(gl.TRIANGLES, mesh.indexCount, gl.UNSIGNED_INT, nil, n)
            
            -- Clean up divisors
            for i = 0, 3 do gl.glVertexAttribDivisor(3 + i, 0) end
            shader:setInt("uInstanced", 0)
        else
            -- SINGLE DRAWING
            shader:setInt("uInstanced", 0)
            local model = objs[1]:getModelMatrix()
            shader:setMat4("model", model)
            shader:setMat3("normalMatrix", objs[1]:getNormalMatrix(model))
            mesh:drawRaw()
        end
    end

    if lastVao then
        gl.glBindVertexArray(0)
    end
end

function scene:renderSkybox()
    if self.skybox and self.camera then
        local view = self.camera:getViewMatrix()
        local proj = self.camera.projection
        self.skybox:draw(view, proj)
    end
end

function scene:clear()
    self.objects = {}
    self.lights = {}
    self.skybox = nil
    self.camera = nil
end

function scene:removeObject(obj)
    for i, o in ipairs(self.objects) do
        if o == obj then
            table.remove(self.objects, i)
            break
        end
    end
end

function scene:removeLight(light)
    for i, l in ipairs(self.lights) do
        if l == light then
            table.remove(self.lights, i)
            break
        end
    end
end

return scene