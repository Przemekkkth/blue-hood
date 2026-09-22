return function(x, y, dir, world)
    local bomb = ECS.entity(world)

    bomb.EXPLOSION_SIZE = 32
    bomb.EXPLOSION_TIME = 1.0
    bomb.LANDING_TIME = 1.0
    bomb.SIZE = 8
    bomb.STATES = {THROWING = 'THROWING', LANDING = 'LANDING', EXPLOSION = 'EXPLOSION'}
    bomb.THROWING_FORCE = {x = 16, y = -8}
    bomb.THROWING_TIME = 1.0

    bomb.time = 0
    bomb.state = bomb.STATES.THROWING
    bomb.dead = false

    bomb:give('position', x, y)
    bomb:give('hitbox', 8, 8)
    bomb:give('physics')
    bomb:give('sprite', assets.sprites.bomb, 0, 0)
    bomb.sprite.flipped_h = dir
    bomb:give('bomb')
    bomb:give('collider', WindfieldSystem.PhysicsWorld:newRectangleCollider(x, y, bomb.hitbox.w, bomb.hitbox.h))
    local direction
    if dir == true then
        direction = -1
    else
        direction = 1
    end
    bomb.collider.data:applyLinearImpulse(direction * bomb.THROWING_FORCE.x, bomb.THROWING_FORCE.y)

    local g = anim8.newGrid(bomb.SIZE, bomb.SIZE, assets.sprites.bomb:getWidth(), assets.sprites.bomb:getHeight())
    local g1 = anim8.newGrid(bomb.EXPLOSION_SIZE, bomb.EXPLOSION_SIZE, assets.sprites.bomb:getWidth(), assets.sprites.bomb:getHeight())
    
    bomb:give('anim8', {
        throw = anim8.newAnimation(g("1-3", 1), bomb.THROWING_TIME / 3),
        landing = anim8.newAnimation(g("1-3", 2), bomb.LANDING_TIME / 3),
        explosion = anim8.newAnimation(g1("1-10", 2), bomb.EXPLOSION_TIME / 10, 'pauseAtEnd'),
    }, 'throw')

    function bomb:set_anim(anim_name)
        bomb.anim8.name = anim_name
    end

    function bomb:update(dt)
        bomb:update_state(dt)
        bomb:handle_state(dt)
    end

    function bomb:update_state(dt)
        bomb.time = bomb.time + dt

        if bomb.state == bomb.STATES.THROWING and bomb.time > bomb.THROWING_TIME then
            bomb.time = 0
            bomb.state = bomb.STATES.LANDING
            bomb:set_anim('landing')
            bomb.anim8:reset()
        elseif bomb.state == bomb.STATES.LANDING and bomb.time > bomb.LANDING_TIME then
            bomb.time = 0
            bomb.state = bomb.STATES.EXPLOSION
            bomb:set_anim('explosion')
            bomb.anim8:reset()
        end
    end

    function bomb:handle_state(dt)
        if bomb.dead then
            return
        end

        if bomb.state == bomb.STATES.THROWING then
            bomb:throw_or_land()
        elseif bomb.state == bomb.STATES.LANDING then
            bomb:throw_or_land()
        elseif bomb.state == bomb.STATES.EXPLOSION then
            bomb:explosion()
        end
    end

    function bomb:throw_or_land()
        local collider = bomb.collider.data
        local x, y = collider:getPosition()
        local y_offset = 1

        bomb.position.x = x - bomb.SIZE / 2
        bomb.position.y = y - bomb.SIZE / 2 + y_offset
    end

    function bomb:explosion()
        local x, y
        if bomb:has('collider') then
            local collider = bomb.collider.data
            x, y = collider:getPosition()
            collider:destroy()
            bomb:remove('collider')

            bomb.position.x = x - bomb.EXPLOSION_SIZE / 2
            bomb.position.y = y - bomb.EXPLOSION_SIZE + bomb.SIZE
            
            bomb:give('delayed_callback', function()
                bomb.sprite.visible = false
                bomb.dead = true
            end, bomb.EXPLOSION_TIME)
        end

        local explosion_offset = 8
        local explosion_hits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            bomb.position.x + explosion_offset,
            bomb.position.y + explosion_offset,
            2 * explosion_offset,
            2 * explosion_offset, {'Player'})

        if #explosion_hits > 0 then
            local player = explosion_hits[1]:getObject()
            player:hit()
        end
    end

    return bomb
end