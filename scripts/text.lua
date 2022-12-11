Text = {}

function Text:new(text, x, y)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.text = text
    o.x = x
    o.y = y

    return o
end

function Text:draw()
    love.graphics.print(self.text, self.x, self.y)
end
