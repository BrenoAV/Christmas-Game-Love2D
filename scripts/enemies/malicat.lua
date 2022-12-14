require('scripts.enemies.enemy')
require('scripts.enemies.saw_blade')
local anim8 = require("libraries.anim8.anim8")

MaliCat = {}

function MaliCat:new(x, y, speed, dir, activateSawBlade, world)
    local width, height = 35, 90

    local o = Enemy:new(x, y, width, height, world)
    setmetatable(o, self)
    self.__index = self

    o.speed = speed or 150
    o.dir = dir or 1

    -- SawBlade
    o.activateSawBlade = activateSawBlade or false
    o.sawBlade = nil
    o.timer = Timer:new() -- timer to spawn the blade
    o.timer:addTimer(1, 0, 2) -- X seconds
    o.timer:startTimer(1)


    -- Animation
    o.sprite = love.graphics.newImage("sprites/catMalignous.png")
    o.grid = anim8.newGrid(150, 163, o.sprite:getWidth(), o.sprite:getHeight())
    o.animations = {}
    o.animations.idle = anim8.newAnimation(o.grid('1-10', 1), 0.1)
    o.animations.walk = anim8.newAnimation(o.grid('1-10', 2), 0.1)
    o.animations.run = anim8.newAnimation(o.grid('1-8', 3), 0.1)
    o.animations.actual = o.animations.idle

    return o
end

function MaliCat:getPosition()
    return self.physics.body:getPosition()
end

function MaliCat:update(dt)
    self:move(dt)
    self.animations.actual:update(dt)

    -- bullet
    if self.sawBlade ~= nil then
        self.sawBlade:update(dt)

        if self.sawBlade.toDestroy then
            self.sawBlade:destroy()
            self.sawBlade = nil
        end
    else
        if self.timer.timers[1].finished then
            math.randomseed(os.time())
            self:throwSawBlade()
            self.timer:resetTimer(1)
            local t = math.random(1, 3)
            self.timer:addTimer(1, 0, t) -- t seconds
            self.timer:startTimer(1)
        end
    end

    -- timer
    self.timer:update(dt)
end

function MaliCat:draw()
    local ex, ey = self:getPosition()
    self.animations.actual:draw(self.sprite, ex, ey, nil, self.dir*0.70, 0.70, 71, 92)

    -- Bullet
    if self.sawBlade ~= nil then
        self.sawBlade:draw()
    end

end

function MaliCat:move(dt)
    local ex, _ = self:getPosition()
    self.animations.actual = self.animations.run
    self.physics.body:setX(ex + self.dir * self.speed * dt)
end

function MaliCat:turnAround()
    self.dir = self.dir * -1
end

function MaliCat:destroy()
    self.physics.fixture:destroy()
    -- bullet
    if self.sawBlade ~= nil then
        self.sawBlade:destroy()
    end
end

-- sawBlade
function MaliCat:throwSawBlade()
    if self.activateSawBlade then
        local ex, ey = self:getPosition()
        -- destroy if already exists
        if self.sawBlade ~= nil then
            self.sawBlade:destroy()
        end
        self.sawBlade = SawBlade:new(ex, ey, self.speed, self.dir, self.world)
    end
end

function MaliCat:destroySawBlade()
    if self.sawBlade ~= nil then
        self.sawBlade:destroy()
        self.sawBlade = nil
    end
end
