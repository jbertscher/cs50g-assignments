--[[
    GD50
    Breakout Remake

    -- Powerup Class --

    Author: Jonathan Bertscher

    Represents a powerup, which, when come into contact with the padde, 
    causes 2 additional balls to spawn.
]]

Powerup = Class{}

function Powerup:init(skin)
    -- simple positional and dimensional variables
    self.width = 8
    self.height = 8
    self.x = 0
    self.y = 0

    -- keeping track of velocity in Y axis, since powerup can only move downwards. 
    self.dy = 70

    -- this will indicate the powerup type (the action that it performs)
    self.type = type

    -- this will be the skin used for the powerup
    self.skin = skin

    -- used to determine whether the powerup should be updated and rendered
    self.isVisible = false

    -- used to determine whether the effect of the powerup should be maintained
    self.inPlay = false

    -- used to determine elapsed time since the powerup is spawned
    self.startTime = os.time()
end

function Powerup:collides(paddle)
    -- check if powerup is above or below paddle
    if self.y + self.height < paddle.y or self.y > paddle.y + paddle.height then
    	return false
    end

    -- otherwise, check if edge of powerup is beyond edge of paddle
    if self.x + self.width < paddle.x or self.x > paddle.x + paddle.width then
    	return false
    end

    -- otherwise, if neither of above conditions met, we must have a collision
	self.y = paddle.y - self.height 
	return true
end

--[[
    Update powerup, if visible
]]
function Powerup:update(dt)
    if self.isVisible then
        self.y = self.y + self.dy * dt
    end
end

--[[
	Render powerup, if visible
]]
function Powerup:render()
    if self.isVisible then
        -- gTexture is our global texture for all blocks
        love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin],
    	   self.x, self.y)
    end

    -- render the key next to the hearts to indicate that the key powerup is in play
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin],
           VIRTUAL_WIDTH - 120, 0)
    end
end