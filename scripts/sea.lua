Sea = {}

function Sea:new(x, y, width, height, world)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.x = x
    o.y = y
    o.width = width
    o.height = height

    -- Physics
    o.physics = {}
    o.physics.body = love.physics.newBody(world, x, y, "static")
    o.physics.shape = love.physics.newRectangleShape(width, height)
    o.physics.fixture = love.physics.newFixture(o.physics.body,
        o.physics.shape)
    o.physics.fixture:setUserData("Sea")
    o.physics.fixture:setCategory(8)
    o.physics.fixture:setSensor(true)

    return o
end

function Sea:destroy()
    self.physics.fixture:destroy()
end
