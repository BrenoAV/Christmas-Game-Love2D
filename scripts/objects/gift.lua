Gift = {}

function Gift:new(x, y, world)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.x = x
    o.y = y
    o.world = world

    -- Sprite
    o.sprite = love.graphics.newImage("sprites/Crate.png")

    -- Physics
    o.physics = {}
    o.physics.body = love.physics.newBody(world, x, y, "kinematic")
    o.physics.shape = love.physics.newRectangleShape(o.sprite:getWidth()/2,
        o.sprite:getHeight()/2)
    o.physics.fixture = love.physics.newFixture(o.physics.body,
        o.physics.shape)
    o.physics.fixture:setUserData("Gift")
    o.physics.fixture:setSensor(true)
    o.physics.fixture:setCategory(3)
    o.physics.fixture:setMask(6)
    o.physics.fixture:setMask(7)

    return o
end

function Gift:draw()
    love.graphics.draw(self.sprite, self.x, self.y, nil, 0.5, 0.5, self.sprite:getWidth()/2, self.sprite:getHeight()/2)
end

function Gift:destroy()
    self.physics.fixture:destroy()
end
