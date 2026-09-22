return function()
    local flying_bird = ECS.entity()

    flying_bird.FLY_TIME = 0.085
    flying_bird.SIZE = 8
    flying_bird.SPEED = -25

    flying_bird.speed = flying_bird.SPEED

    flying_bird:give('sprite', assets.sprites.fauna)
    flying_bird:give('hitbox', flying_bird.SIZE, flying_bird.SIZE)
    flying_bird:give('position')
    flying_bird:give('physics')
    flying_bird:give('fauna')

    local g = anim8.newGrid(flying_bird.SIZE, flying_bird.SIZE, assets.sprites.fauna:getWidth(), assets.sprites.fauna:getHeight())
    flying_bird:give('anim8', {
        fly = anim8.newAnimation(g("1-3", 2), flying_bird.FLY_TIME),
    }, 'fly')

    function flying_bird:update(dt)
        local collider = flying_bird.collider.data
        local x, y = collider:getPosition()

        if x <= flying_bird.SIZE / 2 then
            x = flying_bird.SIZE / 2
            flying_bird:flip()
        end
        
        if x >= GAME_DATA.MAX_X - flying_bird.SIZE / 2 then
            x = GAME_DATA.MAX_X - flying_bird.SIZE / 2
            flying_bird:flip()
        end
        
        collider:setPosition(x, y)

        flying_bird.position.x = x - flying_bird.SIZE / 2
        flying_bird.position.y = y - flying_bird.SIZE / 2

        collider:setLinearVelocity(flying_bird.speed, 0)

        if collider:enter('Wall') then
            flying_bird:flip()
        end
    end

    function flying_bird:flip()
        flying_bird.speed = -flying_bird.speed
        flying_bird.sprite.flipped_h = flying_bird.speed > 0
    end

    return flying_bird
end