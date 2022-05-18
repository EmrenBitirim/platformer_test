-- PlayState.map
local STI = require 'libraries/sti'
require 'objects/char'
PlayState = Class{_includes = BaseState}

function PlayState:init()
    Map = STI("map/1.lua", {"box2d"})
    World = love.physics.newWorld(0, 0) -- x vel, y vel
    World:setCallbacks(beginContact, endContact)
    Map:box2d_init(World)
    Map.layers.solid.visible = false
    
    background = love.graphics.newImage("assets/background.png")
    
    pause = true
    pause_font = love.graphics.newFont('assets/bit.ttf', 48)
    Player:load()
    
end 

function PlayState:enter()

end 

function PlayState:update(dt)
    if not pause then
        World:update(dt)
        Player:update(dt)
    end

    if love.keyboard.wasPressed("return") then 
        if pause == false then 
            pause = true 
        elseif pause == true then
            pause = false 
        end         
    end

end 

function PlayState:exit()

end 

function PlayState:render()
    love.graphics.draw(background)
    Map:draw(0, 0, 2) -- (x, y, scaleX, scaleY) // only applies scaling to the map
    love.graphics.push()
    love.graphics.scale(2, 2)

    Player:draw()
    love.graphics.pop()

    if pause then 
        love.graphics.setFont(pause_font)
        love.graphics.printf("PAUSED", love.graphics.getWidth() / 2 - 200, 375, 300, "center")
    end
end 

function beginContact(a, b, collision) -- 3rd argument: contact object created upon collision
    Player:beginContact(a, b, collision)

end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)

end

