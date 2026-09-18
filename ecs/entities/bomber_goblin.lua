return function()
    local bomber_goblin = ECS.entity()
    bomber_goblin.STATES = {IDLE = 'IDLE', ATTACK = 'ATTACK'}
    bomber_goblin.state = bomber_goblin.STATES.IDLE
    bomber_goblin.IDLE_TIME = 0.4
    bomber_goblin.ATTACK_TIME = 3.5
    bomber_goblin.THROWING_BOMB_FRAME = 5
    bomber_goblin.time = 0
    bomber_goblin.is_bomb_thrown = false

    bomber_goblin:give('position', 0, 0)
    bomber_goblin:give('hitbox', 14, 14)
    bomber_goblin:give('physics')
    bomber_goblin:give('sprite', assets.sprites.bomber_goblin, 0, 0)
    bomber_goblin.sprite.flipped_h = true

    bomber_goblin:give('enemy')

    local g = anim8.newGrid(16, 16, assets.sprites.bomber_goblin:getWidth(), assets.sprites.bomber_goblin:getHeight())
    
    bomber_goblin:give('anim8', {
        attack = anim8.newAnimation(g("1-6", 1), 0.6),
        die = anim8.newAnimation(g("1-6", 2), 0.2, 'pauseAtEnd'),
        idle = anim8.newAnimation(g("1-3", 3), 0.1),
    }, 'idle')
  
    function bomber_goblin:set_anim(anim_name)
        bomber_goblin.anim8.name = anim_name
    end

    function bomber_goblin:flip()
        bomber_goblin.sprite.flipped_h = not bomber_goblin.sprite.flipped_h
    end

    function bomber_goblin:update(dt)
        bomber_goblin:update_state(dt)
        bomber_goblin:handle_state(dt)
    end

    function bomber_goblin:update_state(dt)
        bomber_goblin.time = bomber_goblin.time + dt
        if bomber_goblin.state == bomber_goblin.STATES.IDLE and bomber_goblin.time > bomber_goblin.IDLE_TIME then
            bomber_goblin.time = 0
            bomber_goblin.state = bomber_goblin.STATES.ATTACK
            bomber_goblin:set_anim('attack')
            bomber_goblin.anim8:reset()
        elseif bomber_goblin.state == bomber_goblin.STATES.ATTACK and bomber_goblin.time > bomber_goblin.ATTACK_TIME then
            bomber_goblin.state = bomber_goblin.STATES.IDLE
            bomber_goblin.time = 0
            bomber_goblin:set_anim('idle')
            bomber_goblin.anim8:reset()
            bomber_goblin.is_bomb_thrown = false
        end
    end

    function bomber_goblin:handle_state(dt)
        if bomber_goblin.dead then
            return
        end

        if bomber_goblin.state == bomber_goblin.STATES.IDLE then
            bomber_goblin:idle()
        elseif bomber_goblin.state == bomber_goblin.STATES.ATTACK then
            bomber_goblin:attack()
        end
    end

    function bomber_goblin:idle()
        local collider = bomber_goblin.collider.data
        local x, y = collider:getPosition()
        local w = bomber_goblin.hitbox.w or 0
        local h = bomber_goblin.hitbox.h or 0
        collider:setPosition(x, y)

        bomber_goblin.position.x = x - w / 2 + PLAYER_DATA.PADDING_X
        bomber_goblin.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        collider:setLinearVelocity(0, 0)
    end

    function bomber_goblin:attack()
        bomber_goblin:focus_on_player()
        if bomber_goblin.anim8:get_position() == bomber_goblin.THROWING_BOMB_FRAME and not bomber_goblin.is_bomb_thrown then
            bomber_goblin.is_bomb_thrown = true
            bomber_goblin:create_bomb()
        end
    end

    function bomber_goblin:hit()
        bomber_goblin.collider.data:setObject(nil)
        bomber_goblin.collider.data:destroy()
        bomber_goblin.dead = true
        bomber_goblin:remove('physics')
        bomber_goblin:set_anim('die')
    end

    function bomber_goblin:focus_on_player()
        local w = 14
        if WindfieldSystem.PlayerPos.x + w < bomber_goblin.position.x then
            bomber_goblin.sprite.flipped_h = true
        elseif WindfieldSystem.PlayerPos.x + w > bomber_goblin.position.x + w then
            bomber_goblin.sprite.flipped_h = false
        end
    end

    function bomber_goblin:create_bomb()
        local offset_x = 0
        if bomber_goblin.sprite.flipped_h then
            offset_x = 6
        end

        require 'ecs.entities.bomb'(bomber_goblin.position.x + offset_x, bomber_goblin.position.y - 8, bomber_goblin.sprite.flipped_h, bomber_goblin:getWorld())
    end

    return bomber_goblin
end