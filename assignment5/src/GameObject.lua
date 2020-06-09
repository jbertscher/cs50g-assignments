--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height
    
    -- velocity for when object is fired
    self.isProjectile = def.isProjectile
    self.fireDirection = def.fireDirection
    self.dx = def.dx
    self.dy = def.dy

    -- default empty collision callback
    self.onCollide = function() end
    
    self.onConsume = def.onConsume
    self.onInteraction = def.onInteraction
end

function GameObject:update(dt)
    if self.isProjectile then
        if self.fireDirection == 'left' then
            self.x = self.x - self.dx * dt          
        elseif self.fireDirection == 'right' then
            self.x = self.x + self.dx * dt
        elseif self.fireDirection == 'up' then
            self.y = self.y - self.dy * dt
        elseif self.fireDirection == 'down' then
            self.y = self.y + self.dy * dt
        end
    end
end

function GameObject:fire(entity)
    self.isProjectile = true
    self.fireDirection = entity.direction
end

function GameObject:collides(entity)
    -- if the object collides with an entity
        -- object disappears (or is destroyed)
            -- self.onCollide(self) called
        -- entity loses life
            -- entity object's life decremented
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states and self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end