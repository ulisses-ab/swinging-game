local StateManager = {}
StateManager.__index = StateManager

function StateManager:new(push, pop)
    obj = Scene:new()

    return setmetatable(obj, StateManager)
end

function StateManager:push(state)

end

function StateManager:pop()

end



return StateManager