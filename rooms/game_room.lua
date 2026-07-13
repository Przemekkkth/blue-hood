GameRoom = Object:extend()

GameRoom.STATES = {GAME = 'game', MENU = 'menu', RESTART = 'restart'}
GameRoom.STATE = GameRoom.STATES.GAME

function GameRoom:new()
    GameRoom.STATE = GameRoom.STATES.GAME
    self.physics_world = wf.newWorld(0, 0, true)
    self.physics_world:addCollisionClass('Player')
    self.physics_world:addCollisionClass('Solid')
    self.physics_world:addCollisionClass('Wall')
    self.physics_world:addCollisionClass('Door')
    self.physics_world:addCollisionClass('Enemy')
    self.physics_world:addCollisionClass('Hazard')
    self.physics_world:addCollisionClass('Stone')
    self.physics_world:addCollisionClass("Orbs", {ignores = {'Enemy', 'Stone'}})
    self.physics_world:setQueryDebugDrawing(true)

    WindfieldSystem.PhysicsWorld = self.physics_world
    self.tile_map = TileMap('levels/level'..GAME_DATA.LEVEL..'.lua')
    self.tile_map:add_walls_to_world(self.physics_world)
    self.tile_map:add_solid_to_world(self.physics_world)

    self.world = ECS.world()

    self.camera = Camera(DRAW_WIDTH, DRAW_HEIGHT)
    self.camera.min_x = 0
    self.camera.min_y = 0
    self.camera.max_x = self.tile_map.width * self.tile_map.tile_size
    self.camera.max_y = self.tile_map.height * self.tile_map.tile_size
    CameraSystem.camera = self.camera

    self.tile_map:add_door_to_world(self.world)

    self.tile_map:add_torches_to_world(self.world)

    self.tile_map:add_enemies_to_world(self.world)

    self.tile_map:add_spikes_to_world(self.world)

    self.tile_map:add_stones_to_world(self.world)

    self.tile_map:add_hints_to_world(self.world)

    self:create_hud()

    self.player = require 'ecs.entities.player'()
    local player_x, player_y = self.tile_map:get_player_pos()
    self.player:give('position', player_x, player_y)
    self.player:give('collider', self.physics_world:newBSGRectangleCollider(player_x, player_y, self.player.hitbox.w, self.player.hitbox.h, 3))
    self.player.collider.data:setCollisionClass('Player')
    self.world:addEntity(self.player)
    table.insert(self.player.hearts_huds, self.hearts_hud0)
    table.insert(self.player.hearts_huds, self.hearts_hud1)
    table.insert(self.player.hearts_huds, self.hearts_hud2)

    self:create_background()

    self.tile_map:add_orbs_to_world(self.world)
    self.world:addSystems(Anim8System, DrawSystem, WindfieldSystem, CameraSystem, TimerSystem, SFXSystem)

    MUSIC:stop()
    MUSIC = love.audio.newSource(MUSIC_ID.LEVEL, 'stream')
    MUSIC:setVolume(GAME_DATA.MUSIC_VOLUME)
    MUSIC:play()
end

function GameRoom:update(dt)
    self.world:emit('update', dt)

    self.orbs_text.text.data = tostring(GAME_DATA.ORBS)
    self.lifes_text.text.data = tostring(GAME_DATA.PLAYER_LIFES)

    if GameRoom.STATE == GameRoom.STATES.RESTART then
        go_to_room('GameRoom')
    elseif GameRoom.STATE == GameRoom.STATES.MENU then
        go_to_room('TitleRoom')
    end
end

function GameRoom:draw()
    if CameraSystem.camera then
        CameraSystem.camera:attach()
    end
    
    self.world:emit('draw_background')
    self.tile_map:draw_layer('miscellaneus')
    self.world:emit('draw')
    self.tile_map:draw_layer('foreground')
    

    if DEBUG then
        self.physics_world:draw()
    end

    if CameraSystem.camera then
        CameraSystem.camera:detach()
    end

    self.world:emit('draw_HUD')
end

function GameRoom:create_hud()
    local orbs_hud = require 'ecs.entities.orbs_hud'()
    self.world:addEntity(orbs_hud)
    self.orbs_text = ECS.entity()
    self.orbs_text:give('text', tostring(GAME_DATA.ORBS), FONT_x2, 10)
    self.orbs_text:give('position', orbs_hud.position.x + 12, orbs_hud.position.y - 3)
    self.orbs_text:give('HUD')
    self.world:addEntity(self.orbs_text)

    self.hearts_hud0 = require 'ecs.entities.hearts_hud'()
    self.world:addEntity(self.hearts_hud0)
    self.hearts_hud1 = require 'ecs.entities.hearts_hud'()
    self.hearts_hud1.position.x = self.hearts_hud0.position.x + 18
    if GAME_DATA.PLAYER_HEARTS < 2 then
        self.hearts_hud1:deactivate()
    end
    self.world:addEntity(self.hearts_hud1)
    self.hearts_hud2 = require 'ecs.entities.hearts_hud'()
    self.hearts_hud2.position.x = self.hearts_hud1.position.x + 18
    if GAME_DATA.PLAYER_HEARTS < 3 then
        self.hearts_hud2:deactivate()
    end
    self.world:addEntity(self.hearts_hud2)

    local lifes_icon = require 'ecs.entities.lifes_hud'()
    self.world:addEntity(lifes_icon)
    self.lifes_text = ECS.entity()
    self.lifes_text:give('text', tostring(GAME_DATA.PLAYER_LIFES), FONT_x2, 9)
    self.lifes_text:give('position', lifes_icon.position.x + 16, lifes_icon.position.y + 1)
    self.lifes_text:give('HUD')
    self.world:addEntity(self.lifes_text)
end

function GameRoom:create_background()
    local x = self.camera.max_x / GET_BACKGROUND_SPRITE():getWidth()
    local y = self.camera.max_y / GET_BACKGROUND_SPRITE():getHeight()

    for i = 0, y, 1 do
        for j = 0, x, 1 do
            local background = require 'ecs.entities.background'()
            background.position.x = j * GET_BACKGROUND_SPRITE():getWidth()
            background.position.y = i * GET_BACKGROUND_SPRITE():getHeight()
            self.world:addEntity(background)
        end
    end
end

function GameRoom:destroy()
    self.physics_world:destroy()
    self.physics_world = nil
    self.world:clear()
    self.world = nil
    self.player = nil

    package.loaded['ecs.entities.player'] = nil
    package.loaded['ecs.entities.mushroom'] = nil
    package.loaded['ecs.entities.background'] = nil
end