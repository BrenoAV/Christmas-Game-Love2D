require('scripts.platform')
require('scripts.movement_platform')
require('scripts.malicat')
require('scripts.player')
require('scripts.spike')
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
    o.spikes = {}

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

    -- Platforms
    for _,p in ipairs(self.movementPlatforms) do
        p:update(dt)
    end

    -- Enemies
    for _,e in ipairs(self.enemies) do
        e:update(dt)
    end


    -- Spikes
    for _,s in ipairs(self.spikes) do
        s:draw()
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
    -- movement platforms
    for _,p in ipairs(self.movementPlatforms) do
        p:draw()
    end
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

    -- Movement Platforms Vertical
    for _, obj in pairs(self.gameMap.layers["MovementPlatformsVertical"].objects) do
        table.insert(self.movementPlatforms, MovementPlatform:new(
                obj.x + obj.width/2, obj.y + obj.height / 2,
            obj.width, obj.height, 100, "up", 300, "vertical", self.world))
    end

    -- Movement Platforms Vertical
    for _, obj in pairs(self.gameMap.layers["MovementPlatformsHorizontal"].objects) do
        table.insert(self.movementPlatforms, MovementPlatform:new(
                obj.x + obj.width/2, obj.y + obj.height / 2,
            obj.width, obj.height, 100, "right", 200, "horizontal", self.world))
    end

    -- Enemies
    for _, obj in pairs(self.gameMap.layers["EnemiesSpawn"].objects) do
        table.insert(self.enemies, MaliCat:new(obj.x, obj.y, self.world))
    end

    -- Spikes
    for _, obj in pairs(self.gameMap.layers["Spikes"].objects) do
        table.insert(self.spikes, Spike:new(obj.x, obj.y, obj.width, obj.height, self.world))
    end

    -- platforms
    -- table.insert(self.movementPlatforms, MovementPlatform:new(1150, 500,
    --     150, 20, 100, "left", 180, "horizontal", self.world))

    -- table.insert(self.enemies, MaliCat:new(1100, 400, self.world))
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
    i = #self.movementPlatforms
    while i > -1 do
        if self.movementPlatforms[i] ~= nil then
            self.movementPlatforms[i]:destroy()
        end
        table.remove(self.movementPlatforms, i)
        i = i - 1
    end
end
