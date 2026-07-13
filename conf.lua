function love.conf(t)
    t.identity = "blue_hood"
    t.window.title = "Blue Hood"
    t.window.icon = "assets/sprites/icon.png"
    t.window.width = 320 
    t.window.height = 180 
    t.window.vsync = 0
    --t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    
    t.console = false
    t.modules.physics = true
end