return function(x, y, dir, world)
    local bomb = ECS.entity(world)
    bomb.THROW_FORCE = {x = 16, y = -8}
    bomb.THROW_TIME = 3.0
    bomb.LANDING_TIME = 2.0
    bomb.EXPLOSION_TIME = 1.0
    bomb.STATES = {THROW = 'THROW', LANDING = 'LANDING', EXPLOSION = 'EXPLOSION'}

    bomb.time = 0
    bomb.state = bomb.STATES.THROW
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
    bomb.collider.data:applyLinearImpulse(direction * bomb.THROW_FORCE.x, bomb.THROW_FORCE.y)

    local g = anim8.newGrid(8, 8, assets.sprites.bomb:getWidth(), assets.sprites.bomb:getHeight())
    local g1 = anim8.newGrid(32, 32, assets.sprites.bomb:getWidth(), assets.sprites.bomb:getHeight())
    
    bomb:give('anim8', {
        throw = anim8.newAnimation(g("1-3", 1), 0.2),
        landing = anim8.newAnimation(g("1-3", 2), 0.2),
        explosion = anim8.newAnimation(g1("1-10", 2), 0.1),
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

        if bomb.state == bomb.STATES.THROW and bomb.time > bomb.THROW_TIME then
            bomb.time = 0
            bomb.state = bomb.STATES.LANDING
            bomb:set_anim('landing')
            bomb.anim8:reset()
        elseif bomb.state == bomb.STATES.LANDING and bomb.time > bomb.LANDING_TIME then
            bomb.time = 0
            bomb.state = bomb.STATES.EXPLOSION
            bomb:set_anim('explosion')
            bomb.anim8:reset()
        elseif bomb.state == bomb.STATES.EXPLOSION and bomb.time > bomb.EXPLOSION_TIME then
            bomb.time = 0

        end
    end

    function bomb:handle_state(dt)
        if bomb.dead then
            return
        end

        if bomb.state == bomb.STATES.THROW then
            bomb:throw()
        elseif bomb.state == bomb.STATES.LANDING then
            bomb:landing()
        elseif bomb.state == bomb.STATES.EXPLOSION then
            bomb:explosion()
        end
    end

    function bomb:throw()
        local collider = bomb.collider.data
        local x, y = collider:getPosition()
        local w = bomb.hitbox.w or 0
        local h = bomb.hitbox.h or 0

        bomb.position.x = x - w / 2
        bomb.position.y = y - h / 2
    end

    function bomb:landing()
        local collider = bomb.collider.data
        local x, y = collider:getPosition()
        local w = bomb.hitbox.w or 0
        local h = bomb.hitbox.h or 0

        bomb.position.x = x - w / 2
        bomb.position.y = y - h / 2
    end

    function bomb:explosion()
        local x, y
        if bomb:has('physics') then
            local collider = bomb.collider.data
            x, y = collider:getPosition()
            bomb:remove('physics')
            collider:destroy()
            bomb:remove('collider')
            bomb.position.x = x - 16
            bomb.position.y = y - 27
        end


    end

    return bomb
end