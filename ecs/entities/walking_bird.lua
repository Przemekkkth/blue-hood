return function()
    local walking_bird = ECS.entity()

    walking_bird.IDLE_TIME = 0.3
    walking_bird.RUN_TIME = 0.1
    walking_bird.SPEED = -25
    walking_bird.STATE_TIME = 2.0
    walking_bird.STATES =  {IDLE = 'IDLE', RUN = 'RUN'}

    walking_bird.speed = walking_bird.SPEED
    walking_bird.state = walking_bird.STATES.IDLE
    walking_bird.timer = Timer()

    walking_bird:give('fauna')
    walking_bird:give('hitbox', 8, 7)
    walking_bird:give('physics')
    walking_bird:give('position')
    walking_bird:give('sprite', assets.sprites.fauna)


    local frame_width, frame_height = 8, 8
    local g = anim8.newGrid(frame_width, frame_height, assets.sprites.fauna:getWidth(), assets.sprites.fauna:getHeight())
    walking_bird:give('anim8', {
        idle = anim8.newAnimation(g("1-8", 1), walking_bird.IDLE_TIME),
        run  = anim8.newAnimation(g("1-3", 3), walking_bird.RUN_TIME)
    }, 'idle')

    function walking_bird:update(dt)
        walking_bird.timer:update(dt)

        if walking_bird.state == walking_bird.STATES.RUN then
            local collider = walking_bird.collider.data
            local x, y = collider:getPosition()
            local _, vy = collider:getLinearVelocity()
            local w = walking_bird.hitbox.w or 0
            local h = walking_bird.hitbox.h or 0
            local dir = walking_bird.speed > 0 and 1 or -1
    
            local ground = WindfieldSystem.PhysicsWorld:queryRectangleArea(
                walking_bird.position.x + walking_bird.hitbox.w / 2 + dir * (walking_bird.hitbox.w / 2),
                walking_bird.position.y + walking_bird.hitbox.h,
                2,
                2,
                {"Solid"}
            )
    
            if #ground == 0 then
                walking_bird:flip()
            end
    
            if x <= w / 2 then
                x = w / 2
                walking_bird:flip()
            end
            
            if x >= GAME_DATA.MAX_X - w / 2 then
                x = GAME_DATA.MAX_X - w / 2
                walking_bird:flip()
            end
            
            collider:setPosition(x, y)
    
            walking_bird.position.x = x - w / 2
            walking_bird.position.y = y - h / 2
    
            collider:setLinearVelocity(walking_bird.speed, vy)
    
            if collider:enter('Wall') then
                walking_bird:flip()
            end
        end

    end

    function walking_bird:switch_state()
        if walking_bird.state == walking_bird.STATES.IDLE then
            walking_bird.state = walking_bird.STATES.RUN
            walking_bird.anim8.name = 'run'
            local dir = walking_bird.speed > 0 and 1 or -1
            walking_bird.collider.data:setLinearVelocity(dir * walking_bird.speed, 0)
        else
            walking_bird.state = walking_bird.STATES.IDLE
            walking_bird.anim8.name = 'idle'
            walking_bird.collider.data:setLinearVelocity(0, 0)
        end
    end

    walking_bird.timer:every(walking_bird.STATE_TIME, function()
        walking_bird:switch_state()
    end)

    function walking_bird:flip()
        walking_bird.speed = -walking_bird.speed
        walking_bird.sprite.flipped_h = walking_bird.speed > 0
    end

    return walking_bird
end