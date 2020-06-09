PlayerIdleCarryState = Class{__includes = EntityIdleState}

function PlayerIdleCarryState:enter(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
end

function PlayerIdleCarryState:enter(object)
    self.carriedObject = object
    
    self.entity:changeAnimation('idle-carry-' .. self.entity.direction)
    
    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerIdleCarryState:update(dt)
    EntityIdleState.update(self, dt)
    
    if self.entity.direction == 'left' then
        Timer.tween(0.1, {
            [self.carriedObject] = {
                x = self.entity.x,
                y = self.entity.y - self.carriedObject.height + 8
            }
        })
    elseif self.entity.direction == 'right' then
        Timer.tween(0.1, {
            [self.carriedObject] = {
                x = self.entity.x,
                y = self.entity.y - self.carriedObject.height + 8
            }
        })
    elseif self.entity.direction == 'down' then
        Timer.tween(0.1, {
            [self.carriedObject] = {
                y = self.entity.y - self.carriedObject.height + 12
            }
        })
    elseif self.entity.direction == 'up' then
        Timer.tween(0.1, {
            [self.carriedObject] = {
                y = self.entity.y - self.carriedObject.height + 4
            }
        })
    end
    
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
           self.entity:changeState('carry', self.carriedObject)
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('throw')
    end
end