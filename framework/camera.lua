Camera = Object:extend()

function Camera:new(w, h)
    self.pos = {x = 0, y = 0}
    self.w = w
    self.half_width = w / 2
    self.h = h
    self.half_height = h / 2
    self.min_x = -999999
    self.min_y = -999999
    self.max_x = 999999
    self.max_y = 999999
end

function Camera:top_left()
    return self.pos.x - self.half_width, self.pos.y - self.half_height
end

function Camera:attach()
    love.graphics.push()
    local tlx, tly = self:top_left()
    love.graphics.translate(math.floor(-tlx), math.floor(-tly))
end

function Camera:detach()
    love.graphics.pop()
end

function Camera:set_position(x, y)
    self.pos.x = (math.max(self.min_x + self.half_width, math.min(self.max_x - self.half_width, x)))
    self.pos.y = (math.max(self.min_y + self.half_height, math.min(self.max_y - self.half_height, y)))
end