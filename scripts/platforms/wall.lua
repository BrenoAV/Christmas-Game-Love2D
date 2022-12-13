Wall = {}

function Wall:new(x, y, width, height, world)
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
        o.physics.shape, 1000)
    o.physics.fixture:setUserData("Wall")
    o.physics.fixture:setCategory(3)
    o.physics.fixture:setMask(6) -- Objects

    return o
end

function Wall:destroy()
    self.physics.fixture:destroy()
end
