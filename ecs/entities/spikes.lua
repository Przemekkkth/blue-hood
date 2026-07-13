return function()
    local spikes = ECS.entity()
    spikes.padding = 2
    spikes:give('position', 0, 0)
    spikes:give('sprite', assets.sprites.spikes, 0, 0)
    spikes:give('hitbox', 16, 16)
    return spikes
end