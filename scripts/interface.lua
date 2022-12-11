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
    o.menuFont = love.graphics.newFont("fonts/MatrixSans-Regular.ttf", 20)

    --
    -- UI
    --
    o.spritePanettone = love.graphics.newImage("sprites/spritePanettone.png")

    return o
end

function Interface:drawMenu()
    love.graphics.setFont(self.menuFont)
    love.graphics.printf(self.phraseMenu, 0, HEIGHT/2, WIDTH, "center")
end

function Interface:drawUI(lifes)
    ---
    -- LIFES
    ---
    love.graphics.setFont(self.menuFont)
    love.graphics.draw(self.spritePanettone, 10, 10)
    love.graphics.print(lifes, 50, 12)
end

function Interface:drawTutorial(texts)
    for i,text in pairs(texts) do
        print(i)
    end
end
