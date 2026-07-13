TitleRoom = Menu:extend()

function TitleRoom:new()
    TitleRoom.super.new(self)
    self.t = 0
    self.y = 100
    self.text_y = 0

    MUSIC:stop()
    MUSIC = love.audio.newSource(MUSIC_ID.MENU, 'stream')
    MUSIC:setVolume(GAME_DATA.MUSIC_VOLUME)
    MUSIC:play()

    local continue_element = TextMenuElement("CONTINUE"):disable()
    self:add_element(continue_element)
    
    local new_game_element = TextMenuElement("NEW GAME", function()
        go_to_room("SelectLevelRoom")
    end)
    self:add_element(new_game_element)

    local options_element = TextMenuElement("OPTIONS", function()
        go_to_room("OptionsRoom")
    end)
    self:add_element(options_element)

    local quit_element = TextMenuElement("QUIT", function()
        love.event.quit()
    end)
    self:add_element(quit_element)

    self.current = 2
end

function TitleRoom:update(dt)
    TitleRoom.super.update(self, dt)

    self.t = self.t + dt
    self.text_y = math.sin(self.t * 3) * 8
end

function TitleRoom:draw()
    local text = "BLUE HOOD"

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
    
    TitleRoom.super.draw(self)
    love.graphics.setColor(1, 1, 1, 1)
end