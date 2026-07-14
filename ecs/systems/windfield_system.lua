WindfieldSystem = ECS.system({playerPool = {'is_player', 'physics'}, enemyPool = {'enemy', 'physics'}, 
                              doorPool = {'door', 'physics'}, stonePool = {'stone', 'physics'},
                              hintPool = {'hint', 'physics'}})
WindfieldSystem.PhysicsWorld = nil
WindfieldSystem.Gravity = {x = 0, y = PHYSICS.GRAVITY}

function WindfieldSystem:init(world)
    if WindfieldSystem.PhysicsWorld == nil then
        error('WindfieldSystem.PhysicsWorld is nil')
    end

    WindfieldSystem.PhysicsWorld:setGravity(
        WindfieldSystem.Gravity.x, WindfieldSystem.Gravity.y)
end

function WindfieldSystem:update(dt)
    WindfieldSystem.PhysicsWorld:update(dt)

    for _, player in ipairs(self.playerPool) do
        player:update(dt)
    end

    for _, enemy in ipairs(self.enemyPool) do
        enemy:update(dt)

        local top_collider = WindfieldSystem.PhysicsWorld:queryRectangleArea(enemy.position.x + 3, enemy.position.y - 2, enemy.hitbox.w - 2, 2, {'Player'})
        if #top_collider > 0 and self.playerPool[1]:velocity().y > 0 then
            enemy:smashed()
            self.playerPool[1]:bounce()
        end
    end

    for _, door in ipairs(self.doorPool) do
        door:update(dt)
    end

    for _, stone in ipairs(self.stonePool) do
        stone:update(dt)
    end

    for _, hint in ipairs(self.hintPool) do
        hint:update(dt)
    end
end