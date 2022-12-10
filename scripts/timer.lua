Timer = {}

local function createTimer(startValue, limitValue)
    local timer = {}
    timer.startValue = startValue
    timer.actualValue = startValue
    timer.limitValue = limitValue
    timer.pauseLoop = true
    timer.finished = false
    return timer
end

local function createTimerOneShot(startValue, limitValue)
    local timer = {}
    timer.startValue = startValue
    timer.actualValue = startValue
    timer.limitValue = limitValue
    timer.finished = true
    return timer
end

function Timer:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.timers = {}
    o.timersOneShot = {}

    return o
end

function Timer:addTimer(n, startValue, limitValue)
    table.insert(self.timers, n, createTimer(startValue, limitValue))
end

function Timer:addTimerOneShot(n, startValue, limitValue)
    table.insert(self.timersOneShot, n, createTimerOneShot(startValue, limitValue))
end

function Timer:startTimer(n)
    self.timers[n].pauseLoop = false
end

function Timer:startTimerOneShot(n)
    self.timersOneShot[n].actualValue = 0
    self.timersOneShot[n].finished = false
end

function Timer:resetTimer(n)
    self.timers[n].pauseLoop = false
    self.timers[n].finished = false
    self.timers[n].actualValue = 0
end

function Timer:update(dt)
    for i=1,#self.timers,1 do
        if not self.timers[i].pauseLoop then
            self.timers[i].actualValue = self.timers[i].actualValue + dt

            if self.timers[i].actualValue >= self.timers[i].limitValue then
                self.timers[i].finished = true
            end
        end
    end
    for i=1,#self.timersOneShot,1 do
        if not self.timersOneShot[i].finished then
            self.timersOneShot[i].actualValue = self.timersOneShot[i].actualValue + dt

            if self.timersOneShot[i].actualValue >= self.timersOneShot[i].limitValue then
                self.timersOneShot[i].finished = true
            end
        end
    end
end
