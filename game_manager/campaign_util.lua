local persistance = require("persistance")

local campaign_util = {
    level_list = love.filesystem.getDirectoryItems("campaign_levels")
}

function campaign_util:get_level_list()
    return self.level_list
end

function campaign_util:get_star_times(number)
    local str = love.filesystem.read("campaign_stars/" .. self.level_list[number])

    if not str then return nil end

    local times = {}
    for time in str:gmatch("%S+") do
        table.insert(times, tonumber(time))
    end
    return times
end

function campaign_util:get_best_time(number)
    local str = love.filesystem.read("campaign_best/" .. self.level_list[number])

    if not str then return nil end

    return tonumber(str)
end

function campaign_util:register_time(number, time)
    local str = love.filesystem.read("campaign_best/" .. self.level_list[number])

    if not str or tonumber(str) > time then
        love.filesystem.write("campaign_best/" .. self.level_list[number], time)
    end
end

function campaign_util:load_level(number)
    return persistance.load_scene("campaign_levels/" .. self.level_list[number])
end

function campaign_util:get_all_star_times()
    star_times = {}

    for i = 1, #self.level_list do
        local st = self:get_star_times(i)

        if st then 
            star_times[i] = st
        end
    end

    return star_times
end

function campaign_util:get_all_best_times()
    best_times = {}

    for i = 1, #self.level_list do
        local bt = self:get_best_time(i)

        if bt then 
            best_times[i] = bt
        end
    end

    return best_times
end

return campaign_util