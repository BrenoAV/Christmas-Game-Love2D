local anim8 = require("libraries.anim8.anim8")
require('scripts.timer')
require('scripts.audio')
require('scripts.objects.gift')

Player = {}

function Player:new(x, y, width, height, world)
    local o = {}

    setmetatable(o, self)
    self.__index = self

    o.x = x -- Corner Left
    o.y = y -- Corner Left
    o.width = width
    o.height = height
    o.speed = 350 -- 300
    o.jumpForce = -3050
    o.world = world
    o.dir = 1
    o.limRight = WIDTH

    o.giftsCollected = 0

    o.dx = 0

    -- Audio
    o.audio = Audio:new()
    o.audio:loadSongStatic("audios/jump.wav")

    -- States
    o.isIdle = true
    o.isRunning = false
    o.isJumping = false
    o.isGrounded = true
    o.allowJump = true
    o.isChimney = false
    o.isHorizontalPlatform = false

    -- Lifes
    o.lifes = 1
    o.timer = Timer:new()
    o.timer:addTimer(1, 0, 0.8) -- Damage
    o.timer:addTimer(2, 0, 0.5)  -- Chimney Animation

    -- Sprites
    o.spriteSheet = love.graphics.newImage("sprites/playerSheet.png")
    o.grid = anim8.newGrid(150, 163,
        o.spriteSheet:getWidth(),
        o.spriteSheet:getHeight())

    o.frameHeight = {163, 110, 95, 80, 65, 50, 35}
    o.frameCountHeight = 1
    o.grid_chimney = anim8.newGrid(150, o.frameHeight[1],
        o.spriteSheet:getWidth(),
        o.spriteSheet:getHeight())

    -- Animations
    o.animations = {}
    o.animations.idle = anim8.newAnimation(o.grid('1-16', 1), 0.05)
    o.animations.jump = anim8.newAnimation(o.grid('1-16', 2), 0.05)
    o.animations.run = anim8.newAnimation(o.grid('1-11', 3), 0.05)
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
    o.physics.fixture:setMask(4) -- Endpoints

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
    -- Movement
    self:move(dt)

    -- Timers
    self.timer:update(dt)

    -- Animation Taken Damage
    if self.timer.timers[1].finished then
        self.takenDamage = false
    end

    -- Animation Chimney
    if self.timer.timers[2].finished then
        if self.frameCountHeight == #self.frameHeight then
            self.isChimney = false
            self.frameCountHeight = 1
            self.timer:resetTimer(2)
        else
            self:updateFrameChimney()
            self.timer:resetTimer(2)
            self.timer:startTimer(2)
        end
    end

    self.animations.actual:update(dt)
end

function Player:draw()
    local px, py = self:getPosition()
    -- Animation Taken Damage
    if self.takenDamage then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end

    if self.isChimney then
        if self.frameCountHeight == 1 then
            self.animations.actual:draw(self.spriteSheet, px, py, nil, self.dir, 1, 62, 87)
        else
            self.grid_chimney = anim8.newGrid(150, self.frameHeight[self.frameCountHeight],
                        self.spriteSheet:getWidth(),
                self.spriteSheet:getHeight())
            self.animations.actual = anim8.newAnimation(self.grid_chimney('1-16', 1), 0.01)

            self.animations.actual:draw(self.spriteSheet, px, py, nil, self.dir, 1, 62, 105 - 15*self.frameCountHeight)
        end
    else
        self.animations.actual:draw(self.spriteSheet, px, py, nil, self.dir, 1, 62, 82)
    end

    love.graphics.setColor(1, 1, 1)
end

function Player:move(dt)
    self.isRunning = false
    local px, _ = self:getPosition()
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

        ----
        -- Horizontal Platforms dx
        --
        if self.isHorizontalPlatform and not self.isRunning then
            self.physics.body:setX(self.physics.body:getX() + self.dx)
        else
            self.dx = 0
        end

    end
end

function Player:jump()
    if self.isGrounded and not self.isChimney then
        self.audio:playSongStatic()
        self.isJumping = true
        self.physics.body:applyLinearImpulse(0, self.jumpForce)
    end
end

function Player:animation()
    if self.isChimney then
        self.animations.actual = self.animations.idle
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
    self.lifes = 1
    self.giftsCollected = 0
end

-------------------------------------------------------------------------------
-- Lifes System
-------------------------------------------------------------------------------

function Player:decreaseLifes(n)
    self.lifes = self.lifes - n
    self.takenDamage = true
    self.timer:resetTimer(1)
    self.timer:startTimer(1)
    self.physics.body:applyLinearImpulse(0, 0)
end

function Player:getLifes()
    return self.lifes
end

function Player:updateFrameChimney()
    self.frameCountHeight = self.frameCountHeight + 1
end

function Player:addGifts(n)
    n = n or 1
    self.giftsCollected = self.giftsCollected + n
end

function Player:getGiftsCollected()
    return self.giftsCollected
end
