require('scripts.text')

Interface = {}

function Interface:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -------------------------------
    -- MENU
    -------------------------------
    o.phraseMenu = "Please press enter/return to start the game..."
    o.menuFont = love.graphics.newFont("fonts/MatrixSans-Regular.ttf", 28)

    --
    -- UI
    --
    o.spritePanettone = love.graphics.newImage("sprites/lifes.png")
    o.spriteBoxes = love.graphics.newImage("sprites/Crate.png")

    return o
end

function Interface:drawMenu()
    love.graphics.setFont(self.menuFont)
    love.graphics.printf(self.phraseMenu, 0, HEIGHT/2, WIDTH, "center")
end

function Interface:drawUI(lifes, gifts)
    ---
    -- LIFES
    ---
    love.graphics.setFont(self.menuFont)
    love.graphics.draw(self.spritePanettone, 10, 12, nil, 0.30, nil)
    love.graphics.draw(self.spriteBoxes, WIDTH - 65, 12, nil, 0.50, nil)
    love.graphics.print(lifes, 55, 15)
    love.graphics.print(gifts, WIDTH - 90, 15)
end
