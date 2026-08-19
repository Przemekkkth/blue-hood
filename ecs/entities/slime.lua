return function()
    local slime = ECS.entity()
    slime.speed = ENEMY_DATA.SLIME_SPEED
    slime.last_speed = slime.speed
    slime.STATE_TIME = 2.0
    slime.states =  {IDLE = 'IDLE', WALK = 'WALK'}
    slime.state = slime.states.IDLE
    slime.timer = Timer()
    slime.lifes = 2

    slime:give('position', 0, 0)
    slime:give('hitbox', 14, 14)
    slime:give('physics')
    slime:give('sprite', assets.sprites.slime, 0, 0)
    slime:give('enemy')

    local g = anim8.newGrid(16, 24, assets.sprites.slime:getWidth(), assets.sprites.slime:getHeight(), 0, 8)
    local g1 = anim8.newGrid(16, 16, assets.sprites.slime:getWidth(), assets.sprites.slime:getHeight())

    slime:give('anim8', {
        walk = anim8.newAnimation(g("1-15", 1), 0.1),
        idle = anim8.newAnimation(g1("1-5", 4), 0.25),
        dead = anim8.newAnimation(g1("1-5", 3), 1.0, 'pauseAtEnd')
    }, 'walk')

    function slime:set_anim(anim_name)
        slime.anim8.name = anim_name
    end

    function slime:smashed()
        slime.lifes = slime.lifes - 1
        if slime.lifes > 0 then
            return
        end
        slime:remove('physics')
        slime.collider.data:destroy()
        slime:set_anim('dead')
    end

    function slime:flip()
        slime.speed = -slime.speed
        slime.sprite.flipped_h = slime.speed > 0
    end

    function slime:update(dt)
        slime.timer:update(dt)
        local collider = slime.collider.data
        local x, y = collider:getPosition()
        local _, vy = collider:getLinearVelocity()
        local w = slime.hitbox.w or 0
        local h = slime.hitbox.h or 0
        local dir = slime.speed > 0 and 1 or -1
        local y_walk_offset = 0
        if slime.anim8.name == 'walk' then
            y_walk_offset = 8
        end

        local ground = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            slime.position.x + slime.hitbox.w / 2 + dir * (slime.hitbox.w / 2 + 2),
            slime.position.y + slime.hitbox.h + 1 + y_walk_offset,
            2,
            2,
            {"Solid"}
        )

        if #ground == 0 then
            slime:flip()
        end

        if x <= w / 2 then
            x = w / 2
            slime:flip()
        end
        
        if x >= GAME_DATA.MAX_X - w / 2 then
            x = GAME_DATA.MAX_X - w / 2
            slime:flip()
        end

        collider:setPosition(x, y)

        slime.position.x = x - w / 2 - PLAYER_DATA.PADDING_X
        slime.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y - y_walk_offset

        collider:setLinearVelocity(slime.speed, vy)

        if collider:enter('Wall') or collider:enter('Player') then
            slime:flip()
        end

        local is_sensitive = (slime.anim8.name == 'idle')
        local top_collider = WindfieldSystem.PhysicsWorld:queryRectangleArea(slime.position.x + 3, slime.position.y - 2 + y_walk_offset, slime.hitbox.w - 2, 2, {'Player'})
        if #top_collider > 0 and is_sensitive then
            local player = top_collider[1]:getObject()
            if player:velocity().y > 0 then
                slime.position.y  = slime.position.y + y_walk_offset
                slime:smashed()
                player:bounce()
            end
        end
    end

    function slime:switch_state()
        if slime.state == slime.states.IDLE then
            slime:set_walk_state()
        else
            slime:set_idle_state()
        end
    end

    function slime:hit()
        
    end

    function slime:set_walk_state()
        slime.state = slime.states.WALK
        slime.anim8.name = 'walk'
        slime.anim8:reset()
        slime.speed = slime.last_speed
        local dir = slime.speed > 0 and 1 or -1
        slime.collider.data:setLinearVelocity(dir * slime.speed, 0)
    end

    function slime:set_idle_state()
        slime.state = slime.states.IDLE
        slime.anim8.name = 'idle'
        slime.anim8:reset()
        slime.last_speed = slime.speed
        slime.speed = 0
        slime.collider.data:setLinearVelocity(0, 0)
    end

    slime.timer:every(slime.STATE_TIME, function()
        slime:switch_state()
    end)

    return slime
end