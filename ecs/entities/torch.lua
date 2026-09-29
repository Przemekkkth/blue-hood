return function()
    local torch = ECS.entity()

    torch:give('position')
    torch:give('sprite', assets.sprites.torch)

    local frame_width, frame_height = 8, 24
    local g = anim8.newGrid(frame_width, frame_height, assets.sprites.torch:getWidth(), assets.sprites.torch:getHeight())
    torch:give('anim8', {
        idle = anim8.newAnimation(g("1-12", 1), 0.15) }, 'idle')
    
    return torch
end