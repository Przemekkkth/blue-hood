return function()
    local hearts_hud = ECS.entity()
    hearts_hud:give('HUD')
    hearts_hud:give('position', 2, 2)
    hearts_hud:give('sprite', assets.hud.hearts_hud)

    function hearts_hud:deactivate()
        hearts_hud.sprite.spritesheet = assets.hud.no_hearts_hud
    end

    return hearts_hud
end