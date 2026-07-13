assets = {}

assets.sprites = {
    hero = love.graphics.newImage("assets/sprites/herochar_spritesheet.png"),
    stone = love.graphics.newImage("assets/sprites/stone.png"),
    mushroom = love.graphics.newImage("assets/sprites/mushroom_spritesheet.png"),
    door = love.graphics.newImage("assets/sprites/door.png"),
    spikes = love.graphics.newImage("assets/sprites/spikes.png"),
    orbs = love.graphics.newImage("assets/sprites/orbs_spritesheet.png"),
    torch = love.graphics.newImage("assets/sprites/tiki_torch_spritesheet.png")
}

assets.hud = {
    hearts_hud = love.graphics.newImage("assets/hud/hearts_hud.png"),
    no_hearts_hud = love.graphics.newImage("assets/hud/no_hearts_hud.png"),
    lifes_icon = love.graphics.newImage("assets/hud/lifes_icon.png"),
    orbs_hud   = love.graphics.newImage("assets/hud/orbs_hud.png"),
}

assets.backgrounds = {
    bg0 = love.graphics.newImage("assets/backgrounds/bg_0.png"),
    bg1 = love.graphics.newImage("assets/backgrounds/bg_1.png"),
}

assets.tilesets = {
    mainTileset = love.graphics.newImage("assets/tilesets/tileset.png")
}

assets.audios = {
    [AUDIO_ID.HERO_DAMAGE] = love.audio.newSource('assets/sfx/hero_damage.wav', 'static'),
    [AUDIO_ID.HERO_JUMP] = love.audio.newSource('assets/sfx/hero_jump.wav', 'static'),
    [AUDIO_ID.HERO_PUNCH] = love.audio.newSource('assets/sfx/hero_punch.wav', 'static'),
    [AUDIO_ID.HERO_DEATH] = love.audio.newSource('assets/sfx/hero_death.wav', 'static'),
    [AUDIO_ID.ORB_COLLECT] = love.audio.newSource('assets/sfx/orb_collect.wav', 'static')
}