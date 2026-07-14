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

    function mushroom:update(dt)
        local collider = mushroom.collider.data
        local x, y = collider:getPosition()
        local _, vy = collider:getLinearVelocity()
        local w = mushroom.hitbox.w or 0
        local h = mushroom.hitbox.h or 0
        local dir = mushroom.speed > 0 and 1 or -1

        local ground = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            mushroom.position.x + mushroom.hitbox.w / 2 + dir * (mushroom.hitbox.w / 2 + 2),
            mushroom.position.y + mushroom.hitbox.h + 1,
            2,
            2,
            {"Solid"}
        )

        if #ground == 0 then
            mushroom:flip()
        end

        if x <= w / 2 then
            x = w / 2
            mushroom:flip()
        end
        
        if x >= GAME_DATA.MAX_X - w / 2 then
            x = GAME_DATA.MAX_X - w / 2
            mushroom:flip()
        end
        
        collider:setPosition(x, y)

        mushroom.position.x = x - w / 2 - PLAYER_DATA.PADDING_X
        mushroom.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        collider:setLinearVelocity(mushroom.speed, vy)

        if collider:enter('Wall') or collider:enter('Player') then
            mushroom:flip()
        end

        if mushroom.dead then
            collider:destroy()
        end
    end

    return mushroom
end