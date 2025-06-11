local EventBus = {
    listeners = {}
}

function EventBus:listen(event, callback)
    if not self.listeners[event] then
        self.listeners[event] = {}
    end

    table.insert(self.listeners[event], callback)
end

function EventBus:emit(event, ...)
    if not self.listeners[event] then return end

    for _, callback in ipairs(self.listeners) do
        callback(...)
    end
end

return EventBus