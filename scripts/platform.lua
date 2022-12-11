Platform = {}

local function createEndPoint(x, y, world)
    local endPoint = {}
    endPoint.x = x
    endPoint.y = y
    endPoint.physics = {}
    endPoint.physics.body = love.physics.newBody(world, endPoint.x,
        endPoint.y, "static")
    endPoint.physics.shape = love.physics.newRectangleShape(5, 5)
    endPoint.physics.fixture = love.physics.newFixture(
        endPoint.physics.body,
        endPoint.physics.shape)
    endPoint.physics.fixture:setUserData("Endpoint")
    endPoint.physics.fixture:setSensor(true)

    return endPoint
end

local function createJumperArea(x, y, width, height, world)
    local jumperArea = {}
    jumperArea.x = x
    jumperArea.y = y - height / 2 - 2
    jumperArea.width = width - 20
    jumperArea.height = 2
    jumperArea.physics = {}
    jumperArea.physics.body = love.physics.newBody(world, jumperArea.x,
        jumperArea.y, "static")
    jumperArea.physics.shape = love.physics.newRectangleShape(jumperArea.width, jumperArea.height)
    jumperArea.physics.fixture = love.physics.newFixture(
        jumperArea.physics.body,
        jumperArea.physics.shape)
    jumperArea.physics.fixture:setUserData("JumperArea")
    jumperArea.physics.fixture:setCategory(7)
    jumperArea.physics.fixture:setSensor(true)

    return jumperArea
end

function Platform:new(x, y, width, height, world)
    local o = {}

    setmetatable(o, self)
    self.__index = self

    o.x = x
    o.y = y
    o.width = width
    o.height = height
    o.world = world

    -- Physics
    o.physics = {}
    o.physics.body = love.physics.newBody(world, x, y, "static")
    o.physics.shape = love.physics.newRectangleShape(width, height)
    o.physics.fixture = love.physics.newFixture(o.physics.body,
        o.physics.shape)
    o.physics.fixture:setUserData("Wall")
    o.physics.fixture:setCategory(3)
    o.physics.fixture:setMask(3)
    o.physics.fixture:setMask(6) -- objects
    o.physics.fixture:setMask(7) -- objects

    -- Endpoints
    o.endPointLeft = createEndPoint(o.x - o.width/2, o.y - o.height/2 - 20, o.world)
    o.endPointRight = createEndPoint(o.x + o.width/2, o.y - o.height/2 - 20, o.world)

    -- JumperArea
    o.jumperArea = createJumperArea(o.x, o.y, o.width, o.height, o.world)

    return o
end

function Platform:draw()
    local px, py = self.physics.body:getPosition()
    love.graphics.rectangle("fill",
        px - self.width / 2, py - self.height / 2,
        self.width, self.height)
end

function Platform:destroy()
    self.physics.fixture:destroy()
    self.endPointLeft.physics.fixture:destroy()
    self.endPointRight.physics.fixture:destroy()
end
