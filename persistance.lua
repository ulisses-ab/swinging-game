local Player = require("game_objects.Player")
local Pivot = require("game_objects.Pivot")
local Slingshot = require("game_objects.Slingshot")
local Platform = require("game_objects.Platform")
local Enemy = require("game_objects.Enemy")
local Scene = require("Scene")
local json = require("lib.dkjson")

local persistance = {}

local supported_classes = {
    Player = Player,
    Pivot = Pivot,
    Slingshot = Slingshot,
    Platform = Platform,
    Enemy = Enemy
}

local function object_factory(data)
    local object_class = supported_classes[data.type]

    if not object_class then
        error("Unknown object type")
    end

    return object_class:from_persistance_object(data)
end

function persistance.load_scene(filename)
    local scene = Scene:new()
    local file = love.filesystem.read(filename)
    if not file then
        error("Could not read scene file: " .. filename)
    end

    local data = json.decode(file)
    for _, obj_data in ipairs(data.objects) do
        scene:add(object_factory(obj_data))
    end

    return scene
end

function persistance.save_scene(scene, filename) 
    local scene_data = {
        objects = {}
    }

    for _, object in ipairs(scene.objects) do
        if supported_classes[object.type] then
            table.insert(scene_data.objects, object:persistance_object())
        end
    end

    local json_data = json.encode(scene_data, { indent = true })
    print(json_data)
    love.filesystem.write(filename, json_data)
end

return persistance