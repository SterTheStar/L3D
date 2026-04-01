local gl = require("L3D.core.gl")
local base = require("L3D.scene.shaders.base")

local lighting = setmetatable({}, base)
lighting.__index = lighting

local vs_source = [[
    #version 330 core
    layout (location = 0) in vec3 aPos;
    layout (location = 1) in vec3 aNormal;
    layout (location = 2) in vec2 aTexCoords;
    layout (location = 3) in mat4 aInstanceModel;
    
    out vec3 FragPos;
    out vec3 Normal;
    out vec2 TexCoords;
    
    uniform bool uInstanced;
    uniform mat4 model;
    uniform mat4 view;
    uniform mat4 projection;
    uniform mat3 normalMatrix;
    
    void main()
    {
        mat4 finalModel = uInstanced ? aInstanceModel : model;
        
        // Simplified Normal Matrix for instancing (assumes uniform scaling)
        mat3 finalNormal = uInstanced ? mat3(finalModel) : normalMatrix;
        
        FragPos = vec3(finalModel * vec4(aPos, 1.0));
        Normal = finalNormal * aNormal;
        TexCoords = aTexCoords;
        gl_Position = projection * view * vec4(FragPos, 1.0);
    }
]]

local fs_source = [[
    #version 330 core
    out vec4 FragColor;
    
    in vec3 FragPos;
    in vec3 Normal;
    in vec2 TexCoords;
    
    struct Material {
        vec3 ambient;
        vec3 diffuse;
        vec3 specular;
        float shininess;
    };
    
    struct Light {
        int type;
        vec3 position;
        vec3 direction;
        vec3 color;
        float intensity;
        
        float constant;
        float linear;
        float quadratic;
        
        float cutOff;
        float outerCutOff;
    };
    
    uniform Material material;
    uniform Light lights[16];
    uniform int numLights;
    uniform vec3 viewPos;
    uniform sampler2D texture_diffuse1;
    uniform bool useTexture;
    
    vec3 CalcDirLight(Light light, vec3 normal, vec3 viewDir);
    vec3 CalcPointLight(Light light, vec3 normal, vec3 fragPos, vec3 viewDir);
    vec3 CalcSpotLight(Light light, vec3 normal, vec3 fragPos, vec3 viewDir);
    
    void main()
    {
        vec3 norm = normalize(Normal);
        vec3 viewDir = normalize(viewPos - FragPos);
        
        vec3 result = vec3(0.0);
        
        for(int i = 0; i < numLights; i++) {
            if(lights[i].type == 0) {
                result += CalcDirLight(lights[i], norm, viewDir);
            } else if(lights[i].type == 1) {
                result += CalcPointLight(lights[i], norm, FragPos, viewDir);
            } else if(lights[i].type == 2) {
                result += CalcSpotLight(lights[i], norm, FragPos, viewDir);
            }
        }
        
        FragColor = vec4(result, 1.0);
    }
    
    vec3 CalcDirLight(Light light, vec3 normal, vec3 viewDir)
    {
        vec3 lightDir = normalize(-light.direction);
        
        float diff = max(dot(normal, lightDir), 0.0);
        
        vec3 reflectDir = reflect(-lightDir, normal);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
        
        vec3 ambient = material.ambient * light.color * light.intensity;
        vec3 diffuse = material.diffuse * diff * light.color * light.intensity;
        vec3 specular = material.specular * spec * light.color * light.intensity;
        
        return ambient + diffuse + specular;
    }
    
    vec3 CalcPointLight(Light light, vec3 normal, vec3 fragPos, vec3 viewDir)
    {
        vec3 lightDir = normalize(light.position - fragPos);
        
        float diff = max(dot(normal, lightDir), 0.0);
        
        vec3 reflectDir = reflect(-lightDir, normal);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
        
        float distance = length(light.position - fragPos);
        float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * distance * distance);
        
        vec3 ambient = material.ambient * light.color * light.intensity;
        vec3 diffuse = material.diffuse * diff * light.color * light.intensity;
        vec3 specular = material.specular * spec * light.color * light.intensity;
        
        ambient *= attenuation;
        diffuse *= attenuation;
        specular *= attenuation;
        
        return ambient + diffuse + specular;
    }
    
    vec3 CalcSpotLight(Light light, vec3 normal, vec3 fragPos, vec3 viewDir)
    {
        vec3 lightDir = normalize(light.position - fragPos);
        
        float diff = max(dot(normal, lightDir), 0.0);
        
        vec3 reflectDir = reflect(-lightDir, normal);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
        
        float distance = length(light.position - fragPos);
        float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * distance * distance);
        
        float theta = dot(lightDir, normalize(-light.direction));
        float epsilon = light.cutOff - light.outerCutOff;
        float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);
        
        vec3 ambient = material.ambient * light.color * light.intensity;
        vec3 diffuse = material.diffuse * diff * light.color * light.intensity;
        vec3 specular = material.specular * spec * light.color * light.intensity;
        
        ambient *= attenuation;
        diffuse *= attenuation;
        specular *= attenuation;
        
        diffuse *= intensity;
        specular *= intensity;
        
        return ambient + diffuse + specular;
    }
]]

function lighting.new()
    local vs = base.compile(vs_source, gl.VERTEX_SHADER)
    local fs = base.compile(fs_source, gl.FRAGMENT_SHADER)
    local id = base.link(vs, fs)
    local self = setmetatable({id = id, type = "lighting"}, lighting)
    
    -- Cache light names to avoid string.format in hot loop
    self.uLights = {}
    for i = 0, 15 do
        local p = "lights[" .. i .. "]."
        self.uLights[i] = {
            type = p .. "type",
            pos = p .. "position",
            dir = p .. "direction",
            color = p .. "color",
            intensity = p .. "intensity",
            constant = p .. "constant",
            linear = p .. "linear",
            quad = p .. "quadratic",
            cut = p .. "cutOff",
            outer = p .. "outerCutOff"
        }
    end
    return self
end

function lighting:setMaterial(material)
    self:setVec3("material.ambient", material.ambient.x, material.ambient.y, material.ambient.z)
    self:setVec3("material.diffuse", material.diffuse.x, material.diffuse.y, material.diffuse.z)
    self:setVec3("material.specular", material.specular.x, material.specular.y, material.specular.z)
    self:setFloat("material.shininess", material.shininess)
end

function lighting:setLight(index, light)
    local u = self.uLights[index]
    if not u then return end
    
    local typeMap = {directional = 0, point = 1, spot = 2}
    self:setInt(u.type, typeMap[light.type] or 0)
    
    local p = light.position or {x=0, y=0, z=0}
    local d = light.direction or {x=0, y=0, z=0}
    self:setVec3(u.pos, p.x, p.y, p.z)
    self:setVec3(u.dir, d.x, d.y, d.z)
    
    self:setVec3(u.color, light.color[1], light.color[2], light.color[3])
    self:setFloat(u.intensity, light.intensity or 1.0)
    self:setFloat(u.constant, light.constant or 1.0)
    self:setFloat(u.linear, light.linear or 0.09)
    self:setFloat(u.quad, light.quadratic or 0.032)
    self:setFloat(u.cut, light.cutOff or 0.0)
    self:setFloat(u.outer, light.outerCutOff or 0.0)
end

return lighting
