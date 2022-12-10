require('scripts.platform')

MovementPlatform = {}

function MovementPlatform:new(x, y, width, height, speed, dirInitial, distLimit, orientation, world)
    local o = Platform:new(x, y, width, height, world)
    setmetatable(o, self)
    self.__index = self

    o.speed = speed
    if string.lower(dirInitial) == "right" or string.lower(dirInitial) == "down"  then
        o.dir = 1
    elseif string.lower(dirInitial) == "left" or string.lower(dirInitial) == "up" then
        o.dir = -1
    else
        print("wrong directions, only 'right', 'left', 'up', 'bottom'...")
    end
    o.distActual = 0
    o.distLimit = distLimit
    o.orientation = orientation

    o.deltaMovement = 0

    -- Physics
    o.physics.fixture:setUserData("MovementPlatform")

    return o

end

function MovementPlatform:getPosition()
    local mpx, mpy = self.physics.body:getPosition()
    return mpx, mpy
end

function MovementPlatform:getDeltaMovementX()
    return self.deltaMovement
end

function MovementPlatform:update(dt)
    self:move(dt)

    if self.distActual >= self.distLimit then
        self.dir = self.dir * -1
        self.distActual = 0
    end

end

function MovementPlatform:move(dt)
    local mpx, mpy = self:getPosition()
    local epLeftX, epLeftY = self.endPointLeft.physics.body:getPosition()
    local epRightX, epRightY = self.endPointRight.physics.body:getPosition()
    self.deltaMovement = self.dir * self.speed * dt

    if self.orientation == "vertical" then
        -- Platform
        self.physics.body:setY(mpy + self:getDeltaMovementX())
        -- Endpoints
        self.endPointLeft.physics.body:setY(epLeftY + self:getDeltaMovementX())
        self.endPointRight.physics.body:setY(epRightY + self:getDeltaMovementX())
    elseif self.orientation == "horizontal" then

        -- Platform
        self.physics.body:setX(mpx + self:getDeltaMovementX())
        -- Endpoints
        self.endPointLeft.physics.body:setX(epLeftX + self:getDeltaMovementX())
        self.endPointRight.physics.body:setX(epRightX + self:getDeltaMovementX())
    end

    -- Change position after distance
    self.distActual = self.distActual + math.abs(self.deltaMovement)
end

function MovementPlatform:draw()
    local px, py = self.physics.body:getPosition()
    love.graphics.setColor(210/255, 51/255, 105/255)
    love.graphics.rectangle("fill",
        px - self.width / 2, py - self.height / 2,
        self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

function MovementPlatform:destroy()
    self.physics.fixture:destroy()
    self.endPointLeft.physics.fixture:destroy()
    self.endPointRight.physics.fixture:destroy()
end
