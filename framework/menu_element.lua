MenuElement = Object:extend()

function MenuElement:new(fn)
    if not fn then
        fn = function()
            print("no action for menu item " .. tostring(self))
        end
    end

    self.fn = fn
    self.enabled = true
    self.selected = false
    self.x, self.y = 0, 0
end

function MenuElement:enable()
    self.enabled = true
    return self
end

function MenuElement:disable()
    self.enabled = false
    return self
end

function MenuElement:get_width()
    return 0
end

function MenuElement:get_height()
    return 0
end

function MenuElement:set_select(on)
    self.selected = on
end

function MenuElement:set_position(x, y)
    self.x, self.y = x, y
end

function MenuElement:accept()
    self.fn()
end

function MenuElement:draw()
    local colour = {1, 1, 1, 1}
    if self.selected then
        colour = {1, 1, 0, 1}
    end

    if (self.enabled == false) then
        colour = {0.6, 0.6, 0.6, 1}
    end

    love.graphics.setColor(colour)
end


TextMenuElement = MenuElement:extend()

function TextMenuElement:new(text, fn)
    TextMenuElement.super.new(self, fn)
    self.text = text
end

function TextMenuElement:__tostring()
    return self.text
end

function TextMenuElement:get_width()
    return FONT_x2:getWidth(self.text)
end

function TextMenuElement:get_height()
    return FONT_x2:getHeight()
end

function TextMenuElement:draw()
    MenuElement.draw(self)

    love.graphics.print(self.text, FONT_x2, self.x, self.y)
end

OptionMenuElement = TextMenuElement:extend()

function OptionMenuElement:new(values, selected ,text, fn)
    OptionMenuElement.super.new(text, fn)
    self.values = values
    self.selected = selected
end