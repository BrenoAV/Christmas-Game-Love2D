require('love')
require('scripts.map')
require('scripts.game_controller')
require('scripts.interface')
require("scripts.audio")
Camera = require('libraries.hump.camera')

TEMP = 3

-- Local Variables
local world = nil
local cam = nil
local gameController = nil
local interface = nil
local audio = nil

-- Map
local map = nil

-- CONSTANTS
WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

function love.load()
    -- gamecontroller
    gameController = GameController:new()

    -- physics
    world = love.physics.newWorld(0, 1800, false)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- objects

    map = Map:new(world)

    -- interface
    interface = Interface:new()

    -- camera
    cam = Camera()

    -- audio
    audio = Audio:new()
    audio:loadMusic("audios/winter_snow.mp3")
    audio:playMusic()
end

function love.update(dt)
    if gameController:getGameState() == 1 then

    elseif gameController:getGameState() == 2 then
        -- World
        world:update(dt)

        -- Map
        map:update(dt)

        if gameController.jumpMap and not map.player.isChimney then
            local nextMap = map.currentMap + 1
            if nextMap < #map.maps + 1 then
                map:destroy(false) -- Not gamer over
                map:loadMap(nextMap, false)
            else
                map:destroy(true) -- Not gamer over
                map:loadMap(1, true)
            end
            gameController.jumpMap = false
        end

        -- camera
        if map.player ~= nil then
            local px, py = map.player:getPosition() -- Player's position
            cam:lookAt(px, py)

            -- Left Border
            if cam.x < WIDTH/2 then
                cam.x = WIDTH/2
            end
            -- Upper Border
            if cam.y < HEIGHT/2 then
                cam.y = HEIGHT/2
            end

            local mapW = map.gameMap.width * map.gameMap.tilewidth
            local mapH = map.gameMap.height * map.gameMap.tileheight
            -- Right Border
            if cam.x > (mapW - WIDTH/2) then
                cam.x = mapW - WIDTH/2
            end
            -- Bottom Border
            if cam.y > (mapH - HEIGHT/2) then
                cam.y = mapH - HEIGHT/2
            end

        else
            cam:lookAt(WIDTH/2, HEIGHT/2)
        end
    end
end

function love.draw()
    map:drawBackground()

    if gameController:getGameState() == 1 then
        interface:drawMenu()
    elseif gameController:getGameState() == 2 then
        cam:attach()
            -- do your drawing here
            map:drawLayer()
            debug()
        cam:detach()

        interface:drawUI(map.player:getLifes(), map.player:getGiftsCollected())
    end
end

function beginContact(a, b, coll)
    if a:getUserData() > b:getUserData() then a, b = b, a end
    if (a:getUserData() == "JumperArea" and b:getUserData() == "Player") then
        map.player.isJumping = false
        map.player.isGrounded = true
    end
    if (a:getUserData() == "Endpoint" and b:getUserData() == "Enemy") then
        for _,e in pairs(map.maliCats) do
            if e.physics.fixture == b then
                e:turnAround()
            end
        end
    end
    if (a:getUserData() == "Enemy" and b:getUserData() == "Enemy") then
        for _,e in pairs(map.maliCats) do
            if e.physics.fixture == a or e.physics.fixture == b then
                e:turnAround()
            end
        end
    end
    if (a:getUserData() == "HorizontalPlatform" and b:getUserData() == "Player") then
        map.player.isHorizontalPlatform = true
    end
    ------------
    -- Fallen Platform
    ------------
    if (a:getUserData() == "FallenPlatform" and b:getUserData() == "Player") then
        for _,fp in pairs(map.fallenPlatforms) do
            if fp.physics.fixture == a then
                fp.isPlayerAbove = true
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Lose Lifes
    ---------------------------------------------------------------------------
    if (a:getUserData() == "Enemy" and b:getUserData() == "Player") then

        for i,e in pairs(map.maliCats) do
            if e.physics.fixture == a then
                map.player:decreaseLifes(1)
                e:destroy()
                table.remove(map.maliCats, i)
            end
        end
    end
    if (a:getUserData() == "Player" and b:getUserData() == "SawBlade") then

        local normX, normY = coll:getNormal()
        map.player:decreaseLifes(1, normX, normY)

        for _,e in pairs(map.maliCats) do
            if b == e.sawBlade.physics.fixture then
                e:destroySawBlade()
            end
        end
    end

    -- collision between sea and player
    if (a:getUserData() == "Player" and b:getUserData() == "Sea") then
        gameController:setGameState(1)
        map:destroy(true)
    end

    ---------------------------------------------------------------------------
    --  Collections
    ---------------------------------------------------------------------------

    if (a:getUserData() == "Gift" and b:getUserData() == "Player") then
        for i,g in pairs(map.gifts) do
            if a == g.physics.fixture then
                g.audio:playSongStatic()
                map.player:addGifts()
                table.remove(map.gifts, i)
                g:destroy() -- Remove collider
            end
        end
    end

    ---------------------------------------------------------------------------
    --  Flag check
    ---------------------------------------------------------------------------

    if (a:getUserData() == "ChimneyFlag" and b:getUserData() == "Player") then
        gameController.jumpMap = true
        map.player.isChimney = true
        map.player.timer:startTimer(2)
    end

    ---------------------------------------------------------------------------
    -- Gamer Over check
    ---------------------------------------------------------------------------
    if map.player:getLifes() <= 0 then
        gameController:setGameState(1)
        map:destroy(true)
    end
end

function endContact(a, b, coll)
    if a:getUserData() > b:getUserData() then a, b = b, a end
    if (a:getUserData() == "JumperArea" and b:getUserData() == "Player") then
        map.player.isJumping = true
        map.player.isGrounded = false
    end
    if (a:getUserData() == "HorizontalPlatform" and b:getUserData() == "Player") then
        map.player.isHorizontalPlatform = false
    end
    ------------
    -- Fallen Platform
    ------------
    if (a:getUserData() == "FallenPlatform" and b:getUserData() == "Player") then
        for _,fp in pairs(map.fallenPlatforms) do
            if fp.physics.fixture == a then
                fp.isPlayerAbove = false
            end
        end
    end
end

function preSolve(a, b, coll)
    if a:getUserData() > b:getUserData() then a, b = b, a end
    if (a:getUserData() == "HorizontalPlatform" and b:getUserData() == "Player") then
        for _,hp in pairs(map.horizontalPlatforms) do
            map.player.dx = hp.dx -- Increase the movement in the player
        end
    end

end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)

end

-- Keyboard
function love.keypressed(key)
    if key == "w" or key == "up" then
        map.player:jump()
    elseif gameController:getGameState() == 1 and key == "return" then
        -- Start the game from the menu
        map:loadMap(TEMP, true) -- First map
        gameController:setGameState(2) -- start game
    elseif key == "escape" then
        love.event.quit()
    end
end

function debug()
    -- Debug
    if love.keyboard.isDown("c") then
        for _, body in pairs(world:getBodies()) do
          for _, fixture in pairs(body:getFixtures()) do
              local shape = fixture:getShape()
              if shape:typeOf("CircleShape") then
                  local cx, cy = body:getWorldPoints(shape:getPoint())
                  love.graphics.circle("fill", cx, cy, shape:getRadius())
              elseif shape:typeOf("PolygonShape") then
                  love.graphics.polygon("fill", body:getWorldPoints(shape:getPoints()))
              else
                  love.graphics.line(body:getWorldPoints(shape:getPoints()))
              end
          end
        end
    end
end
