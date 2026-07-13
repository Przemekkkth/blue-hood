return function()
    local background = ECS.entity()

    background:give('position', x, y)
    background:give('sprite', GET_BACKGROUND_SPRITE(), 0, 0)
    background:give('background')

    background.sprite.order = -1

    return background
end