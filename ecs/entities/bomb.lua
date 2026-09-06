return function(x, y, dir, world)
    local bomb = ECS.entity(world)
    bomb.THROW_FORCE = {x = 16, y = -8}

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
        landing = anim8.newAnimation(g("1-3", 2), 0.1),
        explosion = anim8.newAnimation(g1("1-10", 2), 0.1),
    }, 'throw')

    function bomb:update(dt)
        local collider = bomb.collider.data
        local x, y = collider:getPosition()
        local w = bomb.hitbox.w or 0
        local h = bomb.hitbox.h or 0

        bomb.position.x = x - w / 2
        bomb.position.y = y - h / 2
    end

    return bomb
end