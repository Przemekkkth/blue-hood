return function()
    local rabbit = ECS.entity()

    rabbit.IDLE_TIME = 0.5
    rabbit.RUN_TIME = 0.1
    rabbit.SPEED = 25
    rabbit.STATE_TIME = 2.0
    rabbit.STATES =  {IDLE = 'IDLE', RUN = 'RUN'}

    rabbit.state = rabbit.STATES.IDLE
    rabbit.speed = rabbit.SPEED
    rabbit.timer = Timer()

    rabbit:give('fauna')
    rabbit:give('hitbox', 16, 7)
    rabbit:give('sprite', assets.sprites.fauna)
    rabbit:give('position')
    rabbit:give('physics')

    local g = anim8.newGrid(16, 8, assets.sprites.fauna:getWidth(), assets.sprites.fauna:getHeight())
    rabbit:give('anim8', {
        run  = anim8.newAnimation(g("1-6", 4), rabbit.RUN_TIME),
        idle = anim8.newAnimation(g("1-4", 5), rabbit.IDLE_TIME)
    }, 'idle')

    function rabbit:update(dt)
        rabbit.timer:update(dt)

        if rabbit.state == rabbit.STATES.RUN then
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
        if rabbit.state == rabbit.STATES.IDLE then
            rabbit.state = rabbit.STATES.RUN
            rabbit.anim8.name = 'run'
            local dir = rabbit.speed > 0 and 1 or -1
            rabbit.collider.data:setLinearVelocity(dir * rabbit.speed, 0)
        else
            rabbit.state = rabbit.STATES.IDLE
            rabbit.anim8.name = 'idle'
            rabbit.collider.data:setLinearVelocity(0, 0)
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