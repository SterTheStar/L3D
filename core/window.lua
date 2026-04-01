local ffi = require("ffi")

ffi.cdef[[
    typedef struct GLFWwindow GLFWwindow;
    typedef void (*GLFWerrorfun)(int, const char*);
    typedef void (*GLFWkeyfun)(GLFWwindow*, int, int, int, int);
    typedef void (*GLFWcursorposfun)(GLFWwindow*, double, double);
    typedef void (*GLFWmousebuttonfun)(GLFWwindow*, int, int, int);
    typedef void (*GLFWscrollfun)(GLFWwindow*, double, double);
    typedef void (*GLFWwindowsizefun)(GLFWwindow*, int, int);
    typedef void (*GLFWframebuffersizefun)(GLFWwindow*, int, int);

    int glfwInit(void);
    void glfwTerminate(void);
    GLFWwindow* glfwCreateWindow(int width, int height, const char* title, void* monitor, void* share);
    void glfwMakeContextCurrent(GLFWwindow* window);
    int glfwWindowShouldClose(GLFWwindow* window);
    void glfwPollEvents(void);
    void glfwSwapBuffers(GLFWwindow* window);
    void glfwWindowHint(int hint, int value);
    void glfwGetFramebufferSize(GLFWwindow* window, int* width, int* height);
    
    void glfwSetWindowSize(GLFWwindow* window, int width, int height);
    void glfwSwapInterval(int interval);
    void glfwGetWindowSize(GLFWwindow* window, int* width, int* height);
    
    GLFWkeyfun glfwSetKeyCallback(GLFWwindow* window, GLFWkeyfun callback);
    GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow* window, GLFWcursorposfun callback);
    GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* window, GLFWmousebuttonfun callback);
    GLFWscrollfun glfwSetScrollCallback(GLFWwindow* window, GLFWscrollfun callback);
    GLFWframebuffersizefun glfwSetFramebufferSizeCallback(GLFWwindow* window, GLFWframebuffersizefun callback);
    
    int glfwGetKey(GLFWwindow* window, int key);
    int glfwGetMouseButton(GLFWwindow* window, int button);
    void glfwGetCursorPos(GLFWwindow* window, double* xpos, double* ypos);
    void glfwSetInputMode(GLFWwindow* window, int mode, int value);
    void glfwSetWindowShouldClose(GLFWwindow* window, int value);
    double glfwGetTime(void);
]]

local libglfw = ffi.load("glfw")
local glfw = setmetatable({}, {
    __index = libglfw
})

glfw.CONTEXT_VERSION_MAJOR = 0x00022002
glfw.CONTEXT_VERSION_MINOR = 0x00022003
glfw.PROFILE = 0x00022008
glfw.OPENGL_CORE_PROFILE = 0x00032001

glfw.CURSOR = 0x00033001
glfw.CURSOR_NORMAL = 0x00034001
glfw.CURSOR_HIDDEN = 0x00034002
glfw.CURSOR_DISABLED = 0x00034003

local window = {}
window.__index = window

local keyPressed = {}
local keyReleased = {}
local mousePressed = {}
local mouseReleased = {}
local mouseX, mouseY = 0, 0
local deltaX, deltaY = 0, 0
local firstMouse = true

local function keyCallback(windowPtr, key, scancode, action, mods)
    if action == 1 then -- GLFW_PRESS
        keyPressed[key] = true
    elseif action == 0 then -- GLFW_RELEASE
        keyReleased[key] = true
    end
end

local function mouseButtonCallback(windowPtr, button, action, mods)
    if action == 1 then -- GLFW_PRESS
        mousePressed[button] = true
    elseif action == 0 then -- GLFW_RELEASE
        mouseReleased[button] = true
    end
end

local function cursorPosCallback(windowPtr, x, y)
    if firstMouse then
        mouseX, mouseY = x, y
        firstMouse = false
    end
    deltaX = x - mouseX
    deltaY = y - mouseY
    mouseX, mouseY = x, y
end

local windows = {}

local function framebufferSizeCallback(windowPtr, width, height)
    local self = windows[tostring(windowPtr)]
    if self then
        self.width = width
        self.height = height
        self.resized = true
    end
end

function window.new(width, height, title)
    if glfw.glfwInit() == 0 then return nil end

    glfw.glfwWindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.glfwWindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.glfwWindowHint(glfw.PROFILE, glfw.OPENGL_CORE_PROFILE)

    local ptr = glfw.glfwCreateWindow(width, height, title, nil, nil)
    if ptr == nil then
        glfw.glfwTerminate()
        return nil
    end

    glfw.glfwMakeContextCurrent(ptr)
    
    local obj = {
        ptr = ptr,
        width = width,
        height = height,
        resized = false,
        fpsVisible = false,
        lastFpsUpdate = glfw.glfwGetTime(),
        frameCount = 0,
        currentFps = 0,
        fpsLimit = 0,
        lastFrameTime = glfw.glfwGetTime(),
        deltaTime = 0,
        startTime = glfw.glfwGetTime()
    }
    setmetatable(obj, window)
    
    windows[tostring(ptr)] = obj
    
    glfw.glfwSetKeyCallback(ptr, keyCallback)
    glfw.glfwSetMouseButtonCallback(ptr, mouseButtonCallback)
    glfw.glfwSetCursorPosCallback(ptr, cursorPosCallback)
    glfw.glfwSetFramebufferSizeCallback(ptr, framebufferSizeCallback)

    return obj
end

function window:shouldClose()
    return glfw.glfwWindowShouldClose(self.ptr) == 1
end

function window:update()
    local startTime = glfw.glfwGetTime()
    
    if self.fpsLimit > 0 then
        local targetFrameTime = 1.0 / self.fpsLimit
        while glfw.glfwGetTime() - self.lastFrameTime < targetFrameTime do
            -- busy wait (ideally should use a sleep function here)
        end
    end
    
    local currentTime = glfw.glfwGetTime()
    self.deltaTime = currentTime - self.lastFrameTime
    self.lastFrameTime = currentTime

    self.frameCount = self.frameCount + 1
    if currentTime - self.lastFpsUpdate >= 1.0 then
        self.currentFps = self.frameCount
        self.frameCount = 0
        self.lastFpsUpdate = currentTime
    end

    if self.fpsVisible then
        self:drawFps()
    end

    keyPressed = {}
    keyReleased = {}
    mousePressed = {}
    mouseReleased = {}
    deltaX = 0
    deltaY = 0
    
    glfw.glfwPollEvents()
    glfw.glfwSwapBuffers(self.ptr)
end

function window:initHud()
    if not self.gl_api then
        self.gl_api = require("L3D.core.gl")
    end
    if not self.uiShader then
        local font = require("L3D.utils.font")
        local shader = require("L3D.scene.shader")
        
        self.uiShader = shader.newUI()
        self.fontData = font.createTexture()
        
        local vertices = ffi.new("float[16]", {
            0, 0, 0, 1, -- TL
            1, 0, 1, 1, -- TR
            1, 1, 1, 0, -- BR
            0, 1, 0, 0  -- BL
        })
        local indices = ffi.new("unsigned int[6]", {0, 1, 2, 0, 2, 3})
        
        self.hudVao = ffi.new("GLuint[1]")
        local vbo = ffi.new("GLuint[1]")
        local ebo = ffi.new("GLuint[1]")
        self.gl_api.glGenVertexArrays(1, self.hudVao)
        self.gl_api.glGenBuffers(1, vbo)
        self.gl_api.glGenBuffers(1, ebo)
        
        self.gl_api.glBindVertexArray(self.hudVao[0])
        self.gl_api.glBindBuffer(self.gl_api.ARRAY_BUFFER, vbo[0])
        self.gl_api.glBufferData(self.gl_api.ARRAY_BUFFER, ffi.sizeof(vertices), vertices, self.gl_api.STATIC_DRAW)
        self.gl_api.glBindBuffer(self.gl_api.ELEMENT_ARRAY_BUFFER, ebo[0])
        self.gl_api.glBufferData(self.gl_api.ELEMENT_ARRAY_BUFFER, ffi.sizeof(indices), indices, self.gl_api.STATIC_DRAW)
        
        self.gl_api.glVertexAttribPointer(0, 2, self.gl_api.FLOAT, 0, 4 * 4, nil)
        self.gl_api.glEnableVertexAttribArray(0)
        self.gl_api.glVertexAttribPointer(1, 2, self.gl_api.FLOAT, 0, 4 * 4, ffi.cast("void*", 2 * 4))
        self.gl_api.glEnableVertexAttribArray(1)
    end
end

function window:drawText(text, x, y, scale, r, g, b)
    self:initHud()
    local gl_api = self.gl_api
    
    scale = scale or 1.0
    r, g, b = r or 1.0, g or 1.0, b or 1.0
    
    gl_api.glDisable(gl_api.DEPTH_TEST)
    gl_api.glDisable(gl_api.CULL_FACE)
    gl_api.glDepthMask(0)
    gl_api.glEnable(gl_api.BLEND)
    gl_api.glBlendFunc(gl_api.SRC_ALPHA, gl_api.ONE_MINUS_SRC_ALPHA)
    
    self.uiShader:use()
    self.uiShader:setInt("uUseTex", 1)
    self.uiShader:setFloat("uAlpha", 1.0)
    self.uiShader:setVec3("uColor", r, g, b)
    self.uiShader:setVec2("uScreenSize", self.width, self.height)
    
    gl_api.glActiveTexture(0x84C0) -- TEXTURE0
    gl_api.glBindTexture(gl_api.TEXTURE_2D, self.fontData.id)
    self.uiShader:setInt("uTex", 0)
    
    gl_api.glBindVertexArray(self.hudVao[0])
    
    local charWidth = 8 * scale
    local charHeight = 8 * scale
    local texW = self.fontData.texWidth
    local texH = self.fontData.texHeight
    local cw = self.fontData.charWidth
    local ch = self.fontData.charHeight
    local localPerRow = self.fontData.charsPerRow
    
    for i = 1, #text do
        local c = text:byte(i)
        if c >= 32 and c <= 126 then
            local idx = c - 32
            local col = idx % localPerRow
            local row = math.floor(idx / localPerRow)
            
            local u = (col * cw) / texW
            local v = (row * ch) / texH
            local uw = cw / texW
            local vh = ch / texH
            
            self.uiShader:setVec2("uPos", x + (i-1) * charWidth, y)
            self.uiShader:setVec2("uSize", charWidth, charHeight)
            self.uiShader:setVec2("uUVOffset", u, v)
            self.uiShader:setVec2("uUVSize", uw, vh)
            gl_api.glDrawArrays(gl_api.TRIANGLE_FAN, 0, 4)
        end
    end
    
    gl_api.glDepthMask(1)
    gl_api.glEnable(gl_api.DEPTH_TEST)
    gl_api.glEnable(gl_api.CULL_FACE)
end

function window:drawRect(x, y, w, h, r, g, b, a)
    self:initHud()
    local gl_api = self.gl_api
    
    r, g, b, a = r or 1, g or 1, b or 1, a or 1
    
    gl_api.glDisable(gl_api.DEPTH_TEST)
    gl_api.glDisable(gl_api.CULL_FACE)
    gl_api.glDepthMask(0)
    gl_api.glEnable(gl_api.BLEND)
    gl_api.glBlendFunc(gl_api.SRC_ALPHA, gl_api.ONE_MINUS_SRC_ALPHA)
    
    self.uiShader:use()
    self.uiShader:setInt("uUseTex", 0)
    self.uiShader:setVec3("uColor", r, g, b)
    self.uiShader:setFloat("uAlpha", a)
    self.uiShader:setVec2("uScreenSize", self.width, self.height)
    
    self.uiShader:setVec2("uPos", x, y)
    self.uiShader:setVec2("uSize", w, h)
    
    gl_api.glBindVertexArray(self.hudVao[0])
    gl_api.glDrawArrays(gl_api.TRIANGLE_FAN, 0, 4)
    
    gl_api.glDepthMask(1)
    gl_api.glEnable(gl_api.DEPTH_TEST)
    gl_api.glEnable(gl_api.CULL_FACE)
end

function window:drawFps()
    self:drawText(string.format("FPS: %d", self.currentFps), 10, 10, 2.0, 1, 1, 0)
end

function window:close()
    glfw.glfwTerminate()
end

function window:isKeyDown(key)
    return glfw.glfwGetKey(self.ptr, key) == 1
end

function window:isMouseButtonDown(button)
    return glfw.glfwGetMouseButton(self.ptr, button) == 1
end

function window:getKeyPressed(key)
    return keyPressed[key] or false
end

function window:getMouseButtonPressed(button)
    return mousePressed[button] or false
end

function window:getMousePos()
    return mouseX, mouseY
end

function window:getMouseDelta()
    return deltaX, deltaY
end

function window:setMouseLock(locked)
    glfw.glfwSetInputMode(self.ptr, glfw.CURSOR, locked and glfw.CURSOR_DISABLED or glfw.CURSOR_NORMAL)
end

function window:setFpsVisible(visible)
    self.fpsVisible = visible
end

function window:isFpsVisible()
    return self.fpsVisible
end

function window:setVsync(enabled)
    glfw.glfwSwapInterval(enabled and 1 or 0)
end

function window:setFpsLimit(limit)
    self.fpsLimit = limit or 0
end

function window:setSize(width, height)
    glfw.glfwSetWindowSize(self.ptr, width, height)
    self.width = width
    self.height = height
    self.resized = true
end

function window:getDeltaTime()
    return self.deltaTime
end

function window:getTime()
    return glfw.glfwGetTime() - self.startTime
end

return window
