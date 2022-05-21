-- coin.lua
local Spike = {img = love.graphics.newImage("assets/spike.png")}
Spike.__index = Spike

Spike.width = Spike.img:getWidth()
Spike.height = Spike.img:getHeight()

ActiveSpikes  = {}

local Player = require("objects.Char")

function Spike.new(x,y)
   local instance = setmetatable({}, Spike)
   instance.x = x
   instance.y = y
   instance.damage = 1

   instance.scaleX = 1
   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.fixture:setSensor(true)
   table.insert(ActiveSpikes, instance)
end

function Spike.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveSpikes) do 
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then 
                Player:takeDamage(instance.damage)
                return True 
            end
        end
    end 
end

function Spike:update(dt)

end

function Spike:draw()
   love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Spike.updateAll()
    for i, instance in ipairs(ActiveSpikes) do -- i = index, instance = element, ipairs(table)
        instance:update(dt)
    end 
end 

function Spike.drawAll()
    for i, instance in ipairs(ActiveSpikes) do 
        instance:draw()
    end
end

return Spike
