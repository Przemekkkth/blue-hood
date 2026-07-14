return function()
    local function get_multiline_width(font, text)
        local max = 0
    
        for line in text:gmatch("[^\n]+") do
            max = math.max(max, font:getWidth(line))
        end
    
        return max
    end


    local hint = ECS.entity()
    hint:give('position', 0, 0)
    hint:give('physics')
    hint:give('hitbox', 16, 16)
    hint:give('hint')
    
    hint.text = ECS.entity()
    hint.text:give('position', 0, 0)
    hint.text:give('text', 'K ATTACK\nSPACE JUMP', FONT_x1)
    hint.text:give('HUD')

    function hint:set_hint_text(text)
        hint.text.text.data = text
    end

    function hint:update_hint_text_pos()
        local text = hint.text.text.data
    
        local width = get_multiline_width(FONT_x1, text)
    
        hint.text.position.x = hint.position.x + 8 - width / 2
        hint.text.position.y = hint.position.y - FONT_x1:getHeight() * 2 - 2
    end

    function hint:update(dt)
        local x = hint.position.x
        local y = hint.position.y
        local player_hits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            x,
            y,
            hint.hitbox.w,
            hint.hitbox.h,
            {'Player'}
        )
        if #player_hits > 0 then
            hint.text.text.visible = true
        else
            hint.text.text.visible = false
        end
    end

    return hint
end