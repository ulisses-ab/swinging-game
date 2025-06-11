local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:new(push, pop)
    obj = Updater:new()

    obj.stack = {}

    return setmetatable(obj, StateMachine)
end

function StateMachine:add(state)
    state.state_machine = self
end

function StateMachine:push(state, ...)
    table.insert(self.stack, state)
    Updater.updatables = {state}

    if state.enter then
        state:enter(...)
    end
end

function StateMachine:pop()
    table.remove(self.stack)
    Updater.updatables = {self.stack[#self.stack]}
end

function StateMachine:change(state)
    self:pop()
    self:push(state)
end


return StateMachine