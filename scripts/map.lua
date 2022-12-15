require('scripts.platforms.platform')
require('scripts.platforms.horizontal_platform')
require('scripts.platforms.fallen_platform')
require('scripts.platforms.endpoint')
require('scripts.platforms.wall')
require('scripts.enemies.malicat')
require('scripts.player.player')
require('scripts.flags.chimney_flag')
require('scripts.objects.gift')
require('scripts.sea')
require('scripts.text')
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
    o.maliCats = {}
    o.sea = {}
    o.endpoints = {}
    o.chimneyFlag = nil
    o.gifts = {}
    o.horizontalPlatforms = {}
    o.fallenPlatforms = {}

    -- Collectables
    o.giftsCollected = 0

    -- Graphics
    o.background = love.graphics.newImage("maps/backgrounds/BG.png")

    o.gameMap = nil

    -- All maps
    o.currentMap = 1
    o.maps = {
        -- Map1
        {name = "map1"},
        -- Map2
        {name = "map2"},
        -- Map3
        {name = "map3"},
        -- Map4
        {name = "map4"}
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
    for _,e in pairs(self.maliCats) do
        e:update(dt)
    end

    -- Horizontal Platforms
    for _,hp in pairs(self.horizontalPlatforms) do
        hp:update(dt)
    end

    -- Fallen Platforms
    for _,fp in pairs(self.fallenPlatforms) do
        fp:update(dt)
    end
end

function Map:drawLayer()
    if self.gameMap.layers["Tile Layer 1"] then
        self.gameMap:drawLayer(self.gameMap.layers["Tile Layer 1"])
    end
    if self.gameMap.layers["Tile Layer 2"] then
        self.gameMap:drawLayer(self.gameMap.layers["Tile Layer 2"])
    end
    if self.gameMap.layers["Tile Layer 3"] then
        self.gameMap:drawLayer(self.gameMap.layers["Tile Layer 3"])
    end
    if self.gameMap.layers["Texts"] then
        self.gameMap:drawLayer(self.gameMap.layers["Texts"])
    end

    -- player
    if self.player ~= nil then
        self.player:draw()
    end

    -- texts
    for i,t in pairs(self.texts) do
        t:draw()
    end

    -- Enemies
    for _,e in pairs(self.maliCats) do
        e:draw()
    end

    -- Gifts
    for _,g in pairs(self.gifts) do
        g:draw()
    end

    -- Horizontal Platforms
    for _,hp in pairs(self.horizontalPlatforms) do
        hp:draw()
    end

    -- Fallen Platforms
    for _,fp in pairs(self.fallenPlatforms) do
        fp:draw()
    end
end

function Map:drawBackground()
    love.graphics.draw(self.background, nil, nil, 0, 1.5, 1.5)
end

function Map:loadMap(mapNum, resetPlayer)

    self:destroy(resetPlayer)

    self.currentMap = mapNum

    self.gameMap = sti("maps/" .. self.maps[mapNum]["name"] .. ".lua")

    -- Player
    for _, obj in pairs(self.gameMap.layers["PlayerSpawn"].objects) do
        if resetPlayer then
            self.player = Player:new(obj.x, obj.y, 40, 80, self.world)
        else
            self.player:setPosition(obj.x, obj.y)
        end
        self.player.limRight = self.gameMap.width * self.gameMap.tilewidth
    end


    -- Texts
    if self.gameMap.layers["Texts"] then
        for _, obj in pairs(self.gameMap.layers["Texts"].objects) do
            table.insert(self.texts, Text:new(obj.text, obj.x, obj.y))
        end
    end

    -- Wall
    if self.gameMap.layers["Walls"] then
        for _, obj in pairs(self.gameMap.layers["Walls"].objects) do
            table.insert(self.walls, Wall:new(obj.x + obj.width/2,
                obj.y + obj.height/2, obj.width, obj.height, self.world))
        end
    end

    -- Platforms
    if self.gameMap.layers["Platforms"] then
        for _, obj in pairs(self.gameMap.layers["Platforms"].objects) do
            table.insert(self.platforms, Platform:new(obj.x + obj.width/2, obj.y + obj.height/2,
                obj.width, obj.height, self.world))
        end
    end

    -- Horizontal Platforms
    if self.gameMap.layers["HorizontalPlatforms"] then
        for _, obj in pairs(self.gameMap.layers["HorizontalPlatforms"].objects) do
            table.insert(self.horizontalPlatforms, HorizontalPlatform:new(obj.x + obj.width/2, obj.y + obj.height/2,
                obj.width, obj.height, obj.properties.speed, obj.properties.distLimit - obj.width/2, self.world))
        end
    end

    -- Horizontal Platforms
    if self.gameMap.layers["FallenPlatforms"] then
        for _, obj in pairs(self.gameMap.layers["FallenPlatforms"].objects) do
            table.insert(self.fallenPlatforms, FallenPlatform:new(obj.x + obj.width/2, obj.y + obj.height/2,
                obj.width, obj.height, obj.properties.timeToFallen, self.world))
        end
    end

    -- Malicat
    if self.gameMap.layers["MalicatSpawn"] then
        for _, obj in pairs(self.gameMap.layers["MalicatSpawn"].objects) do
            table.insert(self.maliCats, MaliCat:new(obj.x, obj.y,
                    obj.properties.speed, obj.properties.dir, obj.properties.throwSaw,
                obj.properties.smallCat, self.world))
        end
    end


    -- Sea
    if self.gameMap.layers["Sea"] then
        for _, obj in pairs(self.gameMap.layers["Sea"].objects) do
            table.insert(self.sea, Sea:new(obj.x + obj.width/2,
                obj.y + obj.height/2, obj.width, obj.height, self.world))
        end
    end

    -- Flags
    if self.gameMap.layers["ChimneyFinish"] then
        for _, obj in pairs(self.gameMap.layers["ChimneyFinish"].objects) do
            self.chimneyFlag = ChimneyFlag:new(obj.x + obj.width/2,
                obj.y + obj.height/2, obj.width, obj.height, self.world)
        end
    end

    -- Endpoints
    if self.gameMap.layers["Endpoint"] then
        for _, obj in pairs(self.gameMap.layers["Endpoints"].objects) do
            table.insert(self.endpoints, EndPoint:new(obj.x, obj.y, self.world))
        end
    end


    -- Gifts
    if self.gameMap.layers["Gifts"] then
        for _, obj in pairs(self.gameMap.layers["Gifts"].objects) do
            table.insert(self.gifts, Gift:new(obj.x, obj.y, self.world))
        end
    end
end

function Map:destroy(resetPlayer)
    if resetPlayer and self.player ~= nil then
        self.player:destroy()
    end

    -- enemies
    local i = #self.maliCats
    while i > -1 do
        if self.maliCats[i] ~= nil then
            self.maliCats[i]:destroy()
        end
        table.remove(self.maliCats, i)
        i = i - 1
    end

    -- platforms
     i = #self.platforms
    while i > -1 do
        if self.platforms[i] ~= nil then
            self.platforms[i]:destroy()
        end
        table.remove(self.platforms, i)
        i = i - 1
    end

    -- horizontal platforms
     i = #self.horizontalPlatforms
    while i > -1 do
        if self.horizontalPlatforms[i] ~= nil then
            self.horizontalPlatforms[i]:destroy()
        end
        table.remove(self.horizontalPlatforms, i)
        i = i - 1
    end

    -- fallen platforms
     i = #self.fallenPlatforms
    while i > -1 do
        if self.fallenPlatforms[i] ~= nil then
            self.fallenPlatforms[i]:destroy()
        end
        table.remove(self.fallenPlatforms, i)
        i = i - 1
    end

    -- walls
     i = #self.walls
    while i > -1 do
        if self.walls[i] ~= nil then
            self.walls[i]:destroy()
        end
        table.remove(self.walls, i)
        i = i - 1
    end

    -- sea
     i = #self.sea
    while i > -1 do
        if self.sea[i] ~= nil then
            self.sea[i]:destroy()
        end
        table.remove(self.sea, i)
        i = i - 1
    end

    -- texts
     i = #self.texts
    while i > -1 do
        table.remove(self.texts, i)
        i = i - 1
    end

    -- gifts
     i = #self.gifts
    while i > -1 do
        if self.gifts[i] ~= nil then
            self.gifts[i]:destroy()
        end
        table.remove(self.gifts, i)
        i = i - 1
    end

    -- chimneyFlag
     if self.chimneyFlag ~= nil then
         self.chimneyFlag:destroy()
     end

end

function Map:allMaps()
    return self.maps
end
