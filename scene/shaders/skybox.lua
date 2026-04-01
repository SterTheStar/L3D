local gl = require("L3D.core.gl")
local base = require("L3D.scene.shaders.base")

local skybox = setmetatable({}, base)
skybox.__index = skybox

local vs_source = [[
    #version 330 core
    layout (location = 0) in vec3 aPos;
    
    out vec3 TexCoords;
    
    uniform mat4 projection;
    uniform mat4 view;
    
    void main()
    {
        TexCoords = aPos;
        vec4 pos = projection * view * vec4(aPos, 1.0);
        gl_Position = pos.xyww;
    }
]]

local fs_source = [[
    #version 330 core
    out vec4 FragColor;
    
    in vec3 TexCoords;
    
    uniform samplerCube skybox;
    
    void main()
    {
        FragColor = texture(skybox, TexCoords);
    }
]]

function skybox.new()
    local vs = base.compile(vs_source, gl.VERTEX_SHADER)
    local fs = base.compile(fs_source, gl.FRAGMENT_SHADER)
    local id = base.link(vs, fs)
    return setmetatable({id = id, type = "skybox"}, skybox)
end

return skybox
