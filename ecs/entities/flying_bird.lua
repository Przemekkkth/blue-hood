return function()
    local flying_bird = ECS.entity()
    flying_bird:give('sprite', assets.sprites.fauna, 0, 0)
    flying_bird:give('hitbox', 8, 7)
    flying_bird:give('position', 0, 0)
    flying_bird:give('physics')
    flying_bird:give('fauna')

    local g = anim8.newGrid(8, 8, assets.sprites.fauna:getWidth(), assets.sprites.fauna:getHeight())
    flying_bird:give('anim8', {
        fly = anim8.newAnimation(g("1-3", 2), 0.085),
    }, 'fly')
    
    flying_bird.SPEED = -25
    flying_bird.speed = flying_bird.SPEED


    function flying_bird:update(dt)
        local collider = flying_bird.collider.data
        local x, y = collider:getPosition()
        local w = flying_bird.hitbox.w or 0
        local h = flying_bird.hitbox.h or 0

        if x <= w / 2 then
            x = w / 2
            flying_bird:flip()
        end
        
        if x >= GAME_DATA.MAX_X - w / 2 then
            x = GAME_DATA.MAX_X - w / 2
            flying_bird:flip()
        end
        
        collider:setPosition(x, y)

        flying_bird.position.x = x - w / 2
        flying_bird.position.y = y - h / 2

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