EndPoint = {}

function EndPoint:new(x, y, world)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.x = x
    o.y = y
    o.physics = {}
    o.physics.body = love.physics.newBody(world, o.x,
        o.y, "static")
    o.physics.shape = love.physics.newRectangleShape(5, 5)
    o.physics.fixture = love.physics.newFixture(
        o.physics.body,
        o.physics.shape)
    o.physics.fixture:setCategory(4)
    o.physics.fixture:setMask(2) -- Player
    o.physics.fixture:setUserData("Endpoint")
    o.physics.fixture:setSensor(true)

    return o
end
