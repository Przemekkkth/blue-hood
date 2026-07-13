return function()
    local stone = ECS.entity()
    stone:give('position', 0, 0)
    stone:give('sprite', assets.sprites.stone, 0, 0)
    stone:give('hitbox', 16, 16)
    stone:give('physics')
    stone:give('stone')
    return stone
end