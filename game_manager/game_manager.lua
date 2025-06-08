local Scene = require("Scene")
local persistance = require("persistance")
local editor_mode = require("editor.editor_mode")
local starting_menu = require("game_manager.starting_menu")
local official_levels_list = require("game_manager.official_levels_list")
local my_levels_list = require("game_manager.my_levels_list")
local GameplayOverlay = require("game_manager.GameplayOverlay")
local EditorOverlay = require("game_manager.EditorOverlay")

local game_manager = {
    current_scene = nil,
}

local go_to_main_menu, play_scene, edit_scene

local function go_to_official_levels_list()
    game_manager.is_playing = false
    game_manager.current_scene = official_levels_list:get_scene({
        play = play_scene,
        quit = go_to_main_menu,
    })
end

local function go_to_my_levels_list()
    game_manager.is_playing = false
    game_manager.current_scene = my_levels_list:get_scene({
        play = play_scene,
        quit = go_to_main_menu,
        edit_scene = edit_scene,
    })
end

go_to_main_menu = function()
    game_manager.is_playing = false
    game_manager.paused = false
    game_manager.countdown = -1
    game_manager.current_scene = starting_menu:get_scene({
        start = go_to_official_levels_list,
        my_levels = go_to_my_levels_list,
    })
end

play_scene = function(scene_data)
    game_manager.current_scene = GameplayOverlay:new(scene_data, {
        restart = function()
            play_scene(scene_data)
        end,
        quit = function()
            go_to_official_levels_list()
        end,
    })
end

edit_scene = function(scene_data)
    local new_scene = EditorOverlay:new(scene_data, {
        restart = function()
            play_scene(scene_data)
        end,
        quit = function()
            go_to_official_levels_list()
        end,
    })

    game_manager.current_scene = new_scene
end

function game_manager:load()
    go_to_main_menu()
end

function game_manager:quit()

end

function game_manager:update(dt)
    self.current_scene:update(dt)
end

function game_manager:draw()
    self.current_scene:draw()
end

function game_manager:keypressed(key)
    self.current_scene:keypressed(key)
end

function game_manager:keyreleased(key)
    self.current_scene:keyreleased(key)
end

function game_manager:mousepressed(x, y, button, istouch, presses)
    self.current_scene:mousepressed(x, y, button, istouch, presses)
end

function game_manager:mousereleased(x, y, button, istouch, presses)
    self.current_scene:mousereleased(x, y, button, istouch, presses)
end

function game_manager:wheelmoved(x, y)
    if self.current_scene.wheelmoved then
        self.current_scene:wheelmoved(x, y)
    end
end

return game_manager