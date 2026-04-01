local mat4 = require("L3D.math.mat4")
local vec3 = require("L3D.math.vec3")

local camera = {}
camera.__index = camera

function camera.new(eye, yaw, pitch, fov, aspect, near, far)
    local cam = {
        eye = eye or vec3.new(0, 0, 3),
        yaw = yaw or -90,
        pitch = pitch or 0,
        fov = fov or math.rad(45),
        aspect = aspect or 1.0,
        near = near or 0.1,
        far = far or 100.0,
        up = vec3.new(0, 1, 0),
        front = vec3.new(0, 0, -1),
        right = vec3.new(1, 0, 0)
    }
    setmetatable(cam, camera)
    cam.projection = mat4.perspective(cam.fov, cam.aspect, cam.near, cam.far)
    cam:updateVectors()
    return cam
end

function camera:updateVectors()
    local front = vec3.new(
        math.cos(math.rad(self.yaw)) * math.cos(math.rad(self.pitch)),
        math.sin(math.rad(self.pitch)),
        math.sin(math.rad(self.yaw)) * math.cos(math.rad(self.pitch))
    )
    self.front = front:normalize()
    self.right = self.front:cross(vec3.new(0, 1, 0)):normalize()
    self.up = self.right:cross(self.front):normalize()
end

function camera:getViewMatrix()
    return mat4.lookAt(self.eye, self.eye:add(self.front), self.up)
end

function camera:setProjection(fov, aspect, near, far)
    self.fov = fov or self.fov
    self.aspect = aspect or self.aspect
    self.near = near or self.near
    self.far = far or self.far
    self.projection = mat4.perspective(self.fov, self.aspect, self.near, self.far)
end

function camera:setAspect(aspect)
    self.aspect = aspect
    self.projection = mat4.perspective(self.fov, self.aspect, self.near, self.far)
end

function camera:moveForward(amount)
    self.eye = self.eye:add(self.front:mul(amount))
end

function camera:moveRight(amount)
    self.eye = self.eye:add(self.right:mul(amount))
end

function camera:moveUp(amount)
    self.eye = self.eye:add(vec3.new(0, 1, 0):mul(amount))
end

function camera:rotate(yawOffset, pitchOffset)
    self.yaw = self.yaw + yawOffset
    self.pitch = self.pitch + pitchOffset

    if self.pitch > 89 then self.pitch = 89 end
    if self.pitch < -89 then self.pitch = -89 end

    self:updateVectors()
end

function camera:getFrustum()
    local vp = self.projection * self:getViewMatrix()
    local planes = {}
    
    -- In Row-Major (v' = M * v):
    -- Row 1: 1 2 3 4
    -- Row 2: 5 6 7 8
    -- Row 3: 9 10 11 12
    -- Row 4: 13 14 15 16
    
    planes[1] = {x = vp[13]+vp[1], y = vp[14]+vp[2], z = vp[15]+vp[3], w = vp[16]+vp[4]} -- Left
    planes[2] = {x = vp[13]-vp[1], y = vp[14]-vp[2], z = vp[15]-vp[3], w = vp[16]-vp[4]} -- Right
    planes[3] = {x = vp[13]+vp[5], y = vp[14]+vp[6], z = vp[15]+vp[7], w = vp[16]+vp[8]} -- Bottom
    planes[4] = {x = vp[13]-vp[5], y = vp[14]-vp[6], z = vp[15]-vp[7], w = vp[16]-vp[8]} -- Top
    planes[5] = {x = vp[13]+vp[9], y = vp[14]+vp[10], z = vp[15]+vp[11], w = vp[16]+vp[12]} -- Near
    planes[6] = {x = vp[13]-vp[9], y = vp[14]-vp[10], z = vp[15]-vp[11], w = vp[16]-vp[12]} -- Far
    
    for i=1, 6 do
        local p = planes[i]
        local len = math.sqrt(p.x*p.x + p.y*p.y + p.z*p.z)
        p.x, p.y, p.z, p.w = p.x/len, p.y/len, p.z/len, p.w/len
    end
    return planes
end

function camera:isSphereInFrustum(planes, pos, radius)
    for i=1, 6 do
        local p = planes[i]
        if (p.x * pos.x + p.y * pos.y + p.z * pos.z + p.w) <= -radius then
            return false
        end
    end
    return true
end

return camera
