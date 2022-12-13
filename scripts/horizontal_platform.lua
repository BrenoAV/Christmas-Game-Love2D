require('scripts.platform')
HorizontalPlatform = {}

function HorizontalPlatform:new(x, y, width, height, speed, distLimit, world)
    local o = Platform:new(x, y, width, height, world)
    setmetatable(o, self)
    self.__index = self

    o.speed = speed
    o.dir = 1
    o.dx = 0
    o.actualDist = 0
    o.distLimit = distLimit

    o.physics.fixture:setUserData("HorizontalPlatform")

    return o
end

function HorizontalPlatform:getPosition()
    return self.physics.body:getPosition()
end

function HorizontalPlatform:update(dt)
    self:move(dt)
end

function HorizontalPlatform:move(dt)
    self.dx = self.dir*self.speed*dt
    self.physics.body:setX(self.physics.body:getX() + self.dx)
    self.endPointLeft.physics.body:setX(self.endPointLeft.physics.body:getX() + self.dx)
    self.endPointRight.physics.body:setX(self.endPointRight.physics.body:getX() + self.dx)
    self.jumperArea.physics.body:setX(self.jumperArea.physics.body:getX() + self.dx)

    -- sum up the distance
    self.actualDist = self.actualDist + math.abs(self.dx)

    -- Change position after some distance
    if self.actualDist >= self.distLimit then
        self:turnAround()
        self.actualDist = 0
    end

end

function HorizontalPlatform:draw()
    local hpx, hpy = self:getPosition()
    love.graphics.setColor(150/255, 15/255, 15/255)
    love.graphics.rectangle("fill",
            hpx - self.width / 2,
            hpy - self.height / 2,
            self.width,
            self.height
        )
    love.graphics.setColor(1, 1, 1)
end

function HorizontalPlatform:turnAround()
    self.dir = self.dir * -1
end

function HorizontalPlatform:destroy()
    self.physics.fixture:destroy()
    self.endPointLeft.physics.fixture:destroy()
    self.endPointRight.physics.fixture:destroy()
    self.jumperArea.physics.fixture:destroy()
end
