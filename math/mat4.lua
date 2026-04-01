local mat4 = {}
mat4.__index = mat4

function mat4.identity()
    return setmetatable({
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    }, mat4)
end

function mat4.transpose(m)
    return setmetatable({
        m[1], m[5], m[9], m[13],
        m[2], m[6], m[10], m[14],
        m[3], m[7], m[11], m[15],
        m[4], m[8], m[12], m[16]
    }, mat4)
end

function mat4.__mul(a, b)
    local res = {}
    for i = 0, 3 do
        for j = 0, 3 do
            local sum = 0
            for k = 0, 3 do
                sum = sum + a[i * 4 + k + 1] * b[k * 4 + j + 1]
            end
            res[i * 4 + j + 1] = sum
        end
    end
    return setmetatable(res, mat4)
end

function mat4.translate(x, y, z)
    local m = mat4.identity()
    m[13], m[14], m[15] = x, y, z
    return m
end

function mat4.scale(sx, sy, sz)
    local m = mat4.identity()
    m[1], m[6], m[11] = sx, sy, sz
    return m
end

function mat4.rotate(angle, x, y, z)
    local m = mat4.identity()
    local c, s = math.cos(angle), math.sin(angle)
    local t = 1 - c
    local len = math.sqrt(x*x + y*y + z*z)
    x, y, z = x/len, y/len, z/len

    m[1] = t*x*x + c
    m[2] = t*x*y + s*z
    m[3] = t*x*z - s*y
    m[5] = t*x*y - s*z
    m[6] = t*y*y + c
    m[7] = t*y*z + s*x
    m[9] = t*x*z + s*y
    m[10] = t*y*z - s*x
    m[11] = t*z*z + c
    return m
end

function mat4.perspective(fovy, aspect, near, far)
    local m = mat4.identity()
    local f = 1.0 / math.tan(fovy / 2.0)
    m[1] = f / aspect
    m[6] = f
    m[11] = (far + near) / (near - far)
    m[12] = -1
    m[15] = (2 * far * near) / (near - far)
    m[16] = 0
    return m
end

function mat4.lookAt(eye, center, up)
    local f = center:sub(eye):normalize()
    local s = f:cross(up):normalize()
    local u = s:cross(f)

    local m = mat4.identity()
    m[1], m[5], m[9]  = s.x, s.y, s.z
    m[2], m[6], m[10] = u.x, u.y, u.z
    m[3], m[7], m[11] = -f.x, -f.y, -f.z
    m[13] = -s:dot(eye)
    m[14] = -u:dot(eye)
    m[15] = f:dot(eye)
    return m
end

return mat4
