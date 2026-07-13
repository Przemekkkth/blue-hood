SelectLevelRoom = Object:extend()

function SelectLevelRoom:new()
    self.text_color     = loveli.Property.parse(loveli.Color.parse(0xFFFFFFFF))
    self.normal_color   = loveli.Property.parse(loveli.Color.parse(0x1F0E0AFF))
    self.disabled_color = loveli.Property.parse(loveli.Color.parse(0x0FFF00FF))

    local screen_width = DRAW_WIDTH - 30
    local text_width = FONT_x2:getWidth("SELECT LEVEL")
    local button_w = 75
    local button_y = 125
    local first_row = 25
    
    local label = loveli.Label:new{x = (screen_width / 2 - text_width / 2), y = 0, width = "auto", height = "auto", text = "SELECT LEVEL", font = FONT_x2, textcolor = self.text_color} 
    self.back_btn = loveli.Button:new{x = (screen_width / 2 - button_w / 2), y = button_y, clicked = function() end, text = "BACK", font = FONT_x2, textcolor = self.text_color, backgroundcolor = self.normal_color, bordercolor = self.text_color, width = button_w, height = 23} 
    
    self.btn1 = loveli.Button:new{x = 0*32+16, y = first_row, clicked = function() end, text = "1", font = FONT_x2, textcolor = self.text_color, backgroundcolor = self.normal_color, bordercolor = self.text_color, width = 24, height = 24}
    self.btn2 = loveli.Button:new{x = 1*32+16, y = first_row, clicked = function() end, text = "2", font = FONT_x2, textcolor = self.text_color, backgroundcolor = self.normal_color, bordercolor = self.text_color, width = 24, height = 24}
    self.btn3 = loveli.Button:new{x = 2*32+16, y = first_row, clicked = function() end, text = "3", font = FONT_x2, textcolor = self.text_color, backgroundcolor = self.normal_color, bordercolor = self.text_color, width = 24, height = 24}
    self.btn4 = loveli.Button:new{x = 3*32+16, y = first_row, clicked = function() end, text = "4", font = FONT_x2, textcolor = self.text_color, backgroundcolor = self.normal_color, bordercolor = self.text_color, width = 24, height = 24}
    self.btn5 = loveli.Button:new{x = 4*32+16, y = first_row, clicked = function() end, text = "5", font = FONT_x2, textcolor = self.text_color, backgroundcolor = self.normal_color, bordercolor = self.text_color, width = 24, height = 24}

    local absolutelayout = loveli.AbsoluteLayout:new{ width = screen_width, height = "*", margin = loveli.Thickness.parse(15) }
      :with(label)
      :with(self.btn1)
      :with(self.btn2)
      :with(self.btn3)
      :with(self.btn4)
      :with(self.btn5)
      :with(self.back_btn)
    
    self.layoutmanager = loveli.LayoutManager:new{}:with(absolutelayout)
end

function SelectLevelRoom:update(dt)
    if self.layoutmanager.focusedcontrol == self.btn1 and input:released('accept_action') then
        self:select_level(1)
    elseif self.layoutmanager.focusedcontrol == self.btn2 and input:released('accept_action') then
        self:select_level(2)
    elseif self.layoutmanager.focusedcontrol == self.btn3 and input:released('accept_action') then
        self:select_level(3)
    elseif self.layoutmanager.focusedcontrol == self.btn4 and input:released('accept_action') then
        self:select_level(4)
    elseif self.layoutmanager.focusedcontrol == self.btn5 and input:released('accept_action') then
        self:select_level(5)
    elseif self.layoutmanager.focusedcontrol == self.back_btn and input:released('accept_action') then
        self:go_to_title_room()
    end

    self.layoutmanager:update(dt)
end

function SelectLevelRoom:draw()
    self.layoutmanager:draw()
end

function SelectLevelRoom:keypressed(key, scancode, isrepeat)
    self.layoutmanager:keypressed(key, scancode, isrepeat)
end

function SelectLevelRoom:select_level(n)
    GAME_DATA.LEVEL = n
    go_to_room("GameRoom")
end

function SelectLevelRoom:go_to_title_room()
    go_to_room("TitleRoom")
end