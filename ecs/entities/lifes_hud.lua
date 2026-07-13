return function()
    local lifes_icon = ECS.entity()
    lifes_icon:give('HUD')
    lifes_icon:give('position', DRAW_WIDTH - 30, DRAW_HEIGHT - 16)
    lifes_icon:give('sprite', assets.hud.lifes_icon)

    return lifes_icon
end