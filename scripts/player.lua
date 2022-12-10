local anim8 = require("libraries.anim8.anim8")

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
    o.deltaMovementPlatformX = 0
    o.platformY = 0

    -- States
    o.isIdle = true
    o.isRunning = false
    o.isJumping = false
    o.isGrounded = true
    o.allowJump = true

    -- Sprites
    o.spriteSheet = love.graphics.newImage("sprites/playerSheet.png")
    o.grid = anim8.newGrid(150, 163,
        o.spriteSheet:getWidth(),
        o.spriteSheet:getHeight())

    -- Animations
    o.animations = {}
    o.animations.idle = anim8.newAnimation(o.grid('1-16', 1), 0.05)
    o.animations.jump = anim8.newAnimation(o.grid('1-16', 2), 0.05)
    o.animations.run = anim8.newAnimation(o.grid('1-11', 3), 0.05)
    o.animations.actual = o.animations.idle
    o.activateAnimation = true

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

function Player:update(dt)

    self:animation()
    self.animations.actual:update(dt)
    -- Movement
    self:move(dt)
end

function Player:draw()
    local px, py = self:getPosition()
    self.animations.actual:draw(self.spriteSheet, px, py, nil, self.dir, 1, 62, 82)
end

function Player:move(dt)
    self.isRunning = false
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        self.physics.body:setX(self.physics.body:getX() - self.speed*dt)
        self.isRunning = true
        self.dir = -1
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        self.physics.body:setX(self.physics.body:getX() + self.speed*dt)
        self.isRunning = true
        self.dir = 1
    end
end

function Player:jump()
    if self.isGrounded then
        self.isJumping = true
        self.physics.body:applyLinearImpulse(0, -2500)
    end
end

function Player:animation()
    if self.isGrounded then
        if self.isRunning then
            self.animations.actual = self.animations.run
        else
            self.animations.actual = self.animations.idle
        end
    else
        if self.isJumping and self.activateAnimation then
            self.animations.actual = self.animations.jump
        end
    end
end

function Player:destroy()
    self.physics.fixture:destroy()
end
