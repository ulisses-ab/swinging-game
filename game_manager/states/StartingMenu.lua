local gui = require("game_manager.gui.starting_menu")
local Scene = require("Scene")

local StartingMenu = Scene:new()
StartingMenu.state_machine = nil

function StartingMenu:init()
    local gui_scene = gui({
        campaign = function()
            self.state_machine:change("CampaignMenu")
        end,
        my_levels = function()
            self.state_machine:change("MyLevelsMenu")
        end,
        quit = love.event.quit  
    })

    self:add(gui_scene)
end

local cover = love.graphics.newImage("assets/images/cover.png")

function StartingMenu:draw()
    love.graphics.draw(cover, -cover:getWidth()/2 + 80, -cover:getHeight()/2 - 40) 
    Scene.draw(self)
end

StartingMenu:init()

return StartingMenu