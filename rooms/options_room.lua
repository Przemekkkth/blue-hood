OptionsRoom = Object:extend()

function OptionsRoom:new()
    self.max_value = 20
	local textcolor = loveli.Property.parse(loveli.Color.parse(0xFFFFFFFF) )
    self.normal_color = loveli.Property.parse(loveli.Color.parse(0x1F0E0AFF))

    local font = loveli.Property.parse(FONT_x2)
    local sound_y = 30
    local screen_width = DRAW_WIDTH - 30
    local text_width = FONT_x2:getWidth("OPTIONS")

    local label = loveli.Label:new{x = (screen_width / 2 - text_width / 2), y = 0, width = "auto", height = "auto", text = "OPTIONS", font = font, textcolor = textcolor} 
    local sound_label  = loveli.Label:new{ x = 0, y = sound_y, width = DRAW_WIDTH/4, height = "auto", text = "SOUND", font = font, textcolor = textcolor, horizontaltextalignment = "center", verticaltextalignment = "center" } 
    local sound_slider = loveli.Slider:new{x = DRAW_WIDTH / 4, y = sound_y - 4, width = 3/5*DRAW_WIDTH, valuechanged = function(...) self:on_sound_slider_changed(...) end, value = 5, minimum = 0, maximum = 20, forecolor = textcolor, backgroundcolor = self.normal_color, bordercolor = textcolor }

    local music_y = 60
    local music_label  = loveli.Label:new{ x = 0, y = music_y, width = DRAW_WIDTH/4, height = "auto", text = "MUSIC", font = font, textcolor = textcolor, horizontaltextalignment = "center", verticaltextalignment = "center" } 
    local music_slider = loveli.Slider:new{x = DRAW_WIDTH / 4, y = music_y - 4, width = 3/5*DRAW_WIDTH, valuechanged = function(...) self:on_music_slider_changed(...) end, value = 5, minimum = 0, maximum = 20, forecolor = textcolor, backgroundcolor = self.normal_color, bordercolor = textcolor }

    local button_y = 120
    local button_w = 75
    self.button = loveli.Button:new{x = (screen_width / 2 - button_w / 2), y = button_y, clicked = function() self:on_button_pressed() end, text = "BACK", font = font, textcolor = textcolor, backgroundcolor = self.normal_color, bordercolor = textcolor, width = button_w, height = 23} 

    local absolutelayout = loveli.AbsoluteLayout:new{ width = screen_width, height = "*", margin = loveli.Thickness.parse(15) }
        :with(label)
        :with(sound_label)
        :with(sound_slider)
        :with(music_label)
        :with(music_slider)
        :with(self.button)

    local rootcontrol = absolutelayout

    self.layoutmanager = loveli.LayoutManager:new{}
    :with(rootcontrol)

    sound_slider:setvalue(GAME_DATA.AUDIO_VOLUME * self.max_value)
    music_slider:setvalue(GAME_DATA.MUSIC_VOLUME * self.max_value)
end

function OptionsRoom:update(dt)
    if self.layoutmanager.focusedcontrol == self.button and input:released('accept_action') then
        self:on_button_pressed()
    end

    self.layoutmanager:update(dt)
end

function OptionsRoom:draw()
    self.layoutmanager:draw()
end

function OptionsRoom:keypressed(key, scancode, isrepeat)
    self.layoutmanager:keypressed(key, scancode, isrepeat)
end

function OptionsRoom:on_sound_slider_changed(sender, oldvalue, newvalue)
    GAME_DATA.AUDIO_VOLUME = newvalue / self.max_value
end

function OptionsRoom:on_music_slider_changed(sender, oldvalue, newvalue)
    GAME_DATA.MUSIC_VOLUME = newvalue / self.max_value
    MUSIC:setVolume(GAME_DATA.MUSIC_VOLUME)
end

function OptionsRoom:on_button_pressed()
    go_to_room('TitleRoom')
end