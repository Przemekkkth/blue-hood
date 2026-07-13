SFXSystem = ECS.system({sfx_pool = {'sfx'}})

function SFXSystem:update(dt)
    for _, entity in ipairs(self.sfx_pool) do
        local audio_id = entity.sfx.id
        assets.audios[audio_id]:stop()
        assets.audios[audio_id]:setVolume(GAME_DATA.AUDIO_VOLUME)
        assets.audios[audio_id]:play()
        entity:remove('sfx')
    end
end