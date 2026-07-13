return function()
    local door = ECS.entity()

    door:give('sprite', assets.sprites.door)
    door:give('position', 0, 0)

    return door
end