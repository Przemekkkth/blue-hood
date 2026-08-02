GameOverRoom = Object:extend()

function GameOverRoom:new()
    self.t = 0
    self.y = 100
    self.text_y = 0

    self.timer = Timer()
    self.show_text = false
    self.can_continue = false
    self.timer:after(2.0, function()
        self.can_continue = true
        self.timer:every(1.0, function()
            self.show_text = not self.show_text
        end)
    end)

    local g = anim8.newGrid(16, 16, assets.sprites.hero:getWidth(), assets.sprites.hero:getHeight())
    self.anim8 = anim8.newAnimation(g("1-3", 9), 0.5)

    MUSIC:stop()
    assets.audios[AUDIO_ID.GAME_OVER]:play()
    assets.audios[AUDIO_ID.GAME_OVER]:setVolume(GAME_DATA.AUDIO_VOLUME)
end

function GameOverRoom:update(dt)
    self.t = self.t + dt
    self.text_y = math.sin(self.t * 3) * 8
    self.timer:update(dt)
    self.anim8:update(dt)
    if input:pressed('accept_action') and self.can_continue then
        go_to_room('TitleRoom')
    end
end

function GameOverRoom:draw()
    self:draw_title()
    self:draw_continue_text()

    self.anim8:draw(assets.sprites.hero, DRAW_WIDTH / 2 - 80, DRAW_HEIGHT / 2 - 8)
    love.graphics.print("RESULT: "..GAME_DATA.ORBS, FONT_x2, DRAW_WIDTH / 2 - 48, DRAW_HEIGHT / 2 - 8)
end

function GameOverRoom:draw_title()
    local text = "GAME OVER"

    love.graphics.setColor(0, 0, 189/255, 1)
    centre_text(text, -1, 16 + self.text_y)
    centre_text(text, -1, 15 + self.text_y)
    centre_text(text, -1, 17 + self.text_y)
    centre_text(text, 1, 16 + self.text_y)
    centre_text(text, 1, 15 + self.text_y)
    centre_text(text, 1, 17 + self.text_y)
    
    centre_text(text, 0, 15 + self.text_y)
    centre_text(text, 0, 17 + self.text_y)
    love.graphics.setColor(1, 1, 1, 1)
    centre_text(text, 0, 16 + self.text_y)

    love.graphics.setColor(1, 1, 1, 1)
end

function GameOverRoom:draw_continue_text()
    if self.show_text then
        love.graphics.setFont(FONT_x2)
        local txt = "PRESS E TO CONTINUE..."
        local w = love.graphics.getFont():getWidth(txt) 
        love.graphics.print(txt, DRAW_WIDTH / 2, DRAW_HEIGHT - 20, 0, 1, 1, w / 2)
    end
end