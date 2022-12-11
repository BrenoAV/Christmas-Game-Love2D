local anim8 = require("libraries.anim8.anim8")
require('scripts.timer')

Player = {}

function Player:new(x, y, width, height, world)
    local o = {}

    setmetatable(o, self)
    self.__index = self

    o.x = x -- Corner Left
    o.y = y -- Corner Left
    o.width = width
    o.height = height
    o.speed = 240
    o.world = world
    o.dir = 1
    o.limRight = WIDTH

    -- States
    o.isIdle = true
    o.isRunning = false
    o.isJumping = false
    o.isGrounded = true
    o.allowJump = true
    o.isChimney = false

    -- Lifes
    o.lifes = 2
    o.timerOneShot = Timer:new()
    o.timerOneShot:addTimerOneShot(1, 0, 0.1)

    -- Sprites
    o.spriteSheet = love.graphics.newImage("sprites/playerSheet.png")
    o.grid = anim8.newGrid(150, 163,
        o.spriteSheet:getWidth(),
        o.spriteSheet:getHeight())

    -- 110 -> 95 -> 80 -> 65

    o.frameHeight = 110
    o.grid_chimney = anim8.newGrid(150, o.frameHeight,
        o.spriteSheet:getWidth(),
        o.spriteSheet:getHeight())
    -- Animations
    o.animations = {}
    o.animations.idle = anim8.newAnimation(o.grid('1-16', 1), 0.05)
    o.animations.jump = anim8.newAnimation(o.grid('1-16', 2), 0.05)
    o.animations.run = anim8.newAnimation(o.grid('1-11', 3), 0.05)
    o.animations.chimney = anim8.newAnimation(o.grid_chimney('1-16', 1), 0.05)
    o.animations.actual = o.animations.idle

    o.takenDamage = false

    -- Physics
    o.physics = {}
    o.physics.body = love.physics.newBody(world, x, y, "dynamic")
    o.physics.body:setFixedRotation(true)

    o.physics.shape = love.physics.newRectangleShape(width, height)
    o.physics.fixture = love.physics.newFixture(o.physics.body,
        o.physics.shape, 1)
    o.physics.fixture:setUserData("Player")
    o.physics.fixture:setCategory(2)
    o.physics.fixture:setMask(4)

    return o

end

function Player:getPosition()
    return self.physics.body:getPosition()
end

function Player:setPosition(x, y)
    self.physics.body:setPosition(x, y)
end

function Player:update(dt)
    self:animation()
    self.animations.actual:update(dt)
    -- Movement
    self:move(dt)

    -- Timers
    self.timerOneShot:update(dt)

    -- Animation Taken Damage
    if self.timerOneShot.timersOneShot[1].finished then
        self.takenDamage = false
    end
end

function Player:draw()
    local px, py = self:getPosition()
    -- Animation Taken Damage
    if self.takenDamage then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end
    self.animations.actual:draw(self.spriteSheet, px, py, nil, self.dir, 1, 62, 82)
    love.graphics.setColor(1, 1, 1)
end

function Player:move(dt)
    self.isRunning = false
    local px, py = self:getPosition()
    if not self.isChimney then
        if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) and
            px > 0
            then
            self.physics.body:setX(self.physics.body:getX() - self.speed*dt)
            self.isRunning = true
            self.dir = -1
        end
        if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) and
            px < self.limRight
            then
            self.physics.body:setX(self.physics.body:getX() + self.speed*dt)
            self.isRunning = true
            self.dir = 1
        end
    end
end

function Player:jump()
    if self.isGrounded and not self.isChimney then
        self.isJumping = true
        self.physics.body:applyLinearImpulse(0, -2500)
    end
end

function Player:animation()
    if self.isChimney then
        self.animations.actual = self.animations.chimney
    else
        if self.isGrounded then
            if self.isRunning then
                self.animations.actual = self.animations.run
            else
                self.animations.actual = self.animations.idle
            end
        else
            if self.isJumping then
                self.animations.actual = self.animations.jump
            end
        end
    end
end

function Player:destroy()
    self.physics.fixture:destroy()
end

function Player:reset()
    self:resetLifes()
end

-------------------------------------------------------------------------------
-- Lifes System
-------------------------------------------------------------------------------

function Player:decreaseLifes(n, normX, normY)
    normX = normX or 0
    normY = normY or 0
    print("normX = " .. normX .. " | normY = " .. normY)

    self.lifes = self.lifes - n
    self.takenDamage = true
    self.timerOneShot:startTimerOneShot(1)
    self.physics.body:applyLinearImpulse(1000 * -normX, 3000 * -normY)
end

function Player:resetLifes()
    self.lifes = 5
end

function Player:getLifes()
    return self.lifes
end
