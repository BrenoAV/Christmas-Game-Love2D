GameController = {}

function GameController:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- GameState
    -- 1 - Menu
    -- 2 - Game
    self.gameState = 1

    return o
end

function GameController:getGameState()
    return self.gameState
end

function GameController:setGameState(n)
    self.gameState = n
end
