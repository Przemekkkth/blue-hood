return function()
    local door = ECS.entity()

    door:give('sprite', assets.sprites.door)
    door:give('position', 0, 0)

    function door:update(dt)
        local player_hits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            door.position.x + 10,
            door.position.y + 10,
            5,
            5,
            {'Player'}
        )

        if #player_hits > 0 then
            GAME_DATA.LEVEL = GAME_DATA.LEVEL + 1
            GameRoom.STATE = GameRoom.STATES.RESTART
        end
    end

    return door
end