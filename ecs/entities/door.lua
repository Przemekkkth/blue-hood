return function()
    local door = ECS.entity()

    door:give('sprite', assets.sprites.door)
    door:give('position')

    function door:update(dt)
        local offset = 10
        local size = 5
        local player_hits = WindfieldSystem.PhysicsWorld:queryRectangleArea(
            door.position.x + offset,
            door.position.y + offset,
            size,
            size,
            {'Player'}
        )

        if #player_hits > 0 then
            if GAME_DATA.LEVEL + 1 > GAME_DATA.COUNT_OF_LEVELS then
                GameRoom.STATE = GameRoom.STATES.WIN
            else
                SWITCH_LEVEL(GAME_DATA.LEVEL + 1)
                GameRoom.STATE = GameRoom.STATES.RESTART
            end
        end
    end

    return door
end