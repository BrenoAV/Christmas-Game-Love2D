SawBlade = {}

function SawBlade:new(x, y, speed, dir, world)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.x = x + dir * 50 -- this will get if the cat is right or left
    o.y = y
    o.fixedY = o.y
    o.radius = 30
    o.world = world
    o.dir = dir
    o.rot = 0
    o.speed = speed + 120 -- This is the malicat speed + something

    -- This is to destroy the sawblade after some distance
    o.distActual = 0
    o.distLimit = 350
    o.toDestroy = false

    -- Sprite
    self.sprite = love.graphics.newImage("sprites/Saw.png")

    -- Physics
    o.physics = {}
    o.physics.body = love.physics.newBody(o.world, o.x, o.y, "dynamic")
    o.physics.shape = love.physics.newCircleShape(o.radius)
    o.physics.fixture = love.physics.newFixture(o.physics.body,
        o.physics.shape)
    o.physics.fixture:setUserData("SawBlade")
    o.physics.fixture:setCategory(6) -- objects
    o.physics.fixture:setMask(3) -- ignore platform
    o.physics.fixture:setMask(4) -- ignore platform endpoint
    o.physics.fixture:setMask(5) -- ignore enemies
    return o
end

function SawBlade:getPosition()
    return self.physics.body:getPosition()
end

function SawBlade:setPosition(x, y)
    self.physics.body:setPosition(x, y)
end

function SawBlade:update(dt)
    self:move(dt)

    -- If the blade is more than limit, set bool to destroy the blade
    if self.distActual >= self.distLimit then
        self.toDestroy = true
    end
end

function SawBlade:move(dt)
    local sx, _ = self:getPosition()
    local delta = self.dir * self.speed * dt -- dx
    self:setPosition(sx + delta, self.fixedY)
    self.distActual = self.distActual + math.abs(delta) -- I'm only summing the distance and storing
end

function SawBlade:draw()
    local sx, sy = self:getPosition()
    self.rot = self.rot + 0.05
    love.graphics.draw(self.sprite, sx, sy, self.rot, 0.18, nil, 178, 180)
    love.graphics.circle("line", sx, sy, self.radius)
end

function SawBlade:destroy()
    self.physics.fixture:destroy()
end
