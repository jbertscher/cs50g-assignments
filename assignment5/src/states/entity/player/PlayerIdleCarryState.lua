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
end

function PlayerIdleCarryState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
           self.entity:changeState('carry', self.carriedObject)
    end

    if love.keyboard.wasPressed('space') then
        self.entity:changeState('throw')
    end
end