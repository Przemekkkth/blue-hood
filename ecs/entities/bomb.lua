return function(x, y, dir, world)
    local bomb = ECS.entity(world)

    bomb:give('position', x, y)
    bomb:give('hitbox', 8, 8)
    bomb:give('physics')
    bomb:give('sprite', assets.sprites.bomb, 0, 0)
    bomb.sprite.flipped_h = dir
    bomb:give('bomb')

    local g = anim8.newGrid(8, 8, assets.sprites.bomb:getWidth(), assets.sprites.bomb:getHeight())
    local g1 = anim8.newGrid(32, 32, assets.sprites.bomb:getWidth(), assets.sprites.bomb:getHeight())
    
    bomb:give('anim8', {
        throw = anim8.newAnimation(g("1-5", 1), 0.2, 'pauseAtEnd'),
        landing = anim8.newAnimation(g("1-3", 2), 0.1),
        explosion = anim8.newAnimation(g1("1-10", 2), 0.1),
    }, 'throw')

    function bomb:update(dt)
        
    end

    return bomb
end