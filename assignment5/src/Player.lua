--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end
        
function Player:checkObjectCollisions(objects)
    local collidedObjects = {}

    for k, object in pairs(objects) do
        if self:collides(object) then
            -- trigger collision callback on object
            if object.onCollide then object.onCollide() end
            
            -- make sure we can't walk through the object if its solid
            if object.solid then
                table.insert(collidedObjects, object)
            
            -- if object has an onConsume function then use it
            elseif object.onConsume then
                object.onConsume(self.object, self) 
                table.remove(objects, k)
            end
        end
    end
    
    return collidedObjects
end

function Player:checkCollisions(dt, objects)
    -- check left collision
    if self.direction == 'right' then
        -- temporarily adjust position
        self.x = self.x + PLAYER_WALK_SPEED * dt
        local collidedObjects = self:checkObjectCollisions(objects)
        -- reset position
        self.x = self.x - PLAYER_WALK_SPEED * dt

        -- reset X if new collided object
        if #collidedObjects > 0 then
            self.x = self.x - PLAYER_WALK_SPEED * dt
        end
        
    -- check right collision
    elseif self.direction == 'left' then
        -- temporarily adjust position
        self.x = self.x - PLAYER_WALK_SPEED * dt
        local collidedObjects = self:checkObjectCollisions(objects)
        -- reset position
        self.x = self.x + PLAYER_WALK_SPEED * dt

        -- reset X if new collided object
        if #collidedObjects > 0 then
            self.x = self.x + PLAYER_WALK_SPEED * dt
        end
        
    -- check top collision
    elseif self.direction == 'down' then
        -- temporarily adjust position
        self.y = self.y + PLAYER_WALK_SPEED * dt
        local collidedObjects = self:checkObjectCollisions(objects)
        -- reset position
        self.y = self.y - PLAYER_WALK_SPEED * dt

        -- reset X if new collided object
        if #collidedObjects > 0 then
            self.y = self.y - PLAYER_WALK_SPEED * dt
        end
        
    -- check bottom collision
    else 
        -- temporarily adjust position
        self.y = self.y - PLAYER_WALK_SPEED * dt
        local collidedObjects = self:checkObjectCollisions(objects)
        -- reset position
        self.y = self.y + PLAYER_WALK_SPEED * dt

        -- reset X if new collided object
        if #collidedObjects > 0 then
            self.y = self.y + PLAYER_WALK_SPEED * dt
        end
    end
end

function Player:checkInteractiveObject(objects)
    -- return all objects touching the player
    local touchingObjects = {}

    for k, object in pairs(objects) do
        if self:collides(object) then
            -- check that object is interactive
            if object.onInteraction then
                object.onInteraction(object, self)
                return object
            end
        end
    end
end

function Player:checkInteractions(dt, objects)
    -- check if just to left of object
    if self.direction == 'right' then
        -- temporarily adjust position
        self.x = self.x + 2
        local interactiveObject = self:checkInteractiveObject(objects)
        -- reset position
        self.x = self.x - 2
    end
    
    -- check if just to the right of object
    if self.direction == 'left' then
        -- temporarily adjust position
        self.x = self.x - 2
        local interactiveObject = self:checkInteractiveObject(objects)
        -- reset position
        self.x = self.x + 2
    end
    
    -- check if just above object
    if self.direction == 'down' then
        -- temporarily adjust position
        self.y = self.y + 2
        local interactiveObject = self:checkInteractiveObject(objects)
        -- reset position
        self.y = self.y - 2
    end
    
    -- check if just below object
    if self.direction == 'up' then
        -- temporarily adjust position
        self.y = self.y - 2
        local interactiveObject = self:checkInteractiveObject(objects)
        -- reset position
        self.y = self.y + 2
    end
end

function Player:render()
    Entity.render(self)
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end