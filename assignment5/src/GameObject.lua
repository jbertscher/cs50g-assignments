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
    
    -- whether object should be removed from the table of game objects
    self.inPlay = true

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
    
    -- parameters for when object is projectile
    self.isProjectile = def.isProjectile
    self.fireDirection = def.fireDirection
    self.hitPoints = def.hitPoints
    self.dx = def.dx
    self.dy = def.dy
    
    self.currentRoom = def.room

    -- default empty collision callback
    self.onCollide = function() end
    
    -- other callbacks
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
        
        -- check collision with entity
        for k, entity in pairs(self.currentRoom.entities) do
            if entity:collides(self) then
                entity:damage(self.hitPoints)
                self.inPlay = false
            end
        end
        
        -- check collision with wall
        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) 
            + MAP_RENDER_OFFSET_Y - TILE_SIZE
            
        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE or 
            self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 or
            self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 or 
            self.y + self.height >= bottomEdge then
                self.inPlay = false
        end
        
        -- check travelling farther than 4 tiles
        end
end

function GameObject:fire(entity, room)
    self.isProjectile = true
    self.fireDirection = entity.direction
    self.y = entity.y
    self.currentRoom = room
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