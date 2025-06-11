local Scene = require("Scene")

local StateMachine = {}
StateMachine.__index = StateMachine
setmetatable(StateMachine, Scene)

function StateMachine:new()
    obj = Scene:new()

    obj.states = {}
    obj.type = "StateMachine"

    return setmetatable(obj, StateMachine)
end

function StateMachine:register(state_name, state)
    state.state_machine = self
    self.states[state_name] = state
end

function StateMachine:change(state_name, ...)
    local state = self.states[state_name]

    self:remove_all()
    self:add(state)
    
    if state.enter_state then
        state:enter_state(...)
    end
end

return StateMachine