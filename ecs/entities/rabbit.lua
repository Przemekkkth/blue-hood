return function()
    local rabbit = ECS.entity()
    rabbit:give('sprite', assets.sprites.fauna, 0, 0)
    rabbit:give('hitbox', 16, 7)
    rabbit:give('position', 0, 0)
    rabbit:give('physics')
    rabbit:give('fauna')

    local g = anim8.newGrid(16, 8, assets.sprites.fauna:getWidth(), assets.sprites.fauna:getHeight())
    rabbit:give('anim8', {
        run = anim8.newAnimation(g("1-6", 4), 0.1),
        idle = anim8.newAnimation(g("1-4", 5), 0.5)
    }, 'idle')
    
    rabbit.STATE_TIME = 2.0
    rabbit.SPEED = 25

    rabbit.states =  {IDLE = 'IDLE', RUN = 'RUN'}
    rabbit.state = rabbit.states.IDLE
    rabbit.speed = rabbit.SPEED
    rabbit.timer = Timer()

    function rabbit:update(dt)
        rabbit.timer:update(dt)

        if rabbit.state == rabbit.states.RUN then
            local collider = rabbit.collider.data
            local x, y = collider:getPosition()
            local _, vy = collider:getLinearVelocity()
            local w = rabbit.hitbox.w or 0
            local h = rabbit.hitbox.h or 0
            local dir = rabbit.speed > 0 and 1 or -1
    
            local ground = WindfieldSystem.PhysicsWorld:queryRectangleArea(
                rabbit.position.x + rabbit.hitbox.w / 2 + dir * (rabbit.hitbox.w / 2),
                rabbit.position.y + rabbit.hitbox.h,
                2,
                2,
                {"Solid"}
            )
    
            if #ground == 0 then
                rabbit:flip()
            end
    
            if x <= w / 2 then
                x = w / 2
                rabbit:flip()
            end
            
            if x >= GAME_DATA.MAX_X - w / 2 then
                x = GAME_DATA.MAX_X - w / 2
                rabbit:flip()
            end
            
            collider:setPosition(x, y)
    
            rabbit.position.x = x - w / 2
            rabbit.position.y = y - h / 2
    
            collider:setLinearVelocity(rabbit.speed, vy)
    
            if collider:enter('Wall') then
                rabbit:flip()
            end
        end

    end

    function rabbit:switch_state()
        if rabbit.state == rabbit.states.IDLE then
            rabbit.state = rabbit.states.RUN
            rabbit.anim8.name = 'run'
        else
            rabbit.state = rabbit.states.IDLE
            rabbit.anim8.name = 'idle'
        end
    end

    rabbit.timer:every(rabbit.STATE_TIME, function()
        rabbit:switch_state()
    end)

    function rabbit:flip()
        rabbit.speed = -rabbit.speed
        rabbit.sprite.flipped_h = rabbit.speed < 0
    end

    return rabbit
end