package.path = package.path .. ";./?.lua;./?/init.lua"
local L3D = require("L3D")
local vec3 = L3D.math.vec3
local mat4 = L3D.math.mat4
local input = L3D.core.input

local win = L3D.core.window.new(1024, 768, "L3D Engine - Free Cam & HUD Support")
local gl = L3D.core.gl

-- Initial Viewport Setup
gl.glViewport(0, 0, win.width, win.height)

local shader = L3D.scene.shader.newLighting()
local scene = L3D.scene.scene.new()

-- Initialize camera with yaw/pitch for free cam
local cam = L3D.scene.camera.new(
    vec3.new(0, 2, 6),
    -90, 0, -- yaw, pitch
    math.rad(60),
    1024/768,
    0.1,
    100.0
)
scene:setCamera(cam)

local cubeMesh = L3D.models.cube.new()
local planeMesh = L3D.models.plane.new(20, 20)
local sphereMesh = L3D.models.sphere.new(0.5, 32, 16)

local matRed = L3D.scene.material.new(
    vec3.new(0.2, 0.1, 0.1),
    vec3.new(0.8, 0.2, 0.2),
    vec3.new(1.0, 0.5, 0.5),
    32.0
)

local matGreen = L3D.scene.material.new(
    vec3.new(0.1, 0.2, 0.1),
    vec3.new(0.2, 0.8, 0.2),
    vec3.new(0.5, 1.0, 0.5),
    32.0
)

local matBlue = L3D.scene.material.new(
    vec3.new(0.1, 0.1, 0.2),
    vec3.new(0.2, 0.2, 0.8),
    vec3.new(0.5, 0.5, 1.0),
    64.0
)

local matGold = L3D.scene.material.new(
    vec3.new(0.25, 0.22, 0.06),
    vec3.new(0.75, 0.65, 0.22),
    vec3.new(1.0, 0.92, 0.8),
    128.0
)

local cube1 = L3D.scene.renderable.new(cubeMesh, matRed)
cube1:setPosition(-2, 0, 0)
scene:addObject(cube1)

local cube2 = L3D.scene.renderable.new(cubeMesh, matGreen)
cube2:setPosition(2, 0, 0)
scene:addObject(cube2)

local cube3 = L3D.scene.renderable.new(cubeMesh, matGold)
cube3:setPosition(0, 0.5, -2)
scene:addObject(cube3)

local sphere1 = L3D.scene.renderable.new(sphereMesh, matBlue)
sphere1:setPosition(0, 1.5, 0)
scene:addObject(sphere1)

local dirLight = L3D.scene.light.newDirectional(
    vec3.new(-1, -1, -1),
    {1.0, 0.95, 0.9},
    1.2
)
scene:addLight(dirLight)

local pointLight = L3D.scene.light.newPoint(
    vec3.new(2, 3, 2),
    {1.0, 0.5, 0.2},
    1.0, 0.09, 0.032
)
scene:addLight(pointLight)

local spotLight = L3D.scene.light.newSpot(
    vec3.new(0, 4, 0),
    vec3.new(0, -1, 0),
    math.cos(math.rad(12.5)),
    math.cos(math.rad(15.0)),
    {0.8, 0.8, 1.0},
    1.0, 0.09, 0.032
)
scene:addLight(spotLight)

local cubemap = L3D.scene.cubemap.newColor(135, 206, 235) -- Sky Blue
local skybox = L3D.scene.skybox.new(cubemap)
scene:setSkybox(skybox)

-- Dynamic Lights Collection
local movingPointLights = {}
local colors = {{1,0,0}, {0,1,0}, {0,0,1}, {1,1,0}}
for i = 1, 4 do
    local pl = L3D.scene.light.newPoint(
        vec3.new(0,0,0),
        colors[i],
        1.5, 0.09, 0.032
    )
    scene:addLight(pl)
    table.insert(movingPointLights, pl)
end

-- Spawned Objects Collection
local spawnedObjects = {}

-- local lastTime = os.clock() (removed)
local mouseLocked = true
win:setMouseLock(mouseLocked)
win:setFpsVisible(true)

local vsync = true
local fpsLimit = 0
local resolutions = {
    {1024, 768},
    {1280, 720},
    {800, 600}
}
local resIdx = 1

win:setVsync(vsync)
win:setFpsLimit(fpsLimit)

local menuOpen = false
local menuIdx = 1
local menuItems = {
    {name = "VSync", options = {"OFF", "ON"}, current = vsync and 2 or 1},
    {name = "FPS Limit", options = {"None", "60", "30"}, current = 1},
    {name = "Resolution", options = {"1024x768", "1280x720", "800x600"}, current = 1},
    {name = "FPS Counter", options = {"Hidden", "Visible"}, current = win:isFpsVisible() and 2 or 1},
    {name = "Ambient Intens", options = {"0.1", "0.5", "1.0", "2.0"}, current = 2},
    {name = "Sky Mode", options = {"Static", "Dynamic"}, current = 1}
}

local function drawCenteredText(win, text, y, scale, r, g, b)
    local x = (win.width / 2) - (#text * 8 * scale / 2)
    win:drawText(text, x, y, scale, r, g, b)
end

while not win:shouldClose() do
    local dt = win:getDeltaTime()
    local currentTime = win:getTime()

    -- Window Resize Handling
    if win.resized then
        gl.glViewport(0, 0, win.width, win.height)
        cam:setAspect(win.width / win.height)
        win.resized = false
    end

    -- Camera Movement
    local speed = 5 * dt
    if win:isKeyDown(input.key.W) then cam:moveForward(speed) end
    if win:isKeyDown(input.key.S) then cam:moveForward(-speed) end
    if win:isKeyDown(input.key.A) then cam:moveRight(-speed) end
    if win:isKeyDown(input.key.D) then cam:moveRight(speed) end
    if win:isKeyDown(input.key.SPACE) then cam:moveUp(speed) end
    if win:isKeyDown(input.key.LEFT_SHIFT) then cam:moveUp(-speed) end

    -- Toggles
    if win:getKeyPressed(input.key.ESCAPE) then
        if menuOpen then
            menuOpen = false
            mouseLocked = true
            win:setMouseLock(true)
        else
            mouseLocked = not mouseLocked
            win:setMouseLock(mouseLocked)
        end
    end

    if win:getKeyPressed(input.key.Y) then
        menuOpen = not menuOpen
        mouseLocked = not menuOpen
        win:setMouseLock(mouseLocked)
    end

    if menuOpen then
        if win:getKeyPressed(input.key.UP) then
            menuIdx = (menuIdx - 2) % #menuItems + 1
        end
        if win:getKeyPressed(input.key.DOWN) then
            menuIdx = menuIdx % #menuItems + 1
        end
        
        local item = menuItems[menuIdx]
        local changed = false
        if win:getKeyPressed(input.key.LEFT) then
            item.current = (item.current - 2) % #item.options + 1
            changed = true
        end
        if win:getKeyPressed(input.key.RIGHT) then
            item.current = item.current % #item.options + 1
            changed = true
        end
        
        if changed then
            if item.name == "VSync" then
                vsync = (item.current == 2)
                win:setVsync(vsync)
            elseif item.name == "FPS Limit" then
                local opt = item.options[item.current]
                fpsLimit = (opt == "None") and 0 or tonumber(opt)
                win:setFpsLimit(fpsLimit)
            elseif item.name == "Resolution" then
                local res = resolutions[item.current]
                win:setSize(res[1], res[2])
            elseif item.name == "FPS Counter" then
                win:setFpsVisible(item.current == 2)
            elseif item.name == "Ambient Intens" then
                local intens = tonumber(item.options[item.current])
                scene:setAmbientLight({0.1, 0.1, 0.1}, intens)
            end
        end
    end

    -- Spawning Logic
    if win:getKeyPressed(input.key.K) and not menuOpen then
        for i = 1, 500 do
            local obj = L3D.scene.renderable.new(cubeMesh, matGold)
            local forward = cam.front * (5.0 + math.random() * 15.0)
            local spread = 10.0
            local x = cam.eye.x + forward.x + (math.random() - 0.5) * spread
            local y = cam.eye.y + forward.y + (math.random() - 0.5) * spread
            local z = cam.eye.z + forward.z + (math.random() - 0.5) * spread
            obj:setPosition(x, y, z)
            scene:addObject(obj)
            table.insert(spawnedObjects, {obj = obj, rotX = math.random()*2, rotY = math.random()*2})
        end
    end
    if win:getKeyPressed(input.key.L) and not menuOpen then
        for _, entry in ipairs(spawnedObjects) do
            scene:removeObject(entry.obj)
        end
        spawnedObjects = {}
    end

    -- Free Cam Rotation
    if mouseLocked and not menuOpen then
        local dx, dy = win:getMouseDelta()
        local sensitivity = 0.1
        if dx ~= 0 or dy ~= 0 then
            cam:rotate(dx * sensitivity, -dy * sensitivity)
        end
    end

    -- Scene Logic
    cube1:rotate(0, 1.5 * dt, 0)
    cube2:rotate(0, -1.2 * dt, 0.5 * dt)
    cube3:rotate(0.8 * dt, 1.0 * dt, 0)
    sphere1:translate(0, math.sin(currentTime * 2) * 0.01 * dt, 0)

    -- Update Moving Lights
    for i, pl in ipairs(movingPointLights) do
        local angle = currentTime + (i * (math.pi * 2 / #movingPointLights))
        local radius = 4.0
        pl:setPosition(math.cos(angle) * radius, 2, math.sin(angle) * radius)
    end

    -- Update Spawned Objects
    for _, entry in ipairs(spawnedObjects) do
        entry.obj:rotate(entry.rotX * dt, entry.rotY * dt, 0)
    end

    -- Dynamic Skybox
    if menuItems[6].current == 2 then
        local r = (math.sin(currentTime * 0.5) + 1) * 0.5 * 255
        local g = (math.sin(currentTime * 0.7) + 1) * 0.5 * 255
        local b = (math.sin(currentTime * 0.9) + 1) * 0.5 * 255
        skybox.cubemap:updateColor(r, g, b)
    end

    -- Rendering
    gl.glClearColor(0.1, 0.1, 0.15, 1.0)
    gl.glClear(gl.COLOR_BUFFER_BIT + gl.DEPTH_BUFFER_BIT)
    gl.glEnable(gl.DEPTH_TEST)

    shader:use()
    scene:render(shader)
    scene:renderSkybox()

    if menuOpen then
        local mw, mh = 700, 550
        local mx = win.width / 2 - mw / 2
        local my = win.height / 2 - mh / 2
        win:drawRect(mx, my, mw, mh, 0, 0, 0, 0.8)
        
        local textY = my + 30
        drawCenteredText(win, "--- ENGINE MENU ---", textY, 3.0, 1, 1, 1)
        
        for i, item in ipairs(menuItems) do
            local color = (i == menuIdx) and {1, 1, 0} or {0.8, 0.8, 1}
            local prefix = (i == menuIdx) and "> " or "  "
            local text = prefix .. item.name .. ": < " .. item.options[item.current] .. " >"
            drawCenteredText(win, text, textY + 80 + (i-1) * 45, 2.0, unpack(color))
        end
        
        drawCenteredText(win, "[Y/ESC] Close Menu", my + mh - 70, 1.5, 1, 0.5, 0.5)
        drawCenteredText(win, "ARROWS to Navigate & Change", my + mh - 45, 1.2, 0.7, 0.7, 0.7)
        drawCenteredText(win, "[K] Spawn Cube   [L] Clear All", my + mh - 25, 1.2, 0.5, 1.0, 0.5)
    end

    win:update()
end

win:close()
