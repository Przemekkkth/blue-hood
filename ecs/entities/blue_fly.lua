return function()
    local blue_fly = ECS.entity()
    blue_fly.speed = ENEMY_DATA.BLUE_FLY_SPEED
    blue_fly.STATES = {IDLE = 'IDLE', MOVE = 'MOVE'}
    blue_fly.state = blue_fly.STATES.IDLE
    blue_fly.IDLE_TIME = 0.4
    blue_fly.MOVE_TIME = 0.75
    blue_fly.time = 0
    
    blue_fly:give('position', 0, 0)
    blue_fly:give('hitbox', 8, 8)
    blue_fly:give('physics')
    blue_fly:give('sprite', assets.sprites.fly, 0, 0)
    blue_fly.sprite.flipped_h = blue_fly.speed > 0
    blue_fly:give('enemy')

    local g = anim8.newGrid(8, 8, assets.sprites.fly:getWidth(), assets.sprites.fly:getHeight())
    
    blue_fly:give('anim8', {
        die = anim8.newAnimation(g("1-5", 1), 0.2, 'pauseAtEnd'),
        move = anim8.newAnimation(g("1-3", 4), 0.1),
        idle = anim8.newAnimation(g("1-3", 2), 0.1),
    }, 'idle')

      
    function blue_fly:set_anim(anim_name)
        blue_fly.anim8.name = anim_name
    end

    function blue_fly:flip()
        blue_fly.speed = -blue_fly.speed
        blue_fly.sprite.flipped_h = blue_fly.speed > 0
    end

    function blue_fly:update(dt)
        blue_fly:update_state(dt)
        blue_fly:handle_state(dt)
    end

    function blue_fly:update_state(dt)
        blue_fly.time = blue_fly.time + dt
        if blue_fly.state == blue_fly.STATES.IDLE and blue_fly.time > blue_fly.IDLE_TIME then
            blue_fly.time = 0
            blue_fly.state = blue_fly.STATES.MOVE
            blue_fly.anim8:reset()
            blue_fly:set_anim('move')
        elseif blue_fly.state == blue_fly.STATES.MOVE and blue_fly.time > blue_fly.MOVE_TIME then
            blue_fly.time = 0
            blue_fly.state = blue_fly.STATES.IDLE
            blue_fly.anim8:reset()
            blue_fly:set_anim('idle')
        end
    end

    function blue_fly:handle_state(dt)
        if blue_fly.dead then
            return
        end

        if blue_fly.state == blue_fly.STATES.IDLE then
            blue_fly:idle()
        elseif blue_fly.state == blue_fly.STATES.MOVE then
            blue_fly:move()
        end

        local top_collider = WindfieldSystem.PhysicsWorld:queryRectangleArea(blue_fly.position.x - 2, blue_fly.position.y - 2, blue_fly.hitbox.w, 2, {'Player'})
        if #top_collider > 0 then
            local player = top_collider[1]:getObject()
            if player:velocity().y > 0 then
                blue_fly:hit()
                player:bounce()
            end
        end
    end

    function blue_fly:idle()
        local collider = blue_fly.collider.data
        local x, y = collider:getPosition()
        local w = blue_fly.hitbox.w or 0
        local h = blue_fly.hitbox.h or 0
        collider:setPosition(x, y)

        blue_fly.position.x = x - w / 2 + PLAYER_DATA.PADDING_X
        blue_fly.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        collider:setLinearVelocity(0, 0)
    end

    function blue_fly:move()
        local collider = blue_fly.collider.data
        local x, y = collider:getPosition()
        local w = blue_fly.hitbox.w or 0
        local h = blue_fly.hitbox.h or 0
        local dir = blue_fly.speed > 0 and 1 or -1

        collider:setPosition(x, y)

        blue_fly.position.x = x - w / 2 + PLAYER_DATA.PADDING_X
        blue_fly.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        if collider:enter('Wall') or collider:enter('Player') then
            blue_fly:flip()
        end

        collider:setLinearVelocity(blue_fly.speed, 0)
    end

    function blue_fly:hit()
        blue_fly.collider.data:setObject(nil)
        blue_fly.collider.data:destroy()
        blue_fly.dead = true
        blue_fly:remove('physics')
        blue_fly:set_anim('die')
    end

    return blue_fly
end