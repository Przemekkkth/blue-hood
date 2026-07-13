return function()
    local orb = ECS.entity()
    orb:give('hitbox', 8, 8)
    orb:give('position', 0, 0)
    orb:give('sprite', assets.sprites.orbs, 0, 0)
    orb.sprite.order = 11

    local g = anim8.newGrid(8, 8, assets.sprites.orbs:getWidth(), assets.sprites.orbs:getHeight())
    orb:give('anim8', {
        idle = anim8.newAnimation(g("1-6", 1), 0.2),
        collected = anim8.newAnimation(g("1-5", 2), 0.3)
    }, 'idle')
    
    function orb:collected()
        orb.anim8:reset()
        orb.anim8.name = 'collected'
        orb.collider.data:setObject(nil)
        orb.collider.data:destroy()
        orb:give('sfx', AUDIO_ID.ORB_COLLECT)
        orb:give('delayed_callback', function()
            local world = orb:getWorld()
            world:removeEntity(orb)
            GAME_DATA.ORBS = GAME_DATA.ORBS + 1            
        end, 0.35)
    end

    return orb
end