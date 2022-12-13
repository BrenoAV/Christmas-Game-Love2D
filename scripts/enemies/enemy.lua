Enemy = {}

function Enemy:new(x, y, width, height, world)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.x = x or 0
    o.y = y or 0
    o.width = width or 0
    o.height = height or 0
    o.speed = 50
    o.world = world or nil
    o.dir = -1

    -- Physics
    o.physics = {}
    o.physics.body = love.physics.newBody(o.world, o.x, o.y, "dynamic")
    o.physics.body:setFixedRotation(true)
    o.physics.shape = love.physics.newRectangleShape(width, height)
    o.physics.fixture = love.physics.newFixture(o.physics.body,
        o.physics.shape, 1)
    o.physics.fixture:setUserData("Enemy")
    o.physics.fixture:setCategory(5)
    o.physics.fixture:setMask(6) -- objects

    return o

end

function Enemy:getPosition()
    return self.physics.body:getPosition()
end

function Enemy:update(dt)
    return self:move(dt)
end

function Enemy:draw()
    local ex, ey = self:getPosition()
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill",
        ex - self.width / 2, ey - self.height / 2,
        self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

function Enemy:move(dt)
    local ex, _ = self:getPosition()
    self.physics.body:setX(ex + self.dir * self.speed * dt)
end

function Enemy:turnAround()
    self.dir = self.dir * -1
end
