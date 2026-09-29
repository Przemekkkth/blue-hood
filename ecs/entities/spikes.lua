return function()
    local spikes = ECS.entity()

    spikes.PADDING = 2
    spikes.SIZE = 16

    spikes:give('hitbox', spikes.SIZE, spikes.SIZE)
    spikes:give('position')
    spikes:give('sprite', assets.sprites.spikes)

    return spikes
end