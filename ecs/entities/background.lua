return function()
    local background = ECS.entity()

    background:give('background')
    background:give('position')
    background:give('sprite', GET_BACKGROUND_SPRITE())
    background.sprite.order = -1

    return background
end