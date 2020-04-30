--[[
    GD50
    Breakout Remake

    -- Powerup Class --

    Author: Jonathan Bertscher

    Represents a powerup, which, when come into contact with the padde, 
    causes 2 additional balls to spawn.
]]

Powerup = Class{}

function Powerup:__init__(skin, x, y)
    -- simple positional and dimensional variables
    self.width = 8
    self.height = 8
    self.x = x
    self.y = y

    -- keeping track of velocity in Y axis, since powerup can only move downwards. 
    self.dy = math.random(60, 70)

    -- this will be the skin used for the powerup
    self.skin = skin

    -- used to determine whether the powerup should be updated and rendered
    self.inPlay = true
end

function Powerup:collides()
	self.inPlay = false
end

function Powerup:update(dt)
	if self.inPlay then
		self.y = self.y + self.dy * dt
	end
end

function Powerup:render()
    -- -- gTexture is our global texture for all blocks
    -- -- gBallFrames is a table of quads mapping to each individual ball skin in the texture
    -- love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin],
    --     self.x, self.y)
end

