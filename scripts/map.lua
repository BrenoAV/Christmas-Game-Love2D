require('scripts.platform')
require('scripts.wall')
require('scripts.malicat')
require('scripts.player')
require('scripts.sea')
require('scripts.flag')
local sti = require('libraries/sti')

Map = {}

function Map:new(world)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.world = world
    o.player = nil
    o.walls = {}
    o.platforms = {}
    o.movementPlatforms = {}
    o.enemies = {}
    o.sea = {}
    o.flagFinish = nil  -- Need to be destroyed

    -- Graphics
    o.background = love.graphics.newImage("maps/backgrounds/BG.png")

    o.gameMap = nil

    -- All maps
    o.currentMap = 1
    o.maps = {
        "map1",
        "map2"
    }
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
end

function Map:drawBackground()
    love.graphics.draw(self.background)
end

function Map:loadMap(mapNum, resetPlayer)
    mapNum = mapNum or 1
    resetPlayer = resetPlayer or true
    self.currentMap = mapNum

    self.gameMap = sti("maps/" .. self.maps[mapNum] .. ".lua")

    -- Player
    for _, obj in pairs(self.gameMap.layers["PlayerSpawn"].objects) do
        if resetPlayer then
            self.player = Player:new(obj.x, obj.y, 40, 80, self.world)
        else
            self.player:setPosition(obj.x, obj.y)
        end
        self.player.limRight = self.gameMap.width * self.gameMap.tilewidth
    end

    -- Wall
    for _, obj in pairs(self.gameMap.layers["Walls"].objects) do
        self.walls = Wall:new(obj.x + obj.width/2,
            obj.y + obj.height/2, obj.width, obj.height, self.world)
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

    -- Flags
    for _, obj in pairs(self.gameMap.layers["FlagFinish"].objects) do
        self.flagFinish = Flag:new(obj.x + obj.width/2,
            obj.y + obj.height/2, obj.width, obj.height, self.world)
    end

end

function Map:destroy(gameOver)
    gameOver = gameOver or true

    if gameOver then
        self.player:destroy()
    end

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

    -- walls
    local i = #self.walls
    while i > -1 do
        if self.walls[i] ~= nil then
            self.walls[i]:destroy()
        end
        table.remove(self.walls, i)
        i = i - 1
    end

    -- sea
    local i = #self.sea
    while i > -1 do
        if self.sea[i] ~= nil then
            self.sea[i]:destroy()
        end
        table.remove(self.sea, i)
        i = i - 1
    end

end

function Map:allMaps()
    return self.maps
end
