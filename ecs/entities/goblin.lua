return function()
    local goblin = ECS.entity()

    goblin.ATTACK_TIME = 0.5
    goblin.DIE_TIME = 0.1
    goblin.IDLE_TIME = 0.8
    goblin.RUN_TIME = 2.0
    goblin.SIZE = 14
    goblin.STATES = {IDLE = 'IDLE', ATTACK = 'ATTACK', RUN = 'RUN'}

    goblin.attack_force = 15
    goblin.is_pushed = false
    goblin.speed = ENEMY_DATA.GOBLIN_SPEED
    goblin.state = goblin.STATES.IDLE
    goblin.time = 0

    goblin:give('position')
    goblin:give('hitbox', goblin.SIZE, goblin.SIZE)
    goblin:give('physics')
    goblin:give('sprite', assets.sprites.goblin)
    goblin:give('enemy')

    local frame_width, frame_height = 16, 16
    local bigger_frame_width = 24
    local g = anim8.newGrid(frame_width, frame_height, assets.sprites.goblin:getWidth(), assets.sprites.goblin:getHeight())
    local g1 = anim8.newGrid(bigger_frame_width, frame_height, assets.sprites.goblin:getWidth(), assets.sprites.goblin:getHeight())
    goblin:give('anim8', {
        run = anim8.newAnimation(g("1-6", 1), goblin.RUN_TIME / 12),
        die = anim8.newAnimation(g("1-6", 2), goblin.DIE_TIME, 'pauseAtEnd'),
        attack = anim8.newAnimation(g1("1-4", 3), goblin.ATTACK_TIME / 4, 'pauseAtEnd'),
        idle = anim8.newAnimation(g("1-4", 4), goblin.IDLE_TIME / 4),
    }, 'run')

  
    function goblin:set_anim(anim_name)
        goblin.anim8.name = anim_name
    end

    function goblin:flip()
        goblin.collider.data:setLinearVelocity(0, 0)
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

        collider:setPosition(x, y)

        goblin.position.x = x - goblin.SIZE / 2
        goblin.position.y = y - goblin.SIZE / 2 - PLAYER_DATA.PADDING_Y

        collider:setLinearVelocity(0, 0)
    end

    function goblin:run()
        local collider = goblin.collider.data
        local x, y = collider:getPosition()
        local _, vy = collider:getLinearVelocity()
        goblin:flip_if_not_collided_with_ground(goblin.SIZE)
        
        collider:setPosition(x, y)

        goblin.position.x = x - goblin.SIZE / 2
        goblin.position.y = y - goblin.SIZE / 2 - PLAYER_DATA.PADDING_Y

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
        goblin:flip_if_not_collided_with_ground(goblin.SIZE)

        goblin.position.x = x - w / 2 + PLAYER_DATA.PADDING_X + dir * sprite_x_offset
        goblin.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        if not goblin.is_pushed then
            goblin.is_pushed = true
            collider:applyLinearImpulse(dir * goblin.attack_force, 0)
        end

        if collider:enter('Wall') or collider:enter('Player') then
            goblin:flip()
        end
        
        local sword_width = 4
        local sword = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            x + dir * goblin.SIZE + (dir < 0 and 0 or -sword_width),
            y,
            sword_width,
            2,
            {"Player"}
        )

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

    function goblin:flip_if_not_collided_with_ground(w)
        local x, y = goblin.collider.data:getPosition()
        local dir = goblin.speed > 0 and 1 or -1
        local trigger_size = 2

        local ground = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            goblin.position.x + dir * goblin.SIZE + (dir < 0 and goblin.SIZE/2 + trigger_size or 0),
            goblin.position.y + goblin.hitbox.h + 1,
            trigger_size,
            trigger_size,
            {"Solid"}
        )

        if #ground == 0 then
            goblin:flip()
        end

        if x <= goblin.SIZE / 2 then
            x = goblin.SIZE / 2
            goblin:flip()
        end
        
        if x >= GAME_DATA.MAX_X - goblin.SIZE / 2 then
            x = GAME_DATA.MAX_X - goblin.SIZE / 2
            goblin:flip()
        end
    end

    return goblin
end