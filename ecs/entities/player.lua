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

    function player:update(dt)
        local collider = player.collider.data
        local x, y = collider:getPosition()
        local w = player.hitbox.w or 0
        local h = player.hitbox.h or 0

        x = math.max(x, w / 2)
        x = math.min(x, GAME_DATA.MAX_X - w / 2)
        collider:setPosition(x, y)

        x = math.floor(x)
        y = math.floor(y)

        local vx, vy = collider:getLinearVelocity()

        player.position.x = x - w / 2 - PLAYER_DATA.PADDING_X
        player.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        local footW = w * 0.8
        local footH = 4
        local footX = x - footW / 2
        local footY = y + h / 2

        local groundHits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            footX,
            footY,
            footW,
            footH,
            {'Solid', 'Stone'}
        )

        local isGrounded = #groundHits > 0

        local accel = PLAYER_DATA.ACCELERATION
        local maxSpeed = PLAYER_DATA.SPEED

        if input:down('sprint') then
            maxSpeed = PLAYER_DATA.MAX_SPEED
        end

        if input:pressed('jump') and isGrounded then
            vy = -PHYSICS.PLAYER_JUMP_VELOCITY
            player:give('sfx', AUDIO_ID.HERO_JUMP)
            player:add_jump_dust()
        end

        if input:released('jump') and vy < 0 then
            vy = 0.5 * vy
        end

        if input:down('left') then
            vx = math.max(vx - accel, -maxSpeed)
                
        elseif input:down('right') then
            vx = math.min(vx + accel, maxSpeed)
        end

        -- facing
        if vx > 1.5 and input:down('right') then
            player.is_facing_right = true
            player.sprite.flipped_h = false
        elseif vx < -1.5 and input:down('left') then
            player.is_facing_right = false
            player.sprite.flipped_h = true
        end


        if input:pressed('attact') and not player:is_attack_anim() then
            local speed = 20
            if not player.is_facing_right then
                speed = -speed
            end

            vx = vx + speed
            player:set_anim('attack')
            player:give('sfx', AUDIO_ID.HERO_PUNCH)
        end

        -- animation
        if player:is_attack_anim() then
            local enemy_colliders = {}
            if player.is_facing_right then
                enemy_colliders = WindfieldSystem.PhysicsWorld:queryRectangleArea(x + w/2, y - 2, 3, 2, {'Enemy'})
            else
                enemy_colliders = WindfieldSystem.PhysicsWorld:queryRectangleArea(x - w/2 - 3, y - 2, 3, 2, {'Enemy'})
            end
            for _, collider in ipairs(enemy_colliders) do
                local enemy = collider:getObject()
                enemy:hit()
            end

            player:handle_attack_anim()
            return
        end

        if vy < 1 and not isGrounded then
            player:set_anim('jump')
        elseif vy >= 1 and not isGrounded then
            player:set_anim('fall')
        elseif math.abs(vx) > 1.5 then
            --ToDo: check rect width
            local right_hits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
                x + w / 2,
                y - h / 4,
                2,
                h / 2,
                {'Solid', 'Wall', 'Stone'}
            )

            local left_hits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
                x - w / 2 - 1,
                y - h / 4,
                2,
                h / 2,
                {'Solid', 'Wall', 'Stone'}
            )

            if #left_hits > 0 and vx < 0 then
                player:set_anim('push')
            elseif #right_hits > 0 and vx > 0 then
                player:set_anim('push')
            else
                player:set_anim('run')
            end
            
        elseif math.abs(vx) <= 1.5 then
            player:set_anim('idle') 
        end

        if isGrounded and not player.was_ground and vy > PLAYER_DATA.HARD_LANDING_SPEED then
            player:add_fall_dust()
        end
        
        player.was_ground = isGrounded

        collider:setLinearVelocity(vx, vy)
        collider:setPreSolve(function(collider_1, collider_2, contact)
            if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Orbs' then
                contact:setEnabled(false) 
                local orb = collider_2:getObject()
                orb:collected()
                
            end
        end)

        if collider:enter('Enemy') then
            player:give('sfx', AUDIO_ID.HERO_DAMAGE)
            player:hit()
        end

        if collider:enter('Hazard') then
            player:die()
        end
    end

    return player
end