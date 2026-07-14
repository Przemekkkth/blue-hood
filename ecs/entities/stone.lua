return function()
    local stone = ECS.entity()
    stone:give('position', 0, 0)
    stone:give('sprite', assets.sprites.stone, 0, 0)
    stone:give('hitbox', 16, 16)
    stone:give('physics')
    stone:give('stone')

    function stone:update(dt)
        local collider = stone.collider.data
        local x, y = collider:getPosition()
        x = math.floor(x)
        y = math.floor(y)

        local w = stone.hitbox.w or 0
        local h = stone.hitbox.h or 0

        stone.position.x = x - w / 2
        stone.position.y = y - h / 2
    end

    return stone
end