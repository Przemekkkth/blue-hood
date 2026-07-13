return function()
    local mushroom = ECS.entity()

    mushroom.speed = ENEMY_DATA.MUSHROOM_SPEED
    mushroom:give('position', 0, 0)
    mushroom:give('hitbox', 14, 14)
    mushroom:give('physics')
    mushroom:give('sprite', assets.sprites.mushroom, 0, 0)
    mushroom:give('enemy')

    local g = anim8.newGrid(16, 16, assets.sprites.mushroom:getWidth(), assets.sprites.mushroom:getHeight())
    mushroom:give('anim8', {
        walk = anim8.newAnimation(g("1-8", 1), 0.2),
        smash = anim8.newAnimation(g("1-3", 2), 0.2, 'pauseAtEnd'),
        die = anim8.newAnimation(g("1-8", 3), 0.2, 'pauseAtEnd'),
    }, 'walk')

    function mushroom:set_anim(anim_name)
        mushroom.anim8.name = anim_name
    end

    function mushroom:hit()
        mushroom.collider.data:setObject(nil)
        mushroom.dead = true
        mushroom:remove('physics')
        mushroom:set_anim('die')
    end

    function mushroom:smashed()
        mushroom:remove('physics')
        mushroom.collider.data:destroy()
        mushroom:set_anim('smash')
    end

    function mushroom:flip()
        mushroom.speed = -mushroom.speed
        mushroom.sprite.flipped_h = mushroom.speed < 0
    end

    return mushroom
end