local Camera = { 
    x = 0,
    y = 0,
    scale = 2 -- zoom
}

function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x, -self.y) -- content moves left when we move right
end 

function Camera:clear()
    love.graphics.pop()

end

function Camera:setPosition(x, y)
    -- center the passed in entity
    self.x = x - love.graphics.getWidth() / 2 / self.scale
    self.y = y

    local RS = self.x + love.graphics.getWidth() / 2

    if self.x < 0 then 
        self.x = 0
    elseif RS > MapWidth then -- RS: Right side
        self.x = MapWidth - love.graphics.getWidth() / 2
    end
end 

return Camera