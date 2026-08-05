return function()
    local worm = ECS.entity()
    worm.speed = ENEMY_DATA.MUSHROOM_SPEED

    worm:give('position', 0, 0)
    worm:give('hitbox', 14, 6)
    worm:give('physics')
    worm:give('sprite', assets.sprites.worm, 0, 0)
    worm:give('enemy')

    local g = anim8.newGrid(16, 8, assets.sprites.worm:getWidth(), assets.sprites.worm:getHeight())
    worm:give('anim8', {
        walk = anim8.newAnimation(g("1-6", 1), 0.1),
        dead = anim8.newAnimation(g("1-6", 2), 0.3, 'pauseAtEnd')
    }, 'walk')

    function worm:set_anim(anim_name)
        worm.anim8.name = anim_name
    end

    function worm:smashed()
        worm:remove('physics')
        worm.collider.data:destroy()
        worm:set_anim('dead')
    end

    function worm:flip()
        worm.speed = -worm.speed
        worm.sprite.flipped_h = worm.speed < 0
    end

    function worm:update(dt)
        local collider = worm.collider.data
        local x, y = collider:getPosition()
        local _, vy = collider:getLinearVelocity()
        local w = worm.hitbox.w or 0
        local h = worm.hitbox.h or 0
        local dir = worm.speed > 0 and 1 or -1

        local ground = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            worm.position.x + worm.hitbox.w / 2 + dir * (worm.hitbox.w / 2 + 2),
            worm.position.y + worm.hitbox.h + 1,
            2,
            2,
            {"Solid"}
        )

        if #ground == 0 then
            worm:flip()
        end

        if x <= w / 2 then
            x = w / 2
            worm:flip()
        end
        
        if x >= GAME_DATA.MAX_X - w / 2 then
            x = GAME_DATA.MAX_X - w / 2
            worm:flip()
        end

        collider:setPosition(x, y)

        worm.position.x = x - w / 2 - PLAYER_DATA.PADDING_X
        worm.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        collider:setLinearVelocity(worm.speed, vy)

        if collider:enter('Wall') or collider:enter('Player') then
            worm:flip()
        end

        local top_collider = WindfieldSystem.PhysicsWorld:queryRectangleArea(worm.position.x + 3, worm.position.y - 2, worm.hitbox.w - 2, 2, {'Player'})
        if #top_collider > 0 then
            local player = top_collider[1]:getObject()
            if player:velocity().y > 0 then
                worm:smashed()
                player:bounce()
            end
        end
    end
    
    return worm
end

