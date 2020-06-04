--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
    self.objects = {}
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end
        
function Player:checkObjectCollisions()
    local collidedObjects = {}

    for k, object in pairs(self.objects) do
        if self:collides(object) then
            -- trigger collision callback on object
            if object.onCollide then object:onCollide() end
            
            -- make sure we can't walk through the object if its solid
            print('! 1')
            if object.solid then
                print('! 2')
                table.insert(collidedObjects, object)
                if (love.keyboard.isDown('enter') or love.keyboard.isDown('return')) then
                    print('! here we are!.')
                end
            end
            
        -- if object has an onConsume function then use it
        elseif object.onConsume then
           object.onConsume(self.object, self.player) 
           table.remove(self.objects, k)
        end
    end
    
    return collidedObjects
end

function Player:checkCollisions(dt)
    -- check left collision
    if self.direction == 'right' then
        -- temporarily adjust position
        self.x = self.x + PLAYER_WALK_SPEED * dt
        local collidedObjects = self:checkObjectCollisions()
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
        local collidedObjects = self:checkObjectCollisions()
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
        local collidedObjects = self:checkObjectCollisions()
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
        local collidedObjects = self:checkObjectCollisions()
        -- reset position
        self.y = self.y + PLAYER_WALK_SPEED * dt

        -- reset X if new collided object
        if #collidedObjects > 0 then
            self.y = self.y + PLAYER_WALK_SPEED * dt
        end
    end
end

function Player:render()
    Entity.render(self)
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end