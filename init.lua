local L3D = {
    math = {
        vec3 = require("L3D.math.vec3"),
        mat4 = require("L3D.math.mat4")
    },
    core = {
        gl = require("L3D.core.gl"),
        window = require("L3D.core.window"),
        input = require("L3D.core.input")
    },
    scene = {
        shader = require("L3D.scene.shader"),
        mesh = require("L3D.scene.mesh"),
        camera = require("L3D.scene.camera"),
        light = require("L3D.scene.light"),
        material = require("L3D.scene.material"),
        texture = require("L3D.scene.texture"),
        cubemap = require("L3D.scene.cubemap"),
        skybox = require("L3D.scene.skybox"),
        renderable = require("L3D.scene.renderable"),
        scene = require("L3D.scene.scene")
    },
    models = {
        cube = require("L3D.models.cube"),
        plane = require("L3D.models.plane"),
        sphere = require("L3D.models.sphere"),
        cylinder = require("L3D.models.cylinder"),
        model = require("L3D.models.model")
    }
}

return L3D
