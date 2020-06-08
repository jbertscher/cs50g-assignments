PlayerCarryState = Class{__includes = EntityWalkState}

function PlayerCarryState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerCarryState:enter(object)
    self.carriedObject = object
end

function PlayerCarryState:update(dt)
    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('carry-left')
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('carry-right')
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('carry-up')
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('carry-down')
    -- player is still carrying the object but is not walking (is idle)
    else
        self.entity:changeState('idle-carry', self.carriedObject)
    end
    
    if love.keyboard.isDown('space') then
        self.entity:changeState('throw', self.carriedObject )
    end
    
    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)
end