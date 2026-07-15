DrawSystem = ECS.system({pool = {'position', 'sprite'}, text_pool = {'text'}, hud_pool = {'HUD'}, background_pool = {'background'}} )

function DrawSystem:draw()
    for _, entity in ipairs(self.pool) do
        if not entity:has('HUD') and not entity:has('background') then
            local x = math.floor(entity.position.x)
            local y = math.floor(entity.position.y)

            local sprite = entity.sprite.spritesheet

            if entity:has('anim8') then
                local anim_name = entity.anim8.name
                local frame_w, frame_h = entity.anim8.animations[anim_name]:getDimensions()
                local should_draw = true

                if entity:has('invincible') and math.floor(love.timer.getTime() * 10) % 2 == 0 then
                    should_draw = false
                end

                if entity.sprite.flipped_h and should_draw then    
                    entity.anim8.animations[anim_name]:draw(sprite, x, y, 0, -1, 1, frame_w, 0)
                elseif entity.sprite.flipped_v and should_draw then
                    entity.anim8.animations[anim_name]:draw(sprite, x, y, 0, 1, -1, 0, frame_h)
                elseif should_draw then
                    entity.anim8.animations[anim_name]:draw(sprite, x, y)
                end

            else
                local x = math.floor(entity.position.x)
                local y = math.floor(entity.position.y)
                if entity.sprite.flipped_v then
                    love.graphics.draw(sprite, x, y, 0, 1, -1, 0, sprite:getHeight())
                else
                    love.graphics.draw(sprite, x, y)
                end
            end
        end
    end

    for _, entity in ipairs(self.text_pool) do
        if not entity:has('HUD') then
            local x = math.floor(entity.position.x)
            local y = math.floor(entity.position.y)
            if entity.text.visible then
                love.graphics.setFont(entity.text.font)
                love.graphics.print(entity.text.data, x, y)
            end
        end
    end
end

function DrawSystem:draw_HUD()
    for _, entity in ipairs(self.hud_pool) do
        local x = math.floor(entity.position.x)
        local y = math.floor(entity.position.y)
        if entity:has('sprite') then
            local sprite = entity.sprite.spritesheet
            love.graphics.draw(sprite, x, y)
        elseif entity:has('text') then
            love.graphics.setFont(entity.text.font)
            if entity.text.visible then
                love.graphics.print(entity.text.data, x, y)
            end
        end
    end
end

function DrawSystem:draw_background()
    for _, entity in ipairs(self.background_pool) do
        local x = math.floor(entity.position.x)
        local y = math.floor(entity.position.y)
        local sprite = entity.sprite.spritesheet
        love.graphics.draw(sprite, x, y)
    end
end