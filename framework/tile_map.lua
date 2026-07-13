TileMap = Object:extend()

function TileMap:new(tile_map_path)
    self:load_tile_map(tile_map_path)

    self.width = self.map.width
    self.height = self.map.height
    self.tile_size = self.map.tilewidth
    GAME_DATA.MAX_X = self.width * self.tile_size
end

function TileMap:update(dt)
    
end

function TileMap:draw()
    
end

function TileMap:load_tile_map(tile_map_path)
    self.map = sti(tile_map_path)
end

function TileMap:add_solid_to_world(world)
    local object_layer = self.map.layers['solid']
    for _, obj in ipairs(object_layer.objects) do
        local box = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        box:setCollisionClass('Solid')
        box:setType('static')
    end
end

function TileMap:add_walls_to_world(world)
    local object_layer = self.map.layers['walls']
    for _, obj in ipairs(object_layer.objects) do
        local box = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        box:setCollisionClass('Wall')
        box:setFriction(0.0)
        box:setType('static')
    end
end

function TileMap:add_torches_to_world(world)
    local object_layer = self.map.layers['torch']
    if not object_layer then
        return
    end

    for _, obj in ipairs(object_layer.objects) do
        local torch = require 'ecs.entities.torch'()
        torch:give('position', obj.x, obj.y)
        world:addEntity(torch)
    end
end

function TileMap:draw_layer(layer_name)
    if self.map.layers[layer_name] then
        self.map:drawLayer(self.map.layers[layer_name])
    end
end

function TileMap:get_player_pos()
    local player_layer = self.map.layers['player']
    for _, obj in ipairs(player_layer.objects) do
        return obj.x, obj.y
    end
end

function TileMap:add_door_to_world(world)
    local door = require 'ecs.entities.door'()
    local door_x, door_y 
    local door_layer = self.map.layers['door']
    for _, obj in ipairs(door_layer.objects) do
        door_x = obj.x
        door_y = obj.y
    end
    door:give('position', door_x, door_y)
    door:give('door')
    door:give('physics')
    world:addEntity(door)
end

function TileMap:add_enemies_to_world(world)
    local mushroom_layer = self.map.layers['mushrooms']
    if mushroom_layer then
        for _, obj in ipairs(mushroom_layer.objects) do
            local mushroom = require 'ecs.entities.mushroom'()
            mushroom:give('collider', WindfieldSystem.PhysicsWorld:newRectangleCollider(obj.x, obj.y, mushroom.hitbox.w, mushroom.hitbox.h))
            mushroom.collider.data:setCollisionClass('Enemy')
            mushroom.collider.data:setObject(mushroom)
            world:addEntity(mushroom)
        end
    end
end

function TileMap:add_spikes_to_world(world)
    local spikes_layer = self.map.layers['spikes']
    if spikes_layer then
        for _, obj in ipairs(spikes_layer.objects) do
            local spikes = require 'ecs.entities.spikes'()
            local x = obj.x
            local y = obj.y
            local padding = spikes.padding
            local w = spikes.hitbox.w - 2 * padding
            local h = spikes.hitbox.w - 2 * padding
            spikes:give('position', x, y)
            spikes:give('physics')
            spikes:give('collider', WindfieldSystem.PhysicsWorld:newRectangleCollider(x + padding, y + padding, w, h))
            spikes:give('hazard')
            spikes.collider.data:setType('static')
            spikes.collider.data:setCollisionClass('Hazard')
            spikes.sprite.flipped_v = obj.properties.flipped_v
            world:addEntity(spikes)
        end
    end
end

function TileMap:add_stones_to_world(world)
    local stones_layer = self.map.layers['stones']
    if stones_layer then
        for _, obj in ipairs(stones_layer.objects) do
            local stone = require 'ecs.entities.stone'()
            local padding = 1
            local x = obj.x + padding
            local y = obj.y + padding
            
            local w = stone.hitbox.w - 2*padding
            local h = stone.hitbox.h - 2*padding
            stone:give('collider', WindfieldSystem.PhysicsWorld:newRectangleCollider(x, y, w, h))
            stone.collider.data:setDensity(5)
            stone.collider.data:resetMassData()
            stone.collider.data:setCollisionClass('Stone')
            world:addEntity(stone)
        end
    end
end

function TileMap:add_hints_to_world(world)
    local hint_layer = self.map.layers['hint']
    if hint_layer then
        for _, obj in ipairs(hint_layer.objects) do
            local hint = require 'ecs.entities.hint'()
            local x = obj.x
            local y = obj.y
            hint:give('position', x, y)
            hint:set_hint_text(obj.properties.hint_text)
            hint:update_hint_text_pos()
            world:addEntity(hint)
            world:addEntity(hint.text)
        end
    end
end

function TileMap:add_orbs_to_world(world)
    local orbs_layer = self.map.layers['orbs']

    if orbs_layer == nil then
        return
    end

    for y = 1, orbs_layer.height do
        for x = 1, orbs_layer.width do
            local tile = orbs_layer.data[y][x]
    
            if tile then
                local orb = require 'ecs.entities.orb'()
                local orb_x = (x - 1) * self.tile_size + 4
                local orb_y = (y - 1) * self.tile_size + 4
                local orb_s = 8
                orb:give('position', orb_x, orb_y)
                orb:give('collider', WindfieldSystem.PhysicsWorld:newRectangleCollider(orb_x, orb_y, orb_s, orb_s))
                orb.collider.data:setType('static')
                orb.collider.data:setCollisionClass('Orbs')
                orb.collider.data:setObject(orb)

                world:addEntity(orb)
            end
        end
    end
end