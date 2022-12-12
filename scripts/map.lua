require('scripts.platform')
require('scripts.wall')
require('scripts.malicat')
require('scripts.player')
require('scripts.sea')
require('scripts.chimney_flag')
require('scripts.text')
require('scripts.endpoint')
local sti = require('libraries/sti')

Map = {}

function Map:new(world)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.world = world
    o.texts = {}
    o.player = nil
    o.walls = {}
    o.platforms = {}
    o.movementPlatforms = {}
    o.enemies = {}
    o.sea = {}
    o.endpoints = {}
    o.chimneyFlag = nil

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

function Map:drawLayer()
    self.gameMap:drawLayer(self.gameMap.layers["Tile Layer 1"])
    self.gameMap:drawLayer(self.gameMap.layers["Tile Layer 2"])
    self.gameMap:drawLayer(self.gameMap.layers["Texts"])

    -- player
    if self.player ~= nil then
        self.player:draw()
    end

    -- texts
    for i,t in pairs(self.texts) do
        t:draw()
    end

    -- Enemies
    for _,e in pairs(self.enemies) do
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

    for _, obj in pairs(self.gameMap.layers["Texts"].objects) do
        table.insert(self.texts, Text:new(obj.text, obj.x, obj.y))
    end

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
        table.insert(self.walls, Wall:new(obj.x + obj.width/2,
            obj.y + obj.height/2, obj.width, obj.height, self.world))
    end

    -- Platforms
    for _, obj in pairs(self.gameMap.layers["Platforms"].objects) do
        table.insert(self.platforms, Platform:new(obj.x + obj.width/2, obj.y + obj.height/2,
            obj.width, obj.height, self.world))
    end

    -- Enemies
    for _, obj in pairs(self.gameMap.layers["MalicatSpawn"].objects) do
        table.insert(self.enemies, MaliCat:new(obj.x, obj.y, false, self.world))
    end

    -- Sea
    for _, obj in pairs(self.gameMap.layers["Sea"].objects) do
        table.insert(self.sea, Sea:new(obj.x + obj.width/2,
            obj.y + obj.height/2, obj.width, obj.height, self.world))
    end

    -- Flags
    for _, obj in pairs(self.gameMap.layers["ChimneyFinish"].objects) do
        self.chimneyFlag = ChimneyFlag:new(obj.x + obj.width/2,
            obj.y + obj.height/2, obj.width, obj.height, self.world)
    end

    -- Endpoints
    for _, obj in pairs(self.gameMap.layers["Endpoints"].objects) do
        table.insert(self.endpoints, EndPoint:new(obj.x, obj.y, self.world))
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
