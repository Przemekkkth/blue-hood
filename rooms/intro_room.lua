IntroRoom = Object:extend()

function IntroRoom:new()
    self.layoutmanager = loveli.LayoutManager:new{}
    :with(loveli.Border:new{ width = 300, height = 150, backgroundcolor = loveli.Color.parse(0x000000FF), margin = loveli.Thickness.parse(10) }
        :with(loveli.AnimatedLabel:new{y = 0, isplaying = true, duration = 10, elapsed = 0, font = FONT_x1, text = [[
            BEYOND THE MOUNTAINS, BEYOND THE FORESTS, IN A CERTAIN FORGOTTEN LAND, LIVES AN UNLIKELY HERO. HE DOESN'T WEAR A CAPE. HE WEARS A HOOD. A BLUE HOOD.
            
            UNFORTUNATELY, THE QUEST MARKET HAS BEEN RATHER... QUIET LATELY. WITH BARELY ANY JOBS TO TAKE, HIS COIN POUCH IS SHRINKING AT AN ALARMING RATE. LEFT WITH FEW OPTIONS, OUR BRAVE (OR PERHAPS SIMPLY DESPERATE) HERO DECIDES TO RISK HIS HEALTH AND POSSIBLY HIS LIFE BY VENTURING INTO THE MYSTERIOUS UNDERGROUND RUINS.
            
            LEGEND HAS IT THAT A GREAT TREASURE LIES HIDDEN SOMEWHERE BELOW. HOPEFULLY, THE LEGENDS ARE TRUE. IF FORTUNE SMILES UPON HIM, HE'LL FIND THE TREASURE, REFILL HIS EMPTY POCKETS, AND MAYBE, JUST MAYBE, GET HIS LIFE BACK ON TRACK.
            ]]
        , ismultiline = true, width = "*", height = "*", textcolor = loveli.Color.parse(0xFFFFFFFF) } )
    )
end

function IntroRoom:update(dt)
    self.layoutmanager:update(dt)
end

function IntroRoom:draw()
    self.layoutmanager:draw()
end
