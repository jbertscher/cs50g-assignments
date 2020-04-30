--[[
    ScoreState Class
    Author: Jonathan Bertscher
    jbertscher@gmail.com

    Pause state
]]

PauseState = Class{__includes = BaseState}

function PauseState:enter(params)
    sounds['music']:pause()
    
    -- save parameters, which we'll pass back to the play state when game unpaused
    self.params = params

    -- initialise bird and pipe from parameters, so that they can be correctly rendered
    self.bird = params.bird
    self.pipePairs = params.pipePairs 
    self.score = params.score
end

function PauseState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        sounds['music']:play()
        gStateMachine:change('play', self.params)
    end
end

function PauseState:render()
    scrolling = false

    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()

    -- draw the pause icon. resize it so that it's 80x80 pixels.
    pause = love.graphics.newImage('pause.png')
    pause_size = 80
    love.graphics.draw(pause, VIRTUAL_WIDTH/2 - pause_size/2, VIRTUAL_HEIGHT/2 - 90, 0, 
        pause_size/pause:getWidth(), pause_size/pause:getHeight())

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Game paused. Press \'enter\' to resume', 0, 170, VIRTUAL_WIDTH, 'center')
end