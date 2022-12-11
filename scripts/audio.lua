Audio = {}

function Audio:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.sounds = {}
    o.sounds.music = nil
    o.sounds.jump = nil

    return o
end

function Audio:loadMusic(musicAudio)
    self.sounds.music = love.audio.newSource(musicAudio, "static")
end

function Audio:loadJump(jumpAudio)
    self.sounds.jump = love.audio.newSource(jumpAudio, "static")
end

function Audio:playJump()
    self.sounds.jump:play()
end

function Audio:playMusic()
    self.sounds.music:setLooping(true)
    self.sounds.music:setVolume(0.3)
    self.sounds.music:play()
end
