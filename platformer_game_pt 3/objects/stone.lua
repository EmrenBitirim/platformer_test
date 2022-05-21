-- coin.lua
local stone = {img = love.graphics.newImage("assets/stone.png")}
stone.__index = stone

stone.width = stone.img:getWidth()
stone.height = stone.img:getHeight()

Activestones  = {}

function stone.new(x,y)
   local instance = setmetatable({}, stone)
   instance.x = x
   instance.y = y
   instance.r = 0

   instance.scaleX = 1
   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)
   table.insert(Activestones, instance)
end


function stone:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function stone:update(dt)
    self:syncPhysics()

end

function stone:draw()
   love.graphics.draw(self.img, self.x, self.y, self.r, self.scaleX, 1, self.width / 2, self.height / 2)
end

function stone.updateAll()
    for i, instance in ipairs(Activestones) do -- i = index, instance = element, ipairs(table)
        instance:update(dt)
    end 
end 

function stone.drawAll()
    for i, instance in ipairs(Activestones) do 
        instance:draw()
    end
end

return stone
