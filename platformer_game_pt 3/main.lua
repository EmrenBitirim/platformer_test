Class = require 'libraries.class'

love.graphics.setDefaultFilter('nearest', 'nearest')
require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/TitleScreen'


function love.load()


    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['play'] = function() return PlayState() end,
    }

    gStateMachine:change('play')

    -- initialize input table 
    love.keyboard.keysPressed = {}

end 

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then 
        love.event.quit()
    end 
end 

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
    
end

function love.update(dt)
    gStateMachine:update(dt)

    -- reset table at every frame 
    love.keyboard.keysPressed = {}

end 

function love.draw()
    gStateMachine:render()
    
end 
