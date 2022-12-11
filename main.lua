require('love')
require('scripts.map')
require('scripts.game_controller')
require('scripts.interface')
Camera = require('libraries.hump.camera')

count = 0

-- Timer
local timer = nil

-- Local Variables
local world = nil
local cam = nil
local gameController = nil
local interface = nil

-- Map
local map = nil

-- CONSTANTS
WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

function love.load()
    -- gamecontroller
    gameController = GameController:new()

    -- physics
    world = love.physics.newWorld(0, 1500, false)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- objects

    map = Map:new(world)

    -- interface
    interface = Interface:new()

    -- timer
    timer = Timer:new()
    timer:addTimer(1, 0, 0.15)

    -- camera
    cam = Camera()
end

function love.update(dt)
    if gameController:getGameState() == 1 then

    elseif gameController:getGameState() == 2 then
        -- World
        world:update(dt)

        -- Map
        map:update(dt)

        if gameController.jumpMap and not map.player.isChimney then
            map:destroy(false) -- Not gamer over
            map:loadMap(map.currentMap + 1, false)
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
            --map.player:draw()
            debug()
        cam:detach()

        interface:drawUI(map.player:getLifes())
    end
end

function beginContact(a, b, coll)
    if a:getUserData() > b:getUserData() then a, b = b, a end
    if (a:getUserData() == "JumperArea" and b:getUserData() == "Player") then
        map.player.isJumping = false
        map.player.isGrounded = true
    end
    if (a:getUserData() == "Endpoint" and b:getUserData() == "Enemy") then
        for _,e in pairs(map.enemies) do
            if e.physics.fixture == b then
                e:turnAround()
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Lose Lifes
    ---------------------------------------------------------------------------
    if (a:getUserData() == "Enemy" and b:getUserData() == "Player") then
        local normX, normY = coll:getNormal()
        map.player:decreaseLifes(1, normX, normY)

        for _,e in pairs(map.enemies) do
            if e.physics.fixture == a then
                if (normX > 0 and e.dir < 0) or (normX < 0 and e.dir > 0) then
                    e:turnAround()
                end
            end
        end
    end
    if (a:getUserData() == "Player" and b:getUserData() == "SawBlade") then

        local normX, normY = coll:getNormal()
        map.player:decreaseLifes(1, normX, normY)

        for _,e in pairs(map.enemies) do
            if b == e.sawBlade.physics.fixture then
                e:destroySawBlade()
            end
        end
    end

    -- collision between sea and player
    if (a:getUserData() == "Player" and b:getUserData() == "Sea") then
        gameController:setGameState(1)
        map:destroy()
    end

    ---------------------------------------------------------------------------
    --  Flag check
    ---------------------------------------------------------------------------

    if (a:getUserData() == "FlagFinish" and b:getUserData() == "Player") then
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
end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)

end

-- Keyboard
function love.keypressed(key)
    if key == "w" or key == "up" then
        map.player:jump()
    elseif gameController:getGameState() == 1 and key == "return" then
        -- Start the game from the menu
        map:loadMap(1) -- First map
        gameController:setGameState(2) -- start game
    elseif key == "escape" then
        love.event.quit()
    end
end

function debug()
    -- Debug
    --local mx, my = love.mouse.getPosition()
    --love.graphics.print("x = " .. mx .. " | " .. "y = " .. my, 0, 0)
    --local x, y = 200, 100
    --love.graphics.line(x, 0, x, HEIGHT) -- Vertical
    --love.graphics.line(0, y, WIDTH, y) -- Horizontal
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
