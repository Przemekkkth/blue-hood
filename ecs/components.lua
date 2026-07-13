ECS.component('position', function(component, x, y)
    component.x = x or 0
    component.y = y or 0
end)

ECS.component('hitbox', function(component, w, h, is_solid)
    component.w = w
    component.h = h
    component.is_solid = is_solid or true
end)

ECS.component('physics')

ECS.component('sprite', function(component, spritesheet, ox, oy)
    component.mod = {1, 1, 1, 1}
    component.spritesheet = spritesheet
    component.ox = ox or 0
    component.oy = oy or 0
    component.flipped_h = false
    component.flipped_v = false
    component.order = 0
end)


ECS.component('anim8', function(component, animations, name)
    component.animations = animations
    component.name = name
    component.is_last_frame = function()
        local total_frames = #component.animations[component.name].frames
        if component.animations[component.name].position == total_frames then
            return true
        end
        return false
    end
    component.reset = function()
        component.animations[component.name]:gotoFrame(1)
    end
end)

ECS.component('is_player')

ECS.component('collider', function(component, data, type, fixed_rotation)
    data:setType(type or 'dynamic')
    data:setFixedRotation(fixed_rotation or true)
    component.data = data
end)

ECS.component('delayed_callback', function(component, callback, time)
    component.time = time
    component.callback = callback
end)

ECS.component('background')
ECS.component('door')
ECS.component('enemy')
ECS.component('hazard')
ECS.component('stone')
ECS.component('HUD')
ECS.component('invincible')
ECS.component('hint')

ECS.component('text', function(component, data, font, size)
    component.data = data
    component.font = font
    component.size = size
    component.visible = true
end)

ECS.component('sfx', function(component, id)
    component.id = id
end)