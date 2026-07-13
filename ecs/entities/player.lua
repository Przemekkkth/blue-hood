return function()
    local player = ECS.entity()
    player:give('sprite', assets.sprites.hero, 0, 0)
    player.sprite.order = 10
    player.is_facing_right = true
    player.hearts = GAME_DATA.PLAYER_HEARTS
    player.hearts_huds = {}
    player.was_ground = true

    local g = anim8.newGrid(16, 16, assets.sprites.hero:getWidth(), assets.sprites.hero:getHeight())
    player:give('anim8', {
        idle = anim8.newAnimation(g("1-4", 6), 0.2),
        run = anim8.newAnimation(g("1-6", 2), 0.1),
        push = anim8.newAnimation(g("1-6", 3), 0.1),
        jump = anim8.newAnimation(g("1-3", 8), 0.2),
        fall = anim8.newAnimation(g("1-3", 7), 0.2), 
        hit = anim8.newAnimation(g("1-3", 9), 0.1), 
        attack = anim8.newAnimation(g("1-4", 4), 0.05, 'pauseAtEnd'), 
        die = anim8.newAnimation(g("1-9", 1), 0.065, 'pauseAtEnd'),

        slash = anim8.newAnimation(g("1-4", 15), 0.05, 'pauseAtEnd')
    }, 'idle')

    player:give('position', 100, 0)
    player:give('is_player')
    player:give('hitbox', 12, 14)
    player:give('physics')

    function player:set_anim(anim_name)
        if anim_name ~= player.anim8.name then
            player.anim8:reset()
        end
        player.anim8.name = anim_name
    end

    function player:is_idle_anim()
        return player.anim8.name == 'idle'
    end

    function player:is_run_anim()
        return player.anim8.name == 'run'
    end

    function player:is_attack_anim()
        return player.anim8.name == 'attack'
    end

    function player:handle_attack_anim()
        if player.anim8:is_last_frame() then
            player:set_anim('idle')
        end
    end

    function player:die()
        player:remove('physics')
        player:set_anim('die')
        player:give('sfx', AUDIO_ID.HERO_DEATH)
        player.collider.data:destroy()
        GAME_DATA.PLAYER_LIFES = GAME_DATA.PLAYER_LIFES - 1
        GAME_DATA.PLAYER_HEARTS = 3
    end

    function player:hit()
        if not player:has('invincible') then
            player.hearts_huds[player.hearts]:deactivate()
            player.hearts = player.hearts - 1
            GAME_DATA.PLAYER_HEARTS = GAME_DATA.PLAYER_HEARTS - 1
            if player.hearts <= 0 then
                player:die()
            else
                player:give('invincible')
                player:give('delayed_callback', function() player:remove('invincible') end, PLAYER_DATA.INVINCIBLE_TIME)
            end
        end
    end

    function player:bounce()
        if player.collider.data and not player.collider.data:isDestroyed() then
            local vx, vy = player.collider.data:getLinearVelocity()
            player.collider.data:setLinearVelocity(vx, -PLAYER_DATA.BOUNCE)
            player:give('sfx', AUDIO_ID.HERO_JUMP)
        end
    end

    function player:velocity()
        if player.collider.data and not player.collider.data:isDestroyed() then
            local vx, vy = player.collider.data:getLinearVelocity()
            return {x = vx, y = vy}
        else
            return {x = 0, y = 0}
        end
    end

    function player:add_jump_dust()
        local world = player:getWorld()
        local dust = ECS.entity(world)
        dust:give('delayed_callback', function() world:removeEntity(dust) end, 0.25)
        dust:give('sprite', assets.sprites.hero, 0, 0)
        dust.sprite.order = 20
        dust:give('anim8', { idle = anim8.newAnimation(g("1-4", 14), 0.05, 'pauseAtEnd') }, 'idle')
        dust:give('position', player.position.x, player.position.y)
    end

    function player:add_fall_dust()
        local world = player:getWorld()
        local dust = ECS.entity(world)
        dust:give('delayed_callback', function() world:removeEntity(dust) end, 0.25)
        dust:give('sprite', assets.sprites.hero, 0, 0)
        dust.sprite.order = 20
        dust:give('anim8', { idle = anim8.newAnimation(g("1-4", 13), 0.05, 'pauseAtEnd') }, 'idle')
        dust:give('position', player.position.x, player.position.y + 3)
    end

    return player
end