PlayerThrowState = Class{__includes = PlayerThrowState}

function PlayerThrowState:init(player)
    self.entity = player

    -- throw pot animation (depends on which direction player is in)
    if self.entity.direction == 'left' then
        self.entity.changeAnimation('throw-left')
    elseif self.entity.direction == 'right' then
        self.entity.changeAnimation('throw-right')
    elseif self.entity.direction == 'up' then
        self.entity.changeAnimation('throw-up')
    elseif self.entity.direction == 'down' then
        self.entity.changeAnimation('throw-down')
    end 
end

function PlayerThrowState:enter(object)
    self.carriedObject = object
end

function PlayerThrowState:update(dt)
    -- movement of object
end