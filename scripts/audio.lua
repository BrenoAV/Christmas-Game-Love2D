Audio = {}

function Audio:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.sounds = {}
    o.sounds.music = nil
    o.sounds.songStatic = nil

    return o
end

function Audio:loadMusic(musicAudio)
    self.sounds.music = love.audio.newSource(musicAudio, "stream")
end

function Audio:loadSongStatic(jumpAudio)
    self.sounds.songStatic = love.audio.newSource(jumpAudio, "static")
end

function Audio:playSongStatic()
    self.sounds.songStatic:setVolume(0.3)
    self.sounds.songStatic:play()
end

function Audio:playMusic()
    self.sounds.music:setLooping(true)
    self.sounds.music:setVolume(0.3)
    self.sounds.music:play()
end
