TimerSystem = ECS.system({delayed_callback_pool = {'delayed_callback'}})

function TimerSystem:update(dt)
    for _, entity in ipairs(self.delayed_callback_pool) do
        local delayed_callback = entity.delayed_callback
        delayed_callback.time = delayed_callback.time - dt
        if delayed_callback.time <= 0 then
            delayed_callback.callback()
            entity:remove('delayed_callback')
        end
    end
end