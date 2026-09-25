return function()
    local orange_fly = ECS.entity()

    orange_fly.DIE_TIME = 0.2
    orange_fly.IDLE_TIME = 0.4
    orange_fly.RUN_TIME = 0.80
    orange_fly.SIZE = 8
    orange_fly.STATES = {IDLE = 'IDLE', WALK = 'WALK', RUN = 'RUN'}
    orange_fly.WALK_TIME = 1.0

    orange_fly.speed = ENEMY_DATA.ORANGE_FLY_SPEED
    orange_fly.state = orange_fly.STATES.IDLE
    orange_fly.time = 0
    
    orange_fly:give('enemy')
    orange_fly:give('hitbox', orange_fly.SIZE, orange_fly.SIZE)
    orange_fly:give('position')
    orange_fly:give('physics')
    orange_fly:give('sprite', assets.sprites.fly)
    orange_fly.sprite.flipped_h = orange_fly.speed > 0


    local g = anim8.newGrid(orange_fly.SIZE, orange_fly.SIZE, assets.sprites.fly:getWidth(), assets.sprites.fly:getHeight())
    orange_fly:give('anim8', {
        die = anim8.newAnimation(g("1-5",  5), orange_fly.DIE_TIME, 'pauseAtEnd'),
        move = anim8.newAnimation(g("1-3", 8), orange_fly.RUN_TIME / 9),
        idle = anim8.newAnimation(g("1-3", 6), orange_fly.IDLE_TIME / 6),
    }, 'idle')

      
    function orange_fly:set_anim(anim_name)
        orange_fly.anim8.name = anim_name
    end

    function orange_fly:flip()
        orange_fly.speed = -orange_fly.speed
        orange_fly.sprite.flipped_h = orange_fly.speed > 0
    end

    function orange_fly:update(dt)
        orange_fly:update_state(dt)
        orange_fly:handle_state(dt)
    end

    function orange_fly:update_state(dt)
        orange_fly.time = orange_fly.time + dt

        if orange_fly.state == orange_fly.STATES.IDLE and orange_fly.time > orange_fly.IDLE_TIME then
            orange_fly.time = 0
            orange_fly.state = orange_fly.STATES.WALK
            orange_fly.anim8:reset()
            orange_fly:set_anim('move')
        elseif orange_fly.state == orange_fly.STATES.WALK and orange_fly.time > orange_fly.WALK_TIME then
            orange_fly.time = 0
            orange_fly.state = orange_fly.STATES.RUN
        elseif orange_fly.state == orange_fly.STATES.RUN and orange_fly.time > orange_fly.RUN_TIME then
            orange_fly.time = 0
            orange_fly.state = orange_fly.STATES.IDLE
            orange_fly:set_anim('idle')
        end
    end

    function orange_fly:handle_state(dt)
        if orange_fly.dead then
            return
        end

        if orange_fly.state == orange_fly.STATES.IDLE then
            orange_fly:idle()
        elseif orange_fly.state == orange_fly.STATES.WALK or orange_fly.state == orange_fly.STATES.RUN then
            orange_fly:move()
        end

        local top_collider_size = 2
        local top_collider = WindfieldSystem.PhysicsWorld:queryRectangleArea(orange_fly.position.x - top_collider_size, orange_fly.position.y - top_collider_size, 
                                                                             orange_fly.SIZE + top_collider_size, top_collider_size, {'Player'})
        if #top_collider > 0 then
            local player = top_collider[1]:getObject()
            if player:velocity().y > 0 then
                orange_fly:hit()
                player:bounce()
            end
        end
    end

    function orange_fly:idle()
        local collider = orange_fly.collider.data
        local x, y = collider:getPosition()
        collider:setPosition(x, y)

        orange_fly.position.x = x - orange_fly.SIZE / 2
        orange_fly.position.y = y - orange_fly.SIZE / 2

        collider:setLinearVelocity(0, 0)
    end

    function orange_fly:move()
        local collider = orange_fly.collider.data
        local x, y = collider:getPosition()

        collider:setPosition(x, y)

        orange_fly.position.x = x - orange_fly.SIZE / 2
        orange_fly.position.y = y - orange_fly.SIZE / 2

        if collider:enter('Wall') or collider:enter('Player') then
            orange_fly:flip()
        end

        local factor = 1.0
        if orange_fly.state == orange_fly.STATES.WALK then
            factor = 0.6
        end
        collider:setLinearVelocity(factor * orange_fly.speed, 0)
    end

    function orange_fly:hit()
        orange_fly.collider.data:setObject(nil)
        orange_fly.collider.data:destroy()
        orange_fly.dead = true
        orange_fly:remove('physics')
        orange_fly:set_anim('die')
    end

    return orange_fly
end