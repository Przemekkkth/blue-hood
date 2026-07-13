CameraSystem = ECS.system({pool = {'sprite', 'is_player'}})
CameraSystem.camera = nil

function CameraSystem:update(dt)
    if CameraSystem.camera == nil then
        return
    end

    for _, entity in ipairs(self.pool) do
        local pos = entity.position
        local cx = CameraSystem.camera.pos.x
        local cy = CameraSystem.camera.pos.y

        cx = cx + ((pos.x - cx) * 8 * dt)
        cy = cy + ((pos.y - cy) * 8 * dt)

        if cx < DRAW_WIDTH / 2 then
            cx = DRAW_WIDTH / 2
        end

        if cy < DRAW_HEIGHT / 2 then
            cy = DRAW_HEIGHT / 2
        end

        if cx > CameraSystem.camera.max_x + DRAW_WIDTH / 2 then
            cx = CameraSystem.camera.max_x + DRAW_WIDTH / 2
        end

        if cy > CameraSystem.camera.max_y + DRAW_HEIGHT / 2 then
            cy = CameraSystem.camera.max_y + DRAW_HEIGHT / 2
        end

        CameraSystem.camera:set_position(cx, cy)
    end
end