require('scripts.platform')
require('scripts.timer')
FallenPlatform = {}

function FallenPlatform:new(x, y, width, height, timeToFallen, world)
    local o = Platform:new(x, y, width, height, world)
    setmetatable(o, self)
    self.__index = self

    o.timeToFallen = timeToFallen
    o.isPlayerAbove = false
    o.isPlatformActivate = false
    o.allowMovement = false

    -- Timer
    o.timer = Timer:new()
    o.timer:addTimer(1, 0, 2) -- Timer for activate the platform
    o.timer:addTimer(2, 0, 3) -- Timer for restore the platform

    o.physics.fixture:setUserData("FallenPlatform")
    o.physics.fixture:setMask(8)

    return o
end

function FallenPlatform:getPosition()
    return self.physics.body:getPosition()
end

function FallenPlatform:setY(y)
    self.physics.body:setY(y)
    self.endPointLeft.physics.body:setY(self.endPointLeft.y)
    self.endPointRight.physics.body:setY(self.endPointRight.y)
    self.jumperArea.physics.body:setY(self.jumperArea.y)
end

function FallenPlatform:update(dt)

    self.timer:update(dt)

    -- activate platform
    if self.isPlayerAbove and not self.isPlatformActivate then
        self.isPlatformActivate = true
        self.timer:startTimer(1)
    end

    self:move(dt)

    -- verify the time to fallen the platform
    if self.timer:getTimer(1).finished then
        self.timer:resetTimer(1)
        self.allowMovement = true
        self.timer:startTimer(2)
    end

    if self.timer:getTimer(2).finished then
        self.isPlatformActivate = false
        self.allowMovement = false
        self.timer:resetTimer(2)
        self:setY(self.y)
    end

end

function FallenPlatform:move(dt)
    local _, fpy = self:getPosition()
    if self.allowMovement and fpy < 2000 then
        local dy = 400*dt
        self.physics.body:setY(fpy + dy)
        self.endPointLeft.physics.body:setY(self.endPointLeft.physics.body:getY() + dy)
        self.endPointRight.physics.body:setY(self.endPointLeft.physics.body:getY() + dy)
        self.jumperArea.physics.body:setY(self.jumperArea.physics.body:getY() + dy)
    end
end

function FallenPlatform:draw()
    local hpx, hpy = self:getPosition()
    love.graphics.setColor(172/255, 133/255, 91/255)
    love.graphics.rectangle("fill",
            hpx - self.width / 2,
            hpy - self.height / 2,
            self.width,
            self.height
        )
    love.graphics.setColor(1, 1, 1)
end

function FallenPlatform:destroy()
    self.physics.fixture:destroy()
    self.endPointLeft.physics.fixture:destroy()
    self.endPointRight.physics.fixture:destroy()
    self.jumperArea.physics.fixture:destroy()
end
