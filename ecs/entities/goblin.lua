return function()
    local goblin = ECS.entity()
    goblin.speed = ENEMY_DATA.GOBLIN_SPEED
    goblin.STATES = {IDLE = 'IDLE', ATTACK = 'ATTACK', RUN = 'RUN'}
    goblin.state = goblin.STATES.IDLE
    goblin.IDLE_TIME = 0.5
    goblin.RUN_TIME = 2.0
    goblin.ATTACK_TIME = 0.5
    goblin.time = 0
    goblin.is_pushed = false
    goblin.attack_force = 15

    goblin:give('position', 0, 0)
    goblin:give('hitbox', 14, 14)
    goblin:give('physics')
    goblin:give('sprite', assets.sprites.goblin, 0, 0)
    goblin:give('enemy')

    local g = anim8.newGrid(16, 16, assets.sprites.goblin:getWidth(), assets.sprites.goblin:getHeight())
    local g1 = anim8.newGrid(24, 16, assets.sprites.goblin:getWidth(), assets.sprites.goblin:getHeight())
    goblin:give('anim8', {
        run = anim8.newAnimation(g("1-6", 1), 0.2),
        die = anim8.newAnimation(g("1-6", 2), 0.2, 'pauseAtEnd'),
        attack = anim8.newAnimation(g1("1-4", 3), 0.5, 'pauseAtEnd'),
        idle = anim8.newAnimation(g("1-6", 4), 0.2),
    }, 'run')

  
    function goblin:set_anim(anim_name)
        goblin.anim8.name = anim_name
    end

    function goblin:smashed()
        goblin:remove('physics')
        goblin.collider.data:destroy()
        goblin:set_anim('smash')
    end

    function goblin:flip()
        goblin.speed = -goblin.speed
        goblin.sprite.flipped_h = goblin.speed < 0
    end

    function goblin:update(dt)
        goblin:update_state(dt)
        goblin:handle_state(dt)
    end

    function goblin:update_state(dt)
        goblin.time = goblin.time + dt
        if goblin.state == goblin.STATES.IDLE and goblin.time > goblin.IDLE_TIME then
            goblin.time = 0
            goblin.state = goblin.STATES.RUN
            goblin.anim8:reset()
            goblin:set_anim('run')
        elseif goblin.state == goblin.STATES.RUN and goblin.time > goblin.RUN_TIME then
            goblin.state = goblin.STATES.ATTACK
            goblin.time = 0
            goblin.is_pushed = false
            goblin.anim8:reset()
            goblin:set_anim('attack')
        elseif goblin.state == goblin.STATES.ATTACK and goblin.time > goblin.ATTACK_TIME then
            goblin.time = 0
            goblin.state = goblin.STATES.IDLE
            goblin.anim8:reset()
            goblin:set_anim('idle')
        end
    end

    function goblin:handle_state(dt)
        if goblin.dead then
            return
        end

        if goblin.state == goblin.STATES.IDLE then
            goblin:idle()
        elseif goblin.state == goblin.STATES.RUN then
            goblin:run()
        elseif goblin.state == goblin.STATES.ATTACK then
            goblin:attack()
        end
    end

    function goblin:idle()
        local collider = goblin.collider.data
        local x, y = collider:getPosition()
        local w = goblin.hitbox.w or 0
        local h = goblin.hitbox.h or 0
        collider:setPosition(x, y)

        goblin.position.x = x - w / 2 + PLAYER_DATA.PADDING_X
        goblin.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        collider:setLinearVelocity(0, 0)
    end

    function goblin:run()
        local collider = goblin.collider.data
        local x, y = collider:getPosition()
        local _, vy = collider:getLinearVelocity()
        local w = goblin.hitbox.w or 0
        local h = goblin.hitbox.h or 0
        local dir = goblin.speed > 0 and 1 or -1

        local ground = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            goblin.position.x + goblin.hitbox.w / 2 + dir * (goblin.hitbox.w / 2 + 2),
            goblin.position.y + goblin.hitbox.h + 1,
            2,
            2,
            {"Solid"}
        )

        if #ground == 0 then
            goblin:flip()
        end

        if x <= w / 2 then
            x = w / 2
            goblin:flip()
        end
        
        if x >= GAME_DATA.MAX_X - w / 2 then
            x = GAME_DATA.MAX_X - w / 2
            goblin:flip()
        end
        
        collider:setPosition(x, y)

        goblin.position.x = x - w / 2 - PLAYER_DATA.PADDING_X
        goblin.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        collider:setLinearVelocity(goblin.speed, vy)

        if collider:enter('Wall') or collider:enter('Player') then
            goblin:flip()
        end

    end

    function goblin:attack()
        local collider = goblin.collider.data
        local x, y = collider:getPosition()
        local w = 22
        local h = 14
        local dir = goblin.speed > 0 and 1 or -1
        local sprite_x_offset = 5

        collider:setPosition(x, y)

        goblin.position.x = x - w / 2 + PLAYER_DATA.PADDING_X + dir * sprite_x_offset
        goblin.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        if not goblin.is_pushed then
            goblin.is_pushed = true
            collider:applyLinearImpulse(dir * goblin.attack_force, 0)
        end

        if collider:enter('Wall') or collider:enter('Player') then
            goblin:flip()
        end

        local sword = {}
        if dir > 0 then
            sword = WindfieldSystem.PhysicsWorld:queryRectangleArea(
                x + w / 2 - 3, y,
                3, 2,
                {"Player"})
        else
            sword = WindfieldSystem.PhysicsWorld:queryRectangleArea(
                x - w / 2 - 1,
                y,
                3,
                2,
                {"Player"}
            )
        end

        if #sword > 0 then
            local player = sword[1]:getObject()
            player:die()
        end
    end

    function goblin:hit()
        goblin.collider.data:setObject(nil)
        goblin.collider.data:destroy()
        goblin.dead = true
        goblin:remove('physics')
        goblin:set_anim('die')
    end

    return goblin
end