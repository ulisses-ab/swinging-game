local persistance = require("persistance")
local util = require("util")

local my_levels_util = {
    level_list = love.filesystem.getDirectoryItems("my_levels")
}

function my_levels_util:get_level_list()
    return self.level_list
end

function my_levels_util:get_best_time(level)
    local str = love.filesystem.read("my_levels_best/" .. level)

    if not str then return nil end

    return tonumber(str)
end

function my_levels_util:register_time(level, time)
    local str = love.filesystem.read("my_levels_best/" .. level)

    if not str or tonumber(str) > time then
        love.filesystem.write("my_levels_best/" .. level, time)
    end
end

function my_levels_util:load_level(level)
    return persistance.load_scene("my_levels/" .. level)
end

function my_levels_util:get_all_best_times()
    best_times = {}

    for _, level in ipairs(self.level_list) do
        local bt = self:get_best_time(level)

        if bt then 
            best_times[level] = bt
        end
    end

    return best_times
end

function my_levels_util:delete_level(level)
    love.filesystem.remove("my_levels/" .. level)
    love.filesystem.remove("my_levels_best/" .. level)
    util.remove_obj_in_array(self.level_list, level)
end

function my_levels_util:save_scene(scene, name, substitute)
    scene.name = name
    if substitute then
        love.filesystem.remove("my_levels_best/" .. name)
        persistance.save_scene(scene, "my_levels/" .. name)
    else
        persistance.save_in_dir(scene, "my_levels", name)
    end
end

function my_levels_util:save_string(string)
    local scene = persistance.scene_from_string(string)

    persistance.save_in_dir(scene, "my_levels", scene.name)
end 


return my_levels_util