ChimneyFlag = {}

function ChimneyFlag:new(x, y, width, height, world)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.x = x
    o.y = y
    o.radiusX = width
    o.radiusY = height
    o.world = world

    -- Physics
    o.physics = {}
    o.physics.body = love.physics.newBody(world, x, y, "static")
    o.physics.shape = love.physics.newRectangleShape(width, height)
    o.physics.fixture = love.physics.newFixture(o.physics.body,
        o.physics.shape)
    o.physics.fixture:setUserData("ChimneyFlag")
    o.physics.fixture:setSensor(true)

    return o
end
