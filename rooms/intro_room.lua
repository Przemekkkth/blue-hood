IntroRoom = Object:extend()

function IntroRoom:new()
    local animation_time = 10

    self.layoutmanager = loveli.LayoutManager:new{}
    :with(loveli.Border:new{ width = 300, height = 150, backgroundcolor = loveli.Color.parse(0x000000FF), margin = loveli.Thickness.parse(10) }
        :with(loveli.AnimatedLabel:new{y = 0, isplaying = true, duration = animation_time, elapsed = 0, font = FONT_x1, text = [[
            BEYOND THE MOUNTAINS, BEYOND THE FORESTS, IN A CERTAIN FORGOTTEN LAND, LIVES AN UNLIKELY HERO. HE DOESN'T WEAR A CAPE. HE WEARS A HOOD. A BLUE HOOD.
            
            UNFORTUNATELY, THE QUEST MARKET HAS BEEN RATHER... QUIET LATELY. WITH BARELY ANY JOBS TO TAKE, HIS COIN POUCH IS SHRINKING AT AN ALARMING RATE. LEFT WITH FEW OPTIONS, OUR BRAVE (OR PERHAPS SIMPLY DESPERATE) HERO DECIDES TO RISK HIS HEALTH AND POSSIBLY HIS LIFE BY VENTURING INTO THE MYSTERIOUS UNDERGROUND RUINS.
            
            LEGEND HAS IT THAT A GREAT TREASURE LIES HIDDEN SOMEWHERE BELOW. HOPEFULLY, THE LEGENDS ARE TRUE. IF FORTUNE SMILES UPON HIM, HE'LL FIND THE TREASURE, REFILL HIS EMPTY POCKETS, AND MAYBE, JUST MAYBE, GET HIS LIFE BACK ON TRACK.
            ]]
        , ismultiline = true, width = "*", height = "*", textcolor = loveli.Color.parse(0xFFFFFFFF) } )
    )

    self.timer = Timer()
    self.show_text = false
    self.can_continue = false
    self.timer:after(10.0, function()
        self.can_continue = true
        self.timer:every(1.0, function()
            self.show_text = not self.show_text
        end) 
    end)

    local interval_time = 0.25
    for i = 1, math.floor(animation_time / interval_time), 1 do
        self.timer:after(i * interval_time, function()
            assets.audios[AUDIO_ID.KEY_PRESSED]:stop()
            assets.audios[AUDIO_ID.KEY_PRESSED]:setVolume(GAME_DATA.AUDIO_VOLUME)
            assets.audios[AUDIO_ID.KEY_PRESSED]:play()
        end)
    end
end

function IntroRoom:update(dt)
    self.layoutmanager:update(dt)
    self.timer:update(dt)
    if self.can_continue and input:pressed('accept_action') then
        GAME_DATA.LEVEL = 1
        go_to_room("GameRoom")
    end
end

function IntroRoom:draw()
    self.layoutmanager:draw()
    if self.show_text then
        love.graphics.setFont(FONT_x2)
        local txt = "PRESS E TO CONTINUE..."
        local w = love.graphics.getFont():getWidth(txt) 
        love.graphics.print(txt, DRAW_WIDTH / 2, DRAW_HEIGHT - 20, 0, 1, 1, w / 2)
    end
end