require('scripts.platform')
require('scripts.malicat')
require('scripts.player')
require('scripts.sea')
local sti = require('libraries/sti')

Map = {}

function Map:new(world)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.world = world
    o.player = nil
    o.platforms = {}
    o.movementPlatforms = {}
    o.enemies = {}
    o.sea = {}

    -- Graphics
    o.background = love.graphics.newImage("maps/backgrounds/BG.png")

    o.gameMap = nil
    return o
end

function Map:update(dt)
    self.gameMap:update(dt)

    -- Player
    if self.player ~= nil then
        self.player:update(dt)
    end

    -- Enemies
    for _,e in ipairs(self.enemies) do
        e:update(dt)
    end

end

function Map:drawLayer(layer)
    layer = layer or "Tile Layer 1"
    self.gameMap:drawLayer(self.gameMap.layers[layer])

    -- player
    if self.player ~= nil then
        self.player:draw()
    end


    -- Enemies
    for _,e in ipairs(self.enemies) do
        e:draw()
    end

    -- platforms
    -- for _,p in ipairs(self.platforms) do
    --     p:draw()
    -- end

end

function Map:drawBackground()
    love.graphics.draw(self.background)
end

function Map:loadMap(mapName)
    mapName = mapName or "map1"

    self.gameMap = sti("maps/" .. mapName .. ".lua")

    -- Player
    for _, obj in pairs(self.gameMap.layers["PlayerSpawn"].objects) do
        self.player = Player:new(obj.x, obj.y, 40, 80, self.world)
    end

    -- Platforms
    for _, obj in pairs(self.gameMap.layers["Platforms"].objects) do
        table.insert(self.platforms, Platform:new(obj.x + obj.width/2, obj.y + obj.height/2,
            obj.width, obj.height, self.world))
    end

    -- Enemies
    for _, obj in pairs(self.gameMap.layers["EnemiesSpawn"].objects) do
        table.insert(self.enemies, MaliCat:new(obj.x, obj.y, self.world))
    end

    -- Sea
    for _, obj in pairs(self.gameMap.layers["Sea"].objects) do
        table.insert(self.sea, Sea:new(obj.x + obj.width/2,
            obj.y + obj.height/2, obj.width, obj.height, self.world))
    end

end

function Map:destroy()
    self.player:destroy()

    -- enemies
    local i = #self.enemies
    while i > -1 do
        if self.enemies[i] ~= nil then
            self.enemies[i]:destroy()
        end
        table.remove(self.enemies, i)
        i = i - 1
    end

    -- platforms
    local i = #self.platforms
    while i > -1 do
        if self.platforms[i] ~= nil then
            self.platforms[i]:destroy()
        end
        table.remove(self.platforms, i)
        i = i - 1
    end

end
