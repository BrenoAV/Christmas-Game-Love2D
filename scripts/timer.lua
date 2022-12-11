Timer = {}

local function createTimer(startValue, limitValue)
    local timer = {}
    timer.startValue = startValue
    timer.actualValue = startValue
    timer.limitValue = limitValue
    timer.pause = true
    timer.finished = false
    return timer
end

function Timer:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.timers = {}

    return o
end

function Timer:addTimer(n, startValue, limitValue)
    table.insert(self.timers, n, createTimer(startValue, limitValue))
end

function Timer:startTimer(n)
    self.timers[n].pause = false
    self.timers[n].finished = false
end

function Timer:resetTimer(n)
    self.timers[n].pause = true
    self.timers[n].finished = false
    self.timers[n].actualValue = 0
end

function Timer:update(dt)
    for i=1,#self.timers,1 do
        if not self.timers[i].pause and not self.timers[i].finished then
            self.timers[i].actualValue = self.timers[i].actualValue + dt
            if self.timers[i].actualValue >= self.timers[i].limitValue then
                self.timers[i].finished = true
            end
        end
    end
end
