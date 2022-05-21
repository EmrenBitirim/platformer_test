-- PlayState.map
local STI = require 'libraries/sti'
local GUI = require 'objects.gui'
require 'objects/Char'
PlayState = Class{_includes = BaseState}
local Coin = require "objects/coin"
require "objects.gui"
local Spike = require "objects.spike"
local Player = require("objects.Char")
local Camera = require("camera")
local Stone = require "objects.stone"


function PlayState:init()
    Map = STI("map/1.lua", {"box2d"})
    World = love.physics.newWorld(0, 2000) -- x vel, y vel
    World:setCallbacks(beginContact, endContact)
    Map:box2d_init(World)
    MapWidth = Map.layers.ground.width * 16
    print(Map.layers.ground.width) -- width in tiles * 16 = width in pixels
    Map.layers.solid.visible = false
    
    background = love.graphics.newImage("assets/background.png")
    
    pause = true
    pause_font = love.graphics.newFont('assets/bit.ttf', 48)
    Player:load()
    GUI:load()

    Coin.new(100, 300)
    Coin.new(300, 300)
    Coin.new(200, 60)

    Spike.new(500, 325)
    Stone.new(250, 215)

end 

function PlayState:enter()
    
end 

function PlayState:update(dt)
    if not pause then
        World:update(dt)
        Player:update(dt)
        Coin.updateAll()
        GUI:update(dt)
        Spike:updateAll(dt)
        Stone:updateAll(dt)
        Camera:setPosition(Player.x, 0)

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
    Map:draw(-Camera.x, -Camera.y, Camera.scale) -- (x, y, scaleX, scaleY) // only applies scaling to the map
    
    Camera:apply()
    Player:draw()
    Coin.drawAll()
    Spike.drawAll()
    Stone.drawAll()
    Camera:clear()
    
    GUI:draw()

    if pause then 
        love.graphics.setFont(pause_font)
        love.graphics.printf("PAUSED", love.graphics.getWidth() / 2 - 200, 375, 300, "center")
    end
end 

function beginContact(a, b, collision) -- 3rd argument: contact object created upon collision
    if Coin.beginContact(a, b, contact) then return end
    if Spike.beginContact(a, b, contact) then return end
    Player:beginContact(a, b, collision)

end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)

end

