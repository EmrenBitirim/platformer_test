--Char.lua
local Player = {}

function Player:load()
   self.x = 100
   self.y = 0
   self.startX = self.x 
   self.startY = self.y

   self.width = 20
   self.height = 60

   self.alive = true 

   self.xVel = 0
   self.yVel = 0
   self.maxSpeed = 200
   self.acceleration = 3000
   self.friction = 3500
   self.gravity = 1500
   self.jumpAmount = -500

   self.health = {current = 3, max = 3}

   self.availableJumps = 2

   self.grounded = false
   self.direction = "right"
   self.state = "idle"

   self.coins = 0

   self:loadAssets()

   self.physics = {}
   self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
   self.physics.body:setFixedRotation(true)
   self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
   self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
   self.physics.body:setGravityScale(0)

   self.color = {
      red = 1, 
      green = 1,
      blue = 1, 
      speed = 3 -- pace of untinting
   }

end

function Player:loadAssets()
   self.animation = {timer = 0, rate = 0.1}

   self.animation.run = {total = 6, current = 1, img={}} -- 6 = total frames
   for i=1, self.animation.run.total do
      self.animation.run.img[i] = love.graphics.newImage("assets/player/run/"..i..".png")
   end 

   self.animation.idle = {total = 4, current = 1, img={}}
   for i=1, self.animation.idle.total do
      self.animation.idle.img[i] = love.graphics.newImage("assets/player/idle/"..i..".png")
   end 

   self.animation.air = {total = 4, current = 1, img={}} 
   for i=1, self.animation.air.total do
      self.animation.air.img[i] = love.graphics.newImage("assets/player/air/"..i..".png")
   end

   self.animation.draw = self.animation.idle.img[1] -- store the image that we want to draw
   self.animation.width = self.animation.draw:getWidth()
   self.animation.height = self.animation.draw:getHeight()

end 

function Player:update(dt)
   self:unTint(dt)
   self:respawn()
   self:applyGravity(dt)
   self:move(dt)
   self:syncPhysics()
   self:setDirection()
   self:animate(dt)
   self:setState()

   if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('up') or love.keyboard.wasPressed('w') then
      Player:jump()
  end
end

function Player:unTint(dt)
   self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
   self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
   self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)

end 

function Player:respawn()
   if not self.alive then 
      self.physics.body:setPosition(self.startX, self.startY)
      self.health.current = self.health.max
      self.alive = true 
   end 
end

function Player:tintRed()
   self.color.green = 0
   self.color.blue = 0

end 

function Player:takeDamage(amount)
   self:tintRed()
   if self.health.current - amount > 0 then 
      self.health.current = self.health.current - amount 
   else 
      self.health.current = 0
      self:die()
   end
   print("Player health: "..self.health.current)
end 

function Player:die()
   print("Player died!")
   self.alive = false 

end 

function Player:applyGravity(dt)
   if not self.grounded then
      self.yVel = self.yVel + self.gravity * dt
   end
end

function Player:move(dt)
   if love.keyboard.isDown("d", "right") then
      if self.xVel < self.maxSpeed then
         if self.xVel + self.acceleration * dt < self.maxSpeed then
            self.xVel = self.xVel + self.acceleration * dt
         else
            self.xVel = self.maxSpeed
         end
      end
   elseif love.keyboard.isDown("a", "left") then
      if self.xVel > -self.maxSpeed then
         if self.xVel - self.acceleration * dt > -self.maxSpeed then
            self.xVel = self.xVel - self.acceleration * dt
         else
            self.xVel = -self.maxSpeed
         end
      end
   else
      self:applyFriction(dt)
   end
end

function Player:applyFriction(dt)
   if self.xVel > 0 then
      if self.xVel - self.friction * dt > 0 then
         self.xVel = self.xVel - self.friction * dt
      else
         self.xVel = 0
      end
   elseif self.xVel < 0 then
      if self.xVel + self.friction * dt < 0 then
         self.xVel = self.xVel + self.friction * dt
      else
         self.xVel = 0
      end
   end
end

function Player:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:setState()
   if not self.grounded then 
      self.state = "air"
   elseif self.xVel == 0 then
      self.state = "idle"
   else      
      self.state = "run"
   end
end
      
function Player:setDirection()
   if self.xVel < 0 then
      self.direction = "left"
   elseif self.xVel > 0 then
      self.direction = "right"
   end
end

function Player:animate(dt)
   self.animation.timer = self.animation.timer + dt 
   if self.animation.timer > self.animation.rate then 
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Player:setNewFrame()
   local anim = self.animation[self.state]
   if anim.current < anim.total then 
      anim.current = anim.current + 1
   else 
      anim.current = 1 
   end 
   self.animation.draw = anim.img[anim.current]
end

function Player:beginContact(a, b, collision)
   if self.grounded == true then return end
   local nx, ny = collision:getNormal()
   if a == self.physics.fixture then
      if ny > 0 then
         self:land(collision)
      elseif ny < 0 then 
         self.yVel = 0
      end
   elseif b == self.physics.fixture then
      if ny < 0 then
         self:land(collision)
      elseif ny > 0 then
         self.yVel = 0
      end
   end
end

function Player:land(collision)
   self.currentGroundCollision = collision
   self.yVel = 0
   self.grounded = true
   self.availableJumps = 2

end

function Player:jump()
   if self.availableJumps > 0 then
      if self.grounded then
         self.yVel = self.jumpAmount 
         self.grounded = false
         self.availableJumps = self.availableJumps - 1
      elseif not self.grounded then
         self.yVel = self.jumpAmount * 0.9
         self.availableJumps = self.availableJumps - 1
      end
   end
end

function Player:endContact(a, b, collision)
   if a == self.physics.fixture or b == self.physics.fixture then
      if self.currentGroundCollision == collision then
         self.grounded = false
      end
   end
end

function Player:incrementCoins()
   self.coins = self.coins + 1
end


function Player:draw()
   local scaleX = 1
   if self.direction == "left" then 
      scaleX = -1
   end
   love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
   love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2 )
   love.graphics.setColor(1, 1, 1, 1)
end

return Player