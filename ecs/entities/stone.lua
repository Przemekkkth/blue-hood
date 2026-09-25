return function()
    local stone = ECS.entity()

    stone.SIZE = 16

    stone:give('hitbox', stone.SIZE, stone.SIZE)
    stone:give('physics')
    stone:give('position')
    stone:give('sprite', assets.sprites.stone)
    stone:give('stone')

    function stone:update(dt)
        local collider = stone.collider.data
        local x, y = collider:getPosition()
        x = math.floor(x)
        y = math.floor(y)

        stone.position.x = x - stone.SIZE / 2
        stone.position.y = y - stone.SIZE / 2
    end

    return stone
end