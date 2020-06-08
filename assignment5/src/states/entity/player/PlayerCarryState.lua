PlayerCarryState = Class{__includes = EntityWalkState}

function PlayerCarryState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon

    -- render offset for spaced character sprite
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerCarryState:enter(object)
    print('! entered PlayerCarryState:enter')
    self.carriedObject = object
--    self:update()
end

function PlayerCarryState:update(dt)
    print('! just entered PlayerCarryState:update')
    
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
        self.entity:changeAnimation('idle-carry-' .. self.entity.direction)
    end
    
    if love.keyboard.isDown('space') then
        self.entity:changeState('throw', pot)
    end
    
--    print('! CURRENT ANIMATION: ' .. self.entity.currentAnimation)
    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)
    print('! just ended PlayerCarryState:update')
end

--function PlayerCarryState:render()    
--    -- render object (player animation handled by PlayerWalkState)
--end