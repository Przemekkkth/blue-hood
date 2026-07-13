WindfieldSystem = ECS.system({playerPool = {'is_player', 'physics'}, enemyPool = {'enemy', 'physics'}, 
                              doorPool = {'door', 'physics'}, stonePool = {'stone', 'physics'},
                              hintPool = {'hint', 'physics'}})
WindfieldSystem.PhysicsWorld = nil
WindfieldSystem.Gravity = {x = 0, y = PHYSICS.GRAVITY}

function WindfieldSystem:init(world)
    if WindfieldSystem.PhysicsWorld == nil then
        error('WindfieldSystem.PhysicsWorld is nil')
    end

    WindfieldSystem.PhysicsWorld:setGravity(
        WindfieldSystem.Gravity.x, WindfieldSystem.Gravity.y)
end

function WindfieldSystem:update(dt)
    WindfieldSystem.PhysicsWorld:update(dt)

    for _, player in ipairs(self.playerPool) do
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
            break
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

    for _, enemy in ipairs(self.enemyPool) do
        local collider = enemy.collider.data
        local x, y = collider:getPosition()
        local vx, vy = collider:getLinearVelocity()
        local w = enemy.hitbox.w or 0
        local h = enemy.hitbox.h or 0
        local dir = enemy.speed > 0 and 1 or -1

        local ground = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            enemy.position.x + enemy.hitbox.w / 2 + dir * (enemy.hitbox.w / 2 + 2),
            enemy.position.y + enemy.hitbox.h + 1,
            2,
            2,
            {"Solid"}
        )

        if #ground == 0 then
            enemy:flip()
        end

        if x <= w / 2 then
            x = w / 2
            enemy:flip()
        end
        
        if x >= GAME_DATA.MAX_X - w / 2 then
            x = GAME_DATA.MAX_X - w / 2
            enemy:flip()
        end
        
        collider:setPosition(x, y)

        enemy.position.x = x - w / 2 - PLAYER_DATA.PADDING_X
        enemy.position.y = y - h / 2 - PLAYER_DATA.PADDING_Y

        collider:setLinearVelocity(enemy.speed, vy)

        if collider:enter('Wall') or collider:enter('Player') then
            enemy:flip()
        end

        local top_collider = WindfieldSystem.PhysicsWorld:queryRectangleArea(enemy.position.x + 3, enemy.position.y - 2, enemy.hitbox.w - 2, 2, {'Player'})
        if #top_collider > 0 and self.playerPool[1]:velocity().y > 0 then
            enemy:smashed()
            self.playerPool[1]:bounce()
        end

        if enemy.dead then
            collider:destroy()
        end
    end

    for _, door in ipairs(self.doorPool) do
        local player_hits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            door.position.x + 10,
            door.position.y + 10,
            5,
            5,
            {'Player'}
        )

        if #player_hits > 0 then
            GAME_DATA.LEVEL = GAME_DATA.LEVEL + 1
            GameRoom.STATE = GameRoom.STATES.RESTART
        end
    end

    for _, stone in ipairs(self.stonePool) do
        local collider = stone.collider.data
        local x, y = collider:getPosition()
        x = math.floor(x)
        y = math.floor(y)

        local w = stone.hitbox.w or 0
        local h = stone.hitbox.h or 0

        stone.position.x = x - w / 2
        stone.position.y = y - h / 2
    end

    for _, hint in ipairs(self.hintPool) do
        local x = hint.position.x
        local y = hint.position.y
        local player_hits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            x,
            y,
            hint.hitbox.w,
            hint.hitbox.h,
            {'Player'}
        )
        if #player_hits > 0 then
            hint.text.text.visible = true
        else
            hint.text.text.visible = false
        end
    end
end