Anim8System = ECS.system({pool = {'anim8'}})

function Anim8System:update(dt)
    for _, entity in ipairs(self.pool) do
        local anim_name = entity.anim8.name
        local totalFrames = #entity.anim8.animations[anim_name].frames

        entity.anim8.animations[anim_name]:update(dt)

        if entity:has('is_player') and anim_name == 'die' and entity.anim8.animations[anim_name].position == totalFrames then
            GameRoom.STATE = GameRoom.STATES.RESTART
        end
    end
end