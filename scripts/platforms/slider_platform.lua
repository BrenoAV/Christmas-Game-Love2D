require('scripts.platforms.platform')

SliderPlatform = {}

function SliderPlatform:new(x, y, width, height, sliderForce, world)
    local o = Platform:new(x, y, width, height, world)
    setmetatable(o, self)
    self.__index = self

    o.sliderForce = sliderForce or 2900

    o.physics.fixture:setUserData("SliderPlatform")

    return o
end
