Interface = {}

function Interface:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -------------------------------
    -- MENU
    -------------------------------
    o.phraseMenu = "Please press enter/return to start the game..."
    o.menuFont = love.graphics.newFont("fonts/MatrixSans-Regular.ttf", 20)

    return o
end

function Interface:draw()
    love.graphics.setFont(self.menuFont)
    love.graphics.printf(self.phraseMenu, 0, HEIGHT/2, WIDTH, "center")
end
