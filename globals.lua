CELL_SIZE = 16
DRAW_WIDTH = 320
DRAW_HEIGHT = 180
DRAW_BUF = love.graphics.newCanvas(DRAW_WIDTH+16, DRAW_HEIGHT+16)
DRAW_SCALE = love.graphics.getWidth() / DRAW_WIDTH

WORLD_WIDTH = DRAW_WIDTH / CELL_SIZE
WORLD_HEIGHT = DRAW_HEIGHT / CELL_SIZE

VIEWPORT_Y = 0
VIEWPORT_BUF = love.graphics.newCanvas(DRAW_SCALE * DRAW_WIDTH, DRAW_SCALE * DRAW_HEIGHT)

local glyphs = ' ABCDEFGHIJKLMNOPQRSTUVWXYZ!?/0123456789'
FONT_x1 = love.graphics.newImageFont('assets/fonts/font_x1.png', glyphs) -- 7px
FONT_x2 = love.graphics.newImageFont('assets/fonts/font_x2.png', glyphs) -- 14px
DEBUG = false

GAME_DATA = {
    ORBS = 0,
    PLAYER_LIFES = 3,
    PLAYER_HEARTS = 3,
    LEVEL = 1,
    MAX_X = 0,
    MUSIC_VOLUME = 0.2,
    AUDIO_VOLUME = 0.8
}

function RESET_GAME_DATA()
    GAME_DATA.ORBS = 0
    GAME_DATA.PLAYER_LIFES = 3
    GAME_DATA.PLAYER_HEARTS = 3
end

PLAYER_DATA = {
    SPEED = 70,
    MAX_SPEED = 1.5 * 70,
    ACCELERATION = 2,
    PADDING_X = 2,
    PADDING_Y = 1,
    INVINCIBLE_TIME = 2.5,
    BOUNCE = 150,
    HARD_LANDING_SPEED = 150
}

ENEMY_DATA = {
    MUSHROOM_SPEED = 65
}

PHYSICS = {
    PLAYER_JUMP_TIME = 0.375, -- time from 0 to max y height
    PLAYER_HEIGHT = 40,
}

PHYSICS.GRAVITY =
    2 * PHYSICS.PLAYER_HEIGHT /
    (PHYSICS.PLAYER_JUMP_TIME * PHYSICS.PLAYER_JUMP_TIME)

PHYSICS.PLAYER_JUMP_VELOCITY =
    PHYSICS.GRAVITY * PHYSICS.PLAYER_JUMP_TIME


function GET_BACKGROUND_SPRITE()
    if GAME_DATA.LEVEL == 1 then
        return assets.backgrounds.bg0
    else
        return assets.backgrounds.bg1
    end
end

MUSIC_ID = {
    MENU = 'assets/music/miascizorr - aLL IS A LOOp III - 12 ttr6.wav',
    LEVEL = 'assets/music/miascizorr - aLL IS A LOOp III - 02 leker.wav'
}

MUSIC = love.audio.newSource(MUSIC_ID.MENU, 'stream')
MUSIC:setVolume(GAME_DATA.MUSIC_VOLUME)

AUDIO_ID = {
    HERO_DAMAGE = 'HERO_DAMAGE',
    HERO_JUMP = 'HERO_JUMP',
    HERO_PUNCH = 'HERO_PUNCH',
    HERO_DEATH = 'HERO_DEATH',
    ORB_COLLECT = 'ORB_COLLECT'
}