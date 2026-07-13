return function()
    local orbs_hud = ECS.entity()
    orbs_hud:give('HUD')
    orbs_hud:give('position', 5, 20)
    orbs_hud:give('sprite', assets.hud.orbs_hud)

    return orbs_hud
end