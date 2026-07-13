MenuStack = Object:extend()

function MenuStack:new()
    self:clear()
end

function MenuStack:clear()
    self.stack = {}
end

function MenuStack:is_empty()
    return #self.stack == 0
end

function MenuStack:push(menu)
    table.insert(self.stack, menu)
    menu:reset()
end

function MenuStack:pop()
    table.remove(self.stack, #self.stack)
end

function MenuStack:update(dt)
    if self:is_empty() then return end
     self.stack[#self.stack]:update(dt)
 end

function MenuStack:get_height()
    if self:is_empty() then return end
    return self.stack[#self.stack]:get_height()
end

function MenuStack:draw()
    if self:is_empty() then return end
     self.stack[#self.stack]:draw()
end

function MenuStack:accept()
    if self:is_empty() then return end
     self.stack[#self.stack]:accept()
 end
 
 function MenuStack:next()
    if self:is_empty() then return end
     self.stack[#self.stack]:next()
 end
 
 function MenuStack:previous()
    if self:is_empty() then return end
     self.stack[#self.stack]:previous()
 end

 function MenuStack:accept()
    if self:is_empty() then return end
     self.stack[#self.stack]:accept()
 end

 function MenuStack:next()
    if self:is_empty() then return end
     self.stack[#self.stack]:next()
 end
 
 function MenuStack:previous()
    if (#self.stack == 0) then return end
     self.stack[#self.stack]:previous()
 end