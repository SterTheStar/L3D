local gl = require("L3D.core.gl")
local base = require("L3D.scene.shaders.base")

local ui = setmetatable({}, base)
ui.__index = ui

local vs_source = [[
    #version 330 core
    layout (location = 0) in vec2 aPos;
    layout (location = 1) in vec2 aTexCoord;
    
    out vec2 TexCoord;
    
    uniform vec2 uPos;
    uniform vec2 uSize;
    uniform vec2 uScreenSize;
    uniform vec2 uUVOffset;
    uniform vec2 uUVSize;
    
    void main()
    {
        vec2 pos = aPos * uSize + uPos;
        vec2 clipPos = (pos / uScreenSize) * 2.0 - 1.0;
        gl_Position = vec4(clipPos.x, -clipPos.y, 0.0, 1.0);
        TexCoord = aTexCoord * uUVSize + uUVOffset;
    }
]]

local fs_source = [[
    #version 330 core
    out vec4 FragColor;
    
    in vec2 TexCoord;
    
    uniform sampler2D uTex;
    uniform vec3 uColor;
    uniform float uAlpha;
    uniform bool uUseTex;
    
    void main()
    {
        if (uUseTex) {
            float val = texture(uTex, TexCoord).r;
            if (val < 0.1) discard;
            FragColor = vec4(uColor, 1.0);
        } else {
            FragColor = vec4(uColor, uAlpha);
        }
    }
]]

function ui.new()
    local vs = base.compile(vs_source, gl.VERTEX_SHADER)
    local fs = base.compile(fs_source, gl.FRAGMENT_SHADER)
    local id = base.link(vs, fs)
    return setmetatable({id = id, type = "ui"}, ui)
end

return ui
