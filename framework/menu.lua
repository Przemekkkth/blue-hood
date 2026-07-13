Menu = Object:extend()

function Menu:new()
    self.current = 1
    self.elements = {}
    self.justify = "centre"
    self.y = 0
    print('Menu')
end

function Menu:get_height()
    local height = 0
    for i=1, #self.elements do
        local element = self.elements[i]
        height = height + element:get_height()
    end

    return height
end

function Menu:add_element(element)
    table.insert(self.elements, element)
end

function Menu:reset()
    self.current = 1

    if not self.elements[self.current].enabled then
        self:next()
    end
end

function Menu:next()
    local current = self.current
    self.current = (current % #self.elements) + 1

    if not self.elements[self.current].enabled then
        self:next()
    end
end

function Menu:previous()
    if self.current == 1 then
        self.current = #self.elements
    else
        self.current = self.current - 1
    end

    if not self.elements[self.current].enabled then
        self:previous()
    end
end

function Menu:update(dt)
    if input:pressed('down_action') then
        self:next()
    elseif input:pressed('up_action') then
        self:previous()
    elseif input:pressed('accept_action') then
        self:accept()      
    end
end

function Menu:accept()
    local element = self.elements[self.current]
    element:accept()
end

function Menu:draw()
    
end

function Menu:set_y(y)
    self.y = y
end

function Menu:draw()
    if self.justify == 'centre' then
        local mid = DRAW_WIDTH / 2
        local top = self.y

        for i = 1, #self.elements do
            local element = self.elements[i]
            local element_width = element:get_width()
            local x = element_width / 2
            element.selected = (i == self.current)
            element.x = mid - x
            element.y = top
            element:draw()
            top = top + element:get_height()
        end
    elseif self.justify == 'left' then
        local width = 0

        for i = 1, #self.elements do
            local element = self.elements[i]
            local element_width = element:get_width()

            if element_width > width then
                width = element_width
            end
        end

        local mid = DRAW_WIDTH / 2
        local x = mid - (width / 2)
        local top = self.y

        for i=1, #self.elements do
            local element = self.elements[i]
            element.selected = (i == self.current)
            element.x = mid - x
            element.y = top
            element:draw()

            top = top + element:get_height()
        end
    end
end