return function()
    local torch = ECS.entity()
    torch:give('position', 0, 0)
    torch:give('sprite', assets.sprites.torch)
    local g = anim8.newGrid(8, 24, assets.sprites.torch:getWidth(), assets.sprites.torch:getHeight())
    torch:give('anim8', {
        idle = anim8.newAnimation(g("1-12", 1), 0.15) }, 'idle')
    
    return torch
end