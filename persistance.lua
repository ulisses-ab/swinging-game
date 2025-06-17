local Player = require("game_objects.Player")
local Pivot = require("game_objects.Pivot")
local Slingshot = require("game_objects.Slingshot")
local Platform = require("game_objects.Platform")
local Enemy = require("game_objects.Enemy")
local Wall = require("game_objects.Wall")
local GameScene = require("GameScene")
local json = require("lib.dkjson")

local persistance = {}

local supported_classes = {
    Player = Player,
    Pivot = Pivot,
    Slingshot = Slingshot,
    Platform = Platform,
    Enemy = Enemy,
    Wall = Wall
}

local function object_factory(data)
    local object_class = supported_classes[data.type]

    if not object_class then return nil end

    return object_class:from_persistance_object(data)
end

function persistance.scene_from_string(string)    
    local compressed = love.data.decode("string", "base64", string)
    local json_data = love.data.decompress("string", "zlib", compressed)

    return persistance.scene_from_json(json_data)
end

function persistance.scene_from_json(json_data)
    local scene = GameScene:new()

    local data = json.decode(json_data)

    for _, obj_data in ipairs(data.objects) do
        local obj = object_factory(obj_data)
        if obj then scene:add(obj) end
    end

    scene.name = data.name or "unnamed scene"

    return scene
end

function persistance.scene_to_string(scene)
    local scene_data = {
        objects = {},
        name = scene.name
    }

    for _, object in ipairs(scene.objects) do
        if supported_classes[object.type] then
            table.insert(scene_data.objects, object:persistance_object())
        end
    end

    local json_data = json.encode(scene_data, { indent = true })

    return persistance.json_to_string(json_data)
end

function persistance.json_to_string(json_data)
    local compressed = love.data.compress("string", "zlib", json_data)
    local encoded = love.data.encode("string", "base64", compressed)

    return encoded
end

function persistance.load_scene(filename)
    local file = love.filesystem.read(filename)
    if not file then
        error("Could not read scene file: " .. filename)
    end

    return persistance.scene_from_string(file)
end

function persistance.save_scene(scene, filename) 
    local string = persistance.scene_to_string(scene)

    love.filesystem.write(filename, string)
end

function persistance.save_in_dir(scene, dirname, filename)
    local base_name = filename
    local index = 0  

    local ok = false
    while not ok do
        filename = index == 0 and base_name or base_name .. "(" .. index .. ")"

        ok = true
        for _, item in ipairs(love.filesystem.getDirectoryItems(dirname)) do
            if filename == item then
                ok = false
            end
        end

        index = index + 1
    end

    scene.name = filename 
    local string = persistance.scene_to_string(scene)
    love.filesystem.write(dirname .. "/" .. filename, string)

    return string
end

return persistance