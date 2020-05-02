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
    self.dy = math.random(60, 70)

    -- this will be the skin used for the powerup
    self.skin = skin

    -- used to determine whether the powerup should be updated and rendered
    self.inPlay = false
end

function Powerup:collides(paddle)
    -- check if powerup is above or below paddle
    if self.y > paddle.y + paddle.height or self.y < paddle.y + 2 then
    	return false
    end

    -- otherwise, check if edge of powerup is beyond edge of paddle
    if self.x > paddle.x + paddle.width or self.x < paddle.x then
    	return false
    end

    -- otherwise, if neither of above conditions met, we must have a collision
	self.y = paddle.y - self.height 
	return true
end

function Powerup:update(dt)
	if self.inPlay then
		self.y = self.y + self.dy * dt
	end
end

--[[
	Render powerup if it's in play
]]
function Powerup:render()
    -- gTexture is our global texture for all blocks
    -- gFrames['powerups'] is a table of quads mapping to each individual powerup skin in the texture
    if self.inPlay then
	    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.skin],
	        self.x, self.y)
	end
end